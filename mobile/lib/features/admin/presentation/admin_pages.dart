import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/role_tab_bar.dart';
import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/presentation/status_text.dart';
import '../../../core/theme/app_palette.dart';
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

/// Полоса «внутренний инструмент» — админку не спутать с экраном организатора.
class AdminBanner extends StatelessWidget {
  const AdminBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 8),
      child: Row(children: [
        Icon(LucideIcons.shieldCheck, size: 14, color: c.textMuted),
        const SizedBox(width: 6),
        Text(context.l10n.adminBanner, style: AppText.caption.copyWith(color: c.textMuted)),
      ]),
    );
  }
}

String roleLabel(AppLocalizations l, UserRole r) => switch (r) {
      UserRole.attendee => l.roleAttendee,
      UserRole.organizer => l.roleOrganizer,
      UserRole.eventAdmin => l.roleEventAdmin,
      UserRole.platformAdmin => l.rolePlatformAdmin,
      UserRole.unknown => l.roleUnknown,
    };

Tone roleTone(UserRole r) => switch (r) {
      UserRole.organizer => Tone.primary,
      UserRole.eventAdmin => Tone.info,
      UserRole.platformAdmin => Tone.warning,
      _ => Tone.neutral,
    };

/// Кнопка профиля в шапке вкладок админа (отдельной вкладки нет).
class _AccountAction extends StatelessWidget {
  const _AccountAction();

  @override
  Widget build(BuildContext context) =>
      CircleIconButton(icon: LucideIcons.user, tooltip: context.l10n.account, onPressed: () => context.push(Routes.adminAccount));
}

Widget _none(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(context.l10n.nothingHere, style: AppText.meta.copyWith(color: context.colors.textMuted)),
    );

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, this.badge});

  final OrderInfo order;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final o = order;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  [l.orderNo('${o.id}'), if (o.createdAt != null) Fmt.shortDateTime(o.createdAt!)].join(' · '),
                  style: AppText.meta.copyWith(color: c.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
              badge ?? TagLabel(o.status.text(l), tone: o.status.tone),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.attendeeName ?? o.attendeeEmail ?? '—', style: AppText.cardTitle.copyWith(color: c.text)),
                    if (o.eventTitle != null) Text(o.eventTitle!, style: AppText.meta.copyWith(color: c.textMuted)),
                  ],
                ),
              ),
              Text(Fmt.money(o.total), style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── очереди (§4.12) ───────────────────────────────────────────────────────

class AdminQueuesViewModel extends Loadable<AdminQueues> {
  AdminQueuesViewModel(GetAdminQueues get) : super(get.call);
}

class AdminQueuesPage extends StatelessWidget {
  const AdminQueuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<AdminQueuesViewModel>();
    return RoleScaffold(
      tabs: RoleTabs.admin,
      current: Routes.adminQueues,
      title: l.workQueues,
      action: const _AccountAction(),
      body: Column(
        children: [
          const AdminBanner(),
          Expanded(
            child: LoadableView<AdminQueues>(
              state: vm,
              builder: (context, q) => RefreshIndicator(
                onRefresh: vm.load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 24),
                  children: [
                    StatQuad(cells: [
                      (Fmt.count(q.pendingPayments.length), l.unpaidOrders),
                      (Fmt.count(q.paidSalesEvents.length), l.paidSalesEvents),
                      (Fmt.count(q.suspendedUsers.length), l.suspendedUsers),
                      (Fmt.count(q.recentRefunds.length), l.refundsQueue),
                    ]),
                    const SizedBox(height: 8),
                    Text(l.platformTotals(q.totals.users, q.totals.events, q.totals.orders), style: AppText.meta.copyWith(color: c.textMuted)),
                    const SizedBox(height: AppSpacing.section),
                    SectionLabel(l.unpaidOrdersHint),
                    const SizedBox(height: 10),
                    if (q.pendingPayments.isEmpty) _none(context),
                    for (final o in q.pendingPayments.take(10))
                      _OrderRow(order: o, badge: TagLabel(l.noTicketsIssued, tone: Tone.warning)),
                    const SizedBox(height: AppSpacing.block),
                    SectionLabel(l.paidSalesRecords),
                    const SizedBox(height: 10),
                    if (q.paidSalesEvents.isEmpty) _none(context),
                    for (final e in q.paidSalesEvents) _AdminEventCard(event: e),
                    const SizedBox(height: AppSpacing.block),
                    SectionLabel(l.refundsQueue),
                    const SizedBox(height: 10),
                    if (q.recentRefunds.isEmpty) _none(context),
                    for (final o in q.recentRefunds.take(10)) _OrderRow(order: o),
                    const SizedBox(height: AppSpacing.block),
                    SecondaryButton(label: l.allOrdersPayments, icon: LucideIcons.receipt, onPressed: () => context.go(Routes.adminOrders)),
                    const SizedBox(height: AppSpacing.section),
                    InfoBanner(text: '${l.notInBuild}. ${l.notInBuildBody}', tone: Tone.neutral, icon: LucideIcons.info),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminEventCard extends StatelessWidget {
  const _AdminEventCard({required this.event});

  final EventInfo event;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final e = event;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        onTap: () => context.push(Routes.adminEvent(e.id)),
        child: Row(children: [
          EventImage(url: e.imageUrl, label: e.title, height: 56, width: 56, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title, style: AppText.cardTitle.copyWith(color: c.text)),
                Text(
                  [e.startsAt == null ? l.noDate : Fmt.dateTime(e.startsAt!), ?e.organizerName].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.meta.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  TagLabel(e.status.text(l), tone: e.status.tone),
                  if (e.paidSalesActivated) TagLabel(l.paidSalesTag, tone: Tone.primary, dot: false),
                ]),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: c.textMuted),
        ]),
      ),
    );
  }
}

// ─── события ───────────────────────────────────────────────────────────────

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
    final l = context.l10n;
    final vm = context.watch<AdminEventsViewModel>();
    final statuses = <EventStatus?>[null, ...EventStatus.values];
    return RoleScaffold(
      tabs: RoleTabs.admin,
      current: Routes.adminEvents,
      title: l.navEvents,
      action: const _AccountAction(),
      body: Column(
        children: [
          const AdminBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 12),
            child: LabeledTextField(controller: _q, compact: true, leadingIcon: LucideIcons.search, hintText: l.adminEventsSearch, onChanged: vm.setQuery),
          ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.side),
              itemCount: statuses.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => FilterChipPill(
                label: statuses[i]?.text(l) ?? l.attAll,
                active: vm.status == statuses[i],
                onTap: () => vm.setStatus(statuses[i]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LoadableView<List<EventInfo>>(
              state: vm,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 24),
                children: [
                  if (vm.visible.isEmpty) _none(context),
                  for (final e in vm.visible) _AdminEventCard(event: e),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── модерация события ─────────────────────────────────────────────────────

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

/// Модерация события — приостановка продаж (§4.12, §4.5).
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
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.suspendEventTitle),
        content: Text(l.suspendEventBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.actionKeep)),
          TextButton(onPressed: () => Navigator.pop(d, true), child: Text(l.actSuspend, style: TextStyle(color: d.colors.danger))),
        ],
      ),
    );
    if (ok != true) return;
    final f = await vm.suspend(_reason.text);
    if (mounted) reportResult(context, f, success: l.eventSuspendedToast);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<ModerationViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(subtitle: l.moderation, title: vm.data?.event.title ?? l.eventFallback, onBack: () => context.pop()),
            const AdminBanner(),
            Expanded(
              child: LoadableView<ModerationCase>(
                state: vm,
                builder: (context, m) {
                  final e = m.event;
                  final o = m.organizer;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          EventImage(url: e.imageUrl, label: e.title, height: 56, width: 56, radius: 12),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.moderationSummary(e.organizerName ?? l.organizerFallback, Fmt.count(m.ticketsSold), Fmt.money(m.collected, freeWord: false)),
                                  style: AppText.meta.copyWith(color: c.textMuted),
                                ),
                                const SizedBox(height: 6),
                                Wrap(spacing: 6, runSpacing: 4, children: [
                                  vm.suspended ? TagLabel(l.suspendedTag, tone: Tone.danger) : TagLabel(e.status.text(l), tone: e.status.tone),
                                  if (e.paidSalesActivated) TagLabel(l.paidSalesActive, tone: Tone.primary, dot: false),
                                ]),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: DetailGrid(rows: [
                          if (e.startsAt != null) (l.whenLabel, Fmt.range(e.startsAt!, e.endsAt)),
                          if (e.fullAddress.isNotEmpty) (l.venueLabel, e.fullAddress),
                          (l.visibilityLabel, e.visibility.text(l)),
                        ]),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      SectionLabel(l.organizerRecord),
                      const SizedBox(height: 10),
                      AppCard(
                        child: DetailGrid(rows: [
                          (l.accountLabel, o == null ? (e.organizerName ?? '—') : '${o.fullName} · ${o.email}'),
                          if (o != null) (l.emailVerified, o.emailVerified ? l.yes : l.no),
                          if (o != null) (l.userBlocked, o.suspended ? l.yes : l.no),
                          (l.ordersOnEvent, Fmt.count(m.orders.length)),
                          (l.orderRefunded, Fmt.count(m.orders.where((x) => x.status == OrderStatus.refunded).length)),
                        ]),
                      ),
                      if (!vm.suspended) ...[
                        const SizedBox(height: AppSpacing.section),
                        SectionLabel(l.suspendingWill),
                        const SizedBox(height: 8),
                        for (final line in [l.suspendWill1, l.suspendWill2, l.suspendWill3, l.suspendWill4])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Padding(padding: const EdgeInsets.only(top: 3), child: Icon(LucideIcons.dot, size: 14, color: c.textMuted)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(line, style: AppText.bodySecondary.copyWith(color: c.text))),
                            ]),
                          ),
                        const SizedBox(height: 12),
                        LabeledTextField(label: l.suspendReason, controller: _reason, maxLines: 3),
                        const SizedBox(height: 6),
                        Text(l.suspendReasonNote, style: AppText.finePrint.copyWith(color: c.textMuted)),
                      ],
                    ],
                  );
                },
              ),
            ),
            if (vm.data != null && !vm.suspended && vm.data!.event.status != EventStatus.cancelled)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 16),
                child: PrimaryButton(
                  label: l.suspendEventButton,
                  icon: LucideIcons.ban,
                  tone: Tone.danger,
                  isLoading: vm.isBusy,
                  onPressed: () => _suspend(vm),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── M-B13 пользователи ────────────────────────────────────────────────────

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

/// M-B13 · Пользователи: поиск, роли, блокировка.
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
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(u.suspended ? l.unblockTitle(u.fullName) : l.blockTitle(u.fullName)),
        content: Text(u.suspended ? l.unblockBody : l.blockBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.actionCancel)),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: Text(u.suspended ? l.actUnblock : l.actBlock, style: TextStyle(color: u.suspended ? null : d.colors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final f = await vm.toggle(u);
    if (mounted) reportResult(context, f, success: u.suspended ? l.userUnblockedToast : l.userBlockedToast);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<AdminUsersViewModel>();
    final roles = <UserRole?>[null, UserRole.attendee, UserRole.organizer, UserRole.eventAdmin, UserRole.platformAdmin];
    String chip(UserRole? r) => switch (r) {
          null => l.allRoles,
          UserRole.attendee => l.roleBuyer,
          UserRole.eventAdmin => l.roleGate,
          UserRole.platformAdmin => l.roleAdminShort,
          final r => roleLabel(l, r),
        };
    return RoleScaffold(
      tabs: RoleTabs.admin,
      current: Routes.adminUsers,
      title: l.navUsers,
      action: const _AccountAction(),
      body: Column(
        children: [
          const AdminBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 12),
            child: LabeledTextField(controller: _q, compact: true, leadingIcon: LucideIcons.search, hintText: l.nameOrEmail, onChanged: vm.setQuery),
          ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.side),
              itemCount: roles.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => FilterChipPill(label: chip(roles[i]), active: vm.role == roles[i], onTap: () => vm.setRole(roles[i])),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LoadableView<List<UserAccount>>(
              state: vm,
              builder: (context, _) => RefreshIndicator(
                onRefresh: vm.load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 24),
                  children: [
                    if (vm.visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(l.noUsersMatch, textAlign: TextAlign.center, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
                      ),
                    for (final u in vm.visible) ...[
                      AppCard(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InitialAvatar(u.fullName, size: 40),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(u.fullName, style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                                      Row(children: [
                                        Flexible(child: Text(u.email, overflow: TextOverflow.ellipsis, style: AppText.meta.copyWith(color: c.textMuted))),
                                        const SizedBox(width: 4),
                                        Tooltip(
                                          message: u.emailVerified ? l.emailVerified : '',
                                          child: Icon(
                                            u.emailVerified ? LucideIcons.circleCheck : LucideIcons.circleDashed,
                                            size: 14,
                                            color: u.emailVerified ? c.success : c.textMuted,
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                                TagLabel(u.suspended ? l.userBlocked : l.userActive, tone: u.suspended ? Tone.danger : Tone.success),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(children: [
                              TagLabel(roleLabel(l, u.role), tone: roleTone(u.role), dot: false),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  [l.userNo('${u.id}'), if (u.createdAt != null) Fmt.date(u.createdAt!)].join(' · '),
                                  style: AppText.caption.copyWith(color: c.textMuted, fontWeight: FontWeight.w400),
                                ),
                              ),
                              if (u.role == UserRole.platformAdmin)
                                TagLabel(l.staffTag, dot: false)
                              else
                                TextButton.icon(
                                  onPressed: vm.isBusy ? null : () => _toggle(vm, u),
                                  style: TextButton.styleFrom(
                                    foregroundColor: u.suspended ? c.text : c.danger,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: c.border)),
                                  ),
                                  icon: Icon(u.suspended ? LucideIcons.lockOpen : LucideIcons.lock, size: 14),
                                  label: Text(u.suspended ? l.actUnblock : l.actBlock, style: AppText.caption.copyWith(fontWeight: FontWeight.w600)),
                                ),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── заказы ────────────────────────────────────────────────────────────────

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
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<AdminOrdersViewModel>();
    final statuses = <OrderStatus?>[null, ...OrderStatus.values];
    return RoleScaffold(
      tabs: RoleTabs.admin,
      current: Routes.adminOrders,
      title: l.navOrders,
      action: const _AccountAction(),
      body: Column(
        children: [
          const AdminBanner(),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.side),
              itemCount: statuses.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => FilterChipPill(
                label: statuses[i]?.text(l) ?? l.attAll,
                active: vm.status == statuses[i],
                onTap: () => vm.setStatus(statuses[i]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LoadableView<List<OrderInfo>>(
              state: vm,
              builder: (context, _) => RefreshIndicator(
                onRefresh: vm.load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 24),
                  children: [
                    if (vm.visible.isEmpty) _none(context),
                    for (final o in vm.visible) _OrderRow(order: o),
                    const SizedBox(height: 8),
                    Text(l.noCardData, style: AppText.finePrint.copyWith(color: c.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
