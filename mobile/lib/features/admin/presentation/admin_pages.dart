import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/role_tab_bar.dart';
import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../../../shared/domain/entities/people.dart';
import '../../auth/domain/entities/user_session.dart';
import '../domain/admin_domain.dart';

/// Полоса «внутренний инструмент» — админку нельзя спутать с экраном
/// организатора (P: «on the ink field»).
class AdminBanner extends StatelessWidget {
  const AdminBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.ink,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideList, vertical: 8),
      child: Text('PLATFORM ADMIN · INTERNAL STAFF ONLY', style: AppText.statusStrip.copyWith(color: AppColors.paper)),
    );
  }
}

String roleLabel(UserRole r) => switch (r) {
      UserRole.attendee => 'Attendee',
      UserRole.organizer => 'Organizer',
      UserRole.eventAdmin => 'Event admin',
      UserRole.platformAdmin => 'Platform admin',
      UserRole.unknown => 'Unknown',
    };

// ─── P1 queues ─────────────────────────────────────────────────────────────

class AdminQueuesViewModel extends Loadable<AdminQueues> {
  AdminQueuesViewModel(GetAdminQueues get) : super(get.call);
}

/// P1 · Admin queues (§4.12)
class AdminQueuesPage extends StatelessWidget {
  const AdminQueuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminQueuesViewModel>();
    return RoleScaffold(
      tabs: RoleTabs.admin,
      current: Routes.adminQueues,
      title: 'Work queues',
      subtitle: Fmt.dayStamp(DateTime.now()),
      body: Column(
        children: [
          const AdminBanner(),
          Expanded(
            child: LoadableView<AdminQueues>(
              state: vm,
              builder: (context, q) => ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 18, AppSpacing.sideList, 24),
                children: [
                  StatQuad(cells: [
                    (Fmt.count(q.pendingPayments.length), 'Unpaid orders'),
                    (Fmt.count(q.paidSalesEvents.length), 'Paid-sales events'),
                    (Fmt.count(q.suspendedUsers.length), 'Suspended users'),
                    (Fmt.count(q.recentRefunds.length), 'Refunds'),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    '${q.totals.users} users · ${q.totals.events} events · ${q.totals.orders} orders on the platform',
                    style: AppText.meta.copyWith(color: AppColors.neutral600),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  const SectionLabel('Unpaid orders · payment failures and abandoned checkouts'),
                  if (q.pendingPayments.isEmpty) _none(),
                  for (final o in q.pendingPayments.take(10))
                    ListRow(
                      title: '${o.number} · ${Fmt.money(o.total)}',
                      subtitle: [?o.eventTitle, ?o.attendeeName, if (o.createdAt != null) Fmt.ago(o.createdAt!)].join(' · '),
                      trailing: const TagLabel('No tickets issued'),
                    ),
                  const SizedBox(height: AppSpacing.section),
                  const SectionLabel('Paid sales active · activation records'),
                  if (q.paidSalesEvents.isEmpty) _none(),
                  for (final e in q.paidSalesEvents)
                    ListRow(
                      title: e.title,
                      subtitle: [?e.organizerName, e.status.label].join(' · '),
                      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.neutral500),
                      onTap: () => context.push(Routes.adminEvent(e.id)),
                    ),
                  const SizedBox(height: AppSpacing.section),
                  const SectionLabel('Refunds'),
                  if (q.recentRefunds.isEmpty) _none(),
                  for (final o in q.recentRefunds.take(10))
                    ListRow(
                      title: '${o.number} · ${Fmt.money(o.total)}',
                      subtitle: [?o.eventTitle, ?o.attendeeName].join(' · '),
                      trailing: TagLabel(o.status.label),
                    ),
                  const SizedBox(height: AppSpacing.block),
                  SecondaryButton(label: 'All orders & payments', onPressed: () => context.push(Routes.adminOrders)),
                  const SizedBox(height: AppSpacing.section),
                  const SectionLabel('Not available in this build'),
                  const SizedBox(height: 6),
                  Text(
                    'Reported events, activation reviews, escalated support cases, report exports and activation '
                    'fee settings need backend endpoints that do not exist yet.',
                    style: AppText.bodySecondary.copyWith(color: AppColors.neutral600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _none() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text('Nothing here.', style: AppText.meta.copyWith(color: AppColors.neutral600)),
      );
}

// ─── events ────────────────────────────────────────────────────────────────

class AdminEventsViewModel extends Loadable<List<EventInfo>> {
  AdminEventsViewModel(AdminLists lists) : super(lists.events);

  String query = '';
  EventStatus? status;

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  void setStatus(EventStatus? s) {
    status = s;
    notifyListeners();
  }

  List<EventInfo> get visible {
    final q = query.trim().toLowerCase();
    return [
      for (final e in data ?? const <EventInfo>[])
        if ((status == null || e.status == status) &&
            (q.isEmpty || '${e.title} ${e.organizerName ?? ''} ${e.city ?? ''}'.toLowerCase().contains(q)))
          e,
    ];
  }
}

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminEventsViewModel>();
    final statuses = <EventStatus?>[null, ...EventStatus.values];
    return RoleScaffold(
      tabs: RoleTabs.admin,
      current: Routes.adminEvents,
      title: 'Events',
      body: Column(
        children: [
          const AdminBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 12, AppSpacing.sideList, 0),
            child: LabeledTextField(controller: _q, leadingIcon: Icons.search, hintText: 'Event, organizer or city', onChanged: vm.setQuery),
          ),
          UnderlineTabs(
            labels: [for (final s in statuses) s?.label ?? 'All'],
            current: statuses.indexOf(vm.status),
            onSelect: (i) => vm.setStatus(statuses[i]),
          ),
          Expanded(
            child: LoadableView<List<EventInfo>>(
              state: vm,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideList),
                children: [
                  for (final e in vm.visible)
                    ListRow(
                      overline: e.startsAt == null ? 'NO DATE' : Fmt.dayStamp(e.startsAt!),
                      title: e.title,
                      subtitle: [?e.organizerName, e.venueLine, if (e.paidSalesActivated) 'Paid sales'].where((s) => s.isNotEmpty).join(' · '),
                      trailing: TagLabel(e.status.label),
                      onTap: () => context.push(Routes.adminEvent(e.id)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── P2 moderation ─────────────────────────────────────────────────────────

class ModerationViewModel extends Loadable<ModerationCase> {
  ModerationViewModel({required int eventId, required GetModerationCase get, required this._actions})
      : super(() => get(eventId));

  final ModerationActions _actions;
  bool suspended = false;

  Future<Failure?> suspend(String reason) async {
    final f = await run(() => _actions.suspendEvent(data!.event, reason));
    if (f == null) {
      suspended = true;
      notifyListeners();
    }
    return f;
  }
}

/// P2 · Moderate an event — suspend sales (§4.12, §4.5)
class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _suspend(ModerationViewModel vm) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Suspend this event?', style: AppText.headerTitle.copyWith(color: AppColors.ink)),
        content: Text('New checkouts stop immediately. Issued tickets stay valid until voided.',
            style: AppText.body.copyWith(color: AppColors.neutral700)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('KEEP')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('SUSPEND')),
        ],
      ),
    );
    if (ok != true) return;
    final f = await vm.suspend(_reason.text);
    if (mounted) reportResult(context, f, success: 'Event suspended and sales stopped.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ModerationViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: vm.data?.event.title ?? 'Event', subtitle: 'Moderation', onBack: () => context.pop()),
            const AdminBanner(),
            Expanded(
              child: LoadableView<ModerationCase>(
                state: vm,
                builder: (context, m) {
                  final e = m.event;
                  final o = m.organizer;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 18, AppSpacing.sideLight, 24),
                    children: [
                      Wrap(spacing: 6, children: [
                        TagLabel(vm.suspended ? 'Suspended' : e.status.label, filled: !vm.suspended),
                        if (e.paidSalesActivated) const TagLabel('Paid sales active'),
                      ]),
                      const SizedBox(height: 10),
                      Text(
                        '${e.organizerName ?? 'Organizer'} · ${Fmt.count(m.ticketsSold)} tickets sold · '
                        '${Fmt.money(m.collected, freeWord: false)} collected',
                        style: AppText.bodySecondary.copyWith(color: AppColors.neutral700),
                      ),
                      const SizedBox(height: 14),
                      DetailGrid(rows: [
                        if (e.startsAt != null) ('When', Fmt.range(e.startsAt!, e.endsAt)),
                        if (e.fullAddress.isNotEmpty) ('Venue', e.fullAddress),
                        ('Visibility', e.visibility.label),
                      ]),
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('Organizer record'),
                      const SizedBox(height: 8),
                      DetailGrid(rows: [
                        ('Account', o == null ? (e.organizerName ?? '—') : '${o.fullName} · ${o.email}'),
                        if (o != null) ('Email verified', o.emailVerified ? 'Yes' : 'No'),
                        if (o != null) ('Suspended', o.suspended ? 'Yes' : 'No'),
                        ('Orders on this event', Fmt.count(m.orders.length)),
                        ('Refunded', Fmt.count(m.orders.where((x) => x.status == OrderStatus.refunded).length)),
                      ]),
                      if (!vm.suspended) ...[
                        const SizedBox(height: AppSpacing.section),
                        const SectionLabel('Suspending will', color: AppColors.accent700),
                        const SizedBox(height: 8),
                        for (final line in const [
                          'Stop new checkouts for this event immediately.',
                          'Leave issued tickets valid until you void them.',
                          'Hold any payout to the organizer.',
                          'Write an entry into the event\'s audit trail.',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('— $line', style: AppText.bodySecondary.copyWith(color: AppColors.ink)),
                          ),
                        const SizedBox(height: 12),
                        LabeledTextField(
                          label: 'Reason recorded and sent to the organizer',
                          controller: _reason,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 6),
                        Text('The current API does not store the reason yet; keep it for your records.',
                            style: AppText.finePrint.copyWith(color: AppColors.neutral600)),
                      ],
                    ],
                  );
                },
              ),
            ),
            if (vm.data != null && !vm.suspended && vm.data!.event.status != EventStatus.cancelled)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
                child: PrimaryButton(label: 'Suspend event & sales', isLoading: vm.isBusy, onPressed: () => _suspend(vm)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── users ─────────────────────────────────────────────────────────────────

class AdminUsersViewModel extends Loadable<List<UserAccount>> {
  AdminUsersViewModel({required AdminLists lists, required this._actions, required this.currentAdminId})
      : super(lists.users);

  final ModerationActions _actions;
  final int currentAdminId;
  String query = '';
  UserRole? role;

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  void setRole(UserRole? r) {
    role = r;
    notifyListeners();
  }

  List<UserAccount> get visible {
    final q = query.trim().toLowerCase();
    return [
      for (final u in data ?? const <UserAccount>[])
        if ((role == null || u.role == role) && (q.isEmpty || '${u.fullName} ${u.email}'.toLowerCase().contains(q))) u,
    ];
  }

  Future<Failure?> toggle(UserAccount u) => run(
        () => u.suspended ? _actions.unsuspendUser(u) : _actions.suspendUser(u, currentAdminId: currentAdminId),
        reload: true,
      );
}

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _toggle(AdminUsersViewModel vm, UserAccount u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(u.suspended ? 'Restore ${u.fullName}?' : 'Suspend ${u.fullName}?',
            style: AppText.headerTitle.copyWith(color: AppColors.ink)),
        content: Text(
          u.suspended ? 'They can sign in and use BiletFlow again.' : 'They will not be able to sign in until restored.',
          style: AppText.body.copyWith(color: AppColors.neutral700),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(u.suspended ? 'RESTORE' : 'SUSPEND')),
        ],
      ),
    );
    if (ok != true) return;
    final f = await vm.toggle(u);
    if (mounted) reportResult(context, f, success: u.suspended ? 'User restored.' : 'User suspended.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminUsersViewModel>();
    final roles = <UserRole?>[null, UserRole.attendee, UserRole.organizer, UserRole.eventAdmin, UserRole.platformAdmin];
    return RoleScaffold(
      tabs: RoleTabs.admin,
      current: Routes.adminUsers,
      title: 'Users',
      body: Column(
        children: [
          const AdminBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 12, AppSpacing.sideList, 0),
            child: LabeledTextField(controller: _q, leadingIcon: Icons.search, hintText: 'Name or email', onChanged: vm.setQuery),
          ),
          UnderlineTabs(
            labels: [for (final r in roles) r == null ? 'All' : roleLabel(r)],
            current: roles.indexOf(vm.role),
            onSelect: (i) => vm.setRole(roles[i]),
          ),
          Expanded(
            child: LoadableView<List<UserAccount>>(
              state: vm,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideList),
                children: [
                  for (final u in vm.visible)
                    ListRow(
                      title: u.fullName,
                      subtitle: '${u.email} · #${u.id} · ${roleLabel(u.role)}${u.emailVerified ? '' : ' · email not verified'}',
                      trailing: u.role == UserRole.platformAdmin
                          ? const TagLabel('Staff')
                          : TextButton(
                              onPressed: vm.isBusy ? null : () => _toggle(vm, u),
                              child: Text(u.suspended ? 'RESTORE' : 'SUSPEND',
                                  style: AppText.buttonGhost.copyWith(color: AppColors.accent700)),
                            ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── orders ────────────────────────────────────────────────────────────────

class AdminOrdersViewModel extends Loadable<List<OrderInfo>> {
  AdminOrdersViewModel(AdminLists lists) : super(lists.orders);

  OrderStatus? status;

  void setStatus(OrderStatus? s) {
    status = s;
    notifyListeners();
  }

  List<OrderInfo> get visible => [for (final o in data ?? const <OrderInfo>[]) if (status == null || o.status == status) o];
}

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminOrdersViewModel>();
    final statuses = <OrderStatus?>[null, ...OrderStatus.values];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Orders & payments', subtitle: 'Demonstration amounts', onBack: () => context.pop()),
            const AdminBanner(),
            UnderlineTabs(
              labels: [for (final s in statuses) s?.label ?? 'All'],
              current: statuses.indexOf(vm.status),
              onSelect: (i) => vm.setStatus(statuses[i]),
            ),
            Expanded(
              child: LoadableView<List<OrderInfo>>(
                state: vm,
                builder: (context, _) => ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideList),
                  children: [
                    for (final o in vm.visible)
                      ListRow(
                        overline: o.createdAt == null ? null : Fmt.shortDateTime(o.createdAt!).toUpperCase(),
                        title: '${o.number} · ${Fmt.money(o.total)}',
                        subtitle: [?o.eventTitle, ?o.attendeeName, ?o.attendeeEmail].join(' · '),
                        trailing: TagLabel(o.status.label, filled: o.status == OrderStatus.completed),
                      ),
                    const SizedBox(height: 12),
                    Text('No card data is stored or shown. All payments are sandbox.',
                        style: AppText.finePrint.copyWith(color: AppColors.neutral600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
