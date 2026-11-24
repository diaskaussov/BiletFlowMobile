import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/platform/document_actions.dart';
import '../../../core/presentation/failure_text.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/presentation/status_text.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../domain/organizer_operations_domain.dart';
import 'event_shell.dart';

/// Заказ с его билетами — карточка M-B6.
class OrderGroup {
  const OrderGroup({required this.order, required this.tickets});

  final OrderInfo? order;
  final List<TicketInfo> tickets;

  bool get refundable => order != null && (order!.status == OrderStatus.completed || order!.status == OrderStatus.pending);

  /// «2× VIP · A-3-12, A-3-13»
  String get itemsLine {
    final o = order;
    if (o != null && o.items.isNotEmpty) {
      return o.items.map((i) {
        final seats = [for (final t in tickets) if (t.ticketTypeName == i.ticketTypeName && t.seat != null) t.seat!];
        return '${i.quantity}× ${i.ticketTypeName}${seats.isEmpty ? '' : ' · ${seats.join(', ')}'}';
      }).join('; ');
    }
    final t = tickets.first;
    return ['${tickets.length}× ${t.ticketTypeName ?? ''}'.trim(), ?t.seat].join(' · ');
  }
}

List<OrderGroup> groupOrders(List<AttendeeRow> rows) {
  final byOrder = <int, List<AttendeeRow>>{};
  final loose = <OrderGroup>[];
  for (final r in rows) {
    final o = r.order;
    if (o == null) {
      loose.add(OrderGroup(order: null, tickets: [r.ticket]));
    } else {
      byOrder.putIfAbsent(o.id, () => []).add(r);
    }
  }
  final groups = [
    for (final list in byOrder.values) OrderGroup(order: list.first.order, tickets: [for (final r in list) r.ticket]),
    ...loose,
  ];
  groups.sort((a, b) => (b.order?.createdAt ?? DateTime(0)).compareTo(a.order?.createdAt ?? DateTime(0)));
  return groups;
}

// ─── M-B6 заказы ───────────────────────────────────────────────────────────

class EventAttendeesViewModel extends Loadable<List<AttendeeRow>> {
  EventAttendeesViewModel({required this.eventId, required GetEventAttendees get, required this._refund}) : super(() => get(eventId));

  final int eventId;
  final RefundOrder _refund;
  AttendeeFilter filter = AttendeeFilter.all;
  String query = '';

  List<OrderGroup> get visible {
    final rows = filterAttendees(data ?? const [], filter, '');
    final q = query.trim().toLowerCase().replaceAll('№', '').replaceAll('#', '');
    return [
      for (final g in groupOrders(rows))
        if (q.isEmpty ||
            [g.order?.attendeeName, g.order?.attendeeEmail, g.order?.number, '${g.order?.id ?? ''}', for (final t in g.tickets) ...[t.attendeeName, t.attendeeEmail, t.displayId]]
                .whereType<String>()
                .any((s) => s.toLowerCase().contains(q)))
          g,
    ];
  }

  int count(AttendeeFilter f) => filterAttendees(data ?? const [], f, '').length;

  void setFilter(AttendeeFilter f) {
    filter = f;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  Future<Failure?> refund(OrderInfo order, String reason) => run(() => _refund(order, reason), reload: true);
}

String attendeeFilterText(AppLocalizations l, AttendeeFilter f) => switch (f) {
      AttendeeFilter.all => l.attAll,
      AttendeeFilter.checkedIn => l.attCheckedIn,
      AttendeeFilter.notArrived => l.attNotArrived,
      AttendeeFilter.refunded => l.attRefunded,
      AttendeeFilter.campaign => l.attCampaign,
    };

/// M-B6 · Заказы события с возвратом (§4.9, UC5).
class EventAttendeesPage extends StatefulWidget {
  const EventAttendeesPage({super.key});

  @override
  State<EventAttendeesPage> createState() => _EventAttendeesPageState();
}

class _EventAttendeesPageState extends State<EventAttendeesPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _filters(EventAttendeesViewModel vm) async {
    final l = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheet) {
        final c = sheet.colors;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 8),
                child: Text(l.filtersTitle, style: AppText.headerTitle.copyWith(color: c.text)),
              ),
              for (final f in AttendeeFilter.values)
                ListTile(
                  title: Text(attendeeFilterText(l, f), style: AppText.body.copyWith(color: c.text)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(Fmt.count(vm.count(f)), style: AppText.meta.copyWith(color: c.textMuted)),
                    const SizedBox(width: 10),
                    Icon(vm.filter == f ? LucideIcons.circleCheck : LucideIcons.circle, size: 20, color: vm.filter == f ? c.primary : c.border),
                  ]),
                  onTap: () {
                    vm.setFilter(f);
                    Navigator.of(sheet).pop();
                  },
                ),
              const Divider(),
              ListTile(
                leading: Icon(LucideIcons.share, size: 20, color: c.text),
                title: Text(l.exportCsv, style: AppText.bodyStrong.copyWith(color: c.text, fontSize: 15)),
                onTap: () {
                  Navigator.of(sheet).pop();
                  const DocumentActions().share(
                    utf8.encode(attendeesCsv(filterAttendees(vm.data ?? const [], vm.filter, vm.query))),
                    name: 'attendees-event-${vm.eventId}.csv',
                    mimeType: 'text/csv',
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<EventAttendeesViewModel>();
    return EventShell(
      eventId: vm.eventId,
      section: EventSection.orders,
      onChanged: vm.load,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 8),
            child: Row(children: [
              Expanded(
                child: LabeledTextField(
                  controller: _search,
                  compact: true,
                  leadingIcon: LucideIcons.search,
                  hintText: l.ordersSearchHint,
                  onChanged: vm.setQuery,
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: vm.filter == AttendeeFilter.all ? c.surface : c.primaryTint,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: c.border)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: vm.data == null ? null : () => _filters(vm),
                  child: SizedBox.square(
                    dimension: 48,
                    child: Icon(LucideIcons.slidersHorizontal, size: 18, color: vm.filter == AttendeeFilter.all ? c.text : c.primary),
                  ),
                ),
              ),
            ]),
          ),
          Expanded(
            child: LoadableView<List<AttendeeRow>>(
              state: vm,
              builder: (context, _) {
                final groups = vm.visible;
                return RefreshIndicator(
                  onRefresh: vm.load,
                  child: groups.isEmpty
                      ? ListView(children: [
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              vm.data!.isEmpty ? l.noOrdersYet : l.noOrdersMatch,
                              textAlign: TextAlign.center,
                              style: AppText.bodySecondary.copyWith(color: c.textMuted),
                            ),
                          ),
                        ])
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 24),
                          itemCount: groups.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, i) => OrderCard(
                            group: groups[i],
                            onOpen: groups[i].order == null
                                ? null
                                : () => context.push(Routes.eventOrder(vm.eventId, groups[i].order!.id)).then((_) => vm.load()),
                            onRefund: () => _refund(context, groups[i], vm.refund),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _refund(BuildContext context, OrderGroup g, Future<Failure?> Function(OrderInfo, String) refund) async {
  final done = await showRefundSheet(context, g, (reason) => refund(g.order!, reason));
  if (done && context.mounted) showMessage(context, context.l10n.refundedToast);
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.group, this.onOpen, this.onRefund});

  final OrderGroup group;
  final VoidCallback? onOpen;
  final VoidCallback? onRefund;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final o = group.order;
    final t = group.tickets.first;
    return AppCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                [o == null ? l.noOrder : l.orderNo('${o.id}'), if (o?.createdAt != null) Fmt.shortDateTime(o!.createdAt!)].join(' · '),
                style: AppText.meta.copyWith(color: c.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
            if (o != null) TagLabel(o.status.text(l), tone: o.status.tone) else TagLabel(t.status.text(l), tone: t.status.tone),
          ]),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o?.attendeeName ?? t.attendeeName ?? l.guest, style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                    if ((o?.attendeeEmail ?? t.attendeeEmail) != null)
                      Text(o?.attendeeEmail ?? t.attendeeEmail!, style: AppText.meta.copyWith(color: c.textMuted)),
                  ],
                ),
              ),
              if (o != null) Text(Fmt.money(o.total), style: AppText.headerTitle.copyWith(color: c.text)),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            Icon(LucideIcons.ticket, size: 16, color: c.textMuted),
            const SizedBox(width: 8),
            Expanded(child: Text(group.itemsLine, style: AppText.meta.copyWith(color: c.text, fontWeight: FontWeight.w500))),
            if (o?.promoCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: c.primaryTint, borderRadius: BorderRadius.circular(6)),
                child: Text(o!.promoCode!, style: AppText.badge.copyWith(color: c.primary, fontSize: 11)),
              ),
          ]),
          if (group.refundable && onRefund != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton.icon(
                onPressed: onRefund,
                style: TextButton.styleFrom(
                  foregroundColor: c.danger,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: c.border)),
                ),
                icon: const Icon(LucideIcons.undo2, size: 16),
                label: Text(l.refundMoney, style: AppText.bodyStrong),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// M-B6 · Шторка возврата: сводка, причина, подтверждение суммой.
Future<bool> showRefundSheet(BuildContext context, OrderGroup g, Future<Failure?> Function(String reason) onConfirm) async {
  final done = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _RefundSheet(group: g, onConfirm: onConfirm),
  );
  return done ?? false;
}

class _RefundSheet extends StatefulWidget {
  const _RefundSheet({required this.group, required this.onConfirm});

  final OrderGroup group;
  final Future<Failure?> Function(String reason) onConfirm;

  @override
  State<_RefundSheet> createState() => _RefundSheetState();
}

class _RefundSheetState extends State<_RefundSheet> {
  final _reason = TextEditingController();
  bool _busy = false;
  Failure? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final f = await widget.onConfirm(_reason.text);
    if (!mounted) return;
    if (f == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _busy = false;
        _error = f;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final o = widget.group.order!;
    final used = widget.group.tickets.where((t) => t.status == TicketStatus.checkedIn).length;
    final amount = Fmt.money(o.total, freeWord: false);
    Widget row(String k, String v, {bool strong = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(k, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                v,
                textAlign: TextAlign.end,
                style: strong ? AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700) : AppText.label.copyWith(color: c.text),
              ),
            ),
          ]),
        );
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.refundTitle('${o.id}'), style: AppText.headerTitle.copyWith(color: c.text, fontSize: 20)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                row(l.buyer, o.attendeeName ?? '—'),
                row(l.positions, widget.group.itemsLine),
                row(l.toRefund, amount, strong: true),
              ]),
            ),
            const SizedBox(height: 12),
            Text(l.refundNote, style: AppText.meta.copyWith(color: c.textMuted)),
            if (used > 0) ...[
              const SizedBox(height: 10),
              InfoBanner(text: l.refundUsedWarning(used), tone: Tone.warning),
            ],
            const SizedBox(height: 16),
            LabeledTextField(
              label: l.reasonStar,
              controller: _reason,
              hintText: l.refundReasonHint,
              maxLines: 3,
              hasError: _error != null,
              onChanged: (_) => setState(() => _error = null),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              InfoBanner(text: _error!.text(context), tone: Tone.danger),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              label: l.refundConfirm(amount),
              tone: Tone.danger,
              isLoading: _busy,
              onPressed: _reason.text.trim().isEmpty ? null : _confirm,
            ),
            GhostButton(label: l.actionCancel, color: c.text, onPressed: _busy ? null : () => Navigator.of(context).pop(false)),
          ],
        ),
      ),
    );
  }
}

// ─── карточка заказа ───────────────────────────────────────────────────────

class ManageOrderViewModel extends Loadable<OrderGroup> {
  ManageOrderViewModel({
    required this.eventId,
    required this.orderId,
    required GetEventAttendees attendees,
    required this._refund,
  })  : super(() async {
          final r = await attendees(eventId);
          return r.fold(
            (rows) {
              final mine = rows.where((x) => x.order?.id == orderId).toList();
              if (mine.isEmpty) return const Err(ServerFailure('Order not found.', statusCode: 404, code: 'orderNotFound'));
              return Ok(OrderGroup(order: mine.first.order, tickets: [for (final x in mine) x.ticket]));
            },
            Err.new,
          );
        });

  final int eventId;
  final int orderId;
  final RefundOrder _refund;

  Future<Failure?> refund(String reason) => run(() => _refund(data!.order!, reason), reload: true);
}

/// Заказ: состав, билеты, возврат.
class ManageOrderPage extends StatelessWidget {
  const ManageOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<ManageOrderViewModel>();
    final g = vm.data;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              subtitle: l.orderTitle,
              title: g == null ? l.orderNo('${vm.orderId}') : (g.order!.attendeeName ?? l.orderNo('${g.order!.id}')),
              onBack: () => context.pop(),
            ),
            Expanded(
              child: LoadableView<OrderGroup>(
                state: vm,
                builder: (context, g) {
                  final o = g.order!;
                  final used = g.tickets.where((t) => t.status == TicketStatus.checkedIn).length;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
                    children: [
                      OrderCard(group: g),
                      const SizedBox(height: 16),
                      AppCard(
                        child: DetailGrid(rows: [
                          (l.statusLabel, o.status.text(l)),
                          if (o.attendeeEmail != null) (l.email, o.attendeeEmail!),
                          for (final i in o.items) ('${i.quantity} × ${i.ticketTypeName}', Fmt.money(i.subtotal)),
                          if (o.discount > 0) (l.discountCode(o.promoCode ?? ''), '− ${Fmt.money(o.discount, freeWord: false)}'),
                          (l.paidLabel, Fmt.money(o.total)),
                          if (o.createdAt != null) (l.placedLabel, Fmt.shortDateTime(o.createdAt!)),
                          (l.attCheckedIn, l.usedOfTotal('$used', '${g.tickets.length}')),
                        ]),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      SectionLabel(l.secTickets),
                      const SizedBox(height: 10),
                      for (final t in g.tickets) ...[
                        AppCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text([?t.ticketTypeName, ?t.seat].join(' · '), style: AppText.bodyStrong.copyWith(color: c.text)),
                                  Text(t.displayId, style: AppText.mono.copyWith(color: c.textMuted, fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ),
                            TagLabel(t.status.text(l), tone: t.status.tone),
                          ]),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  );
                },
              ),
            ),
            if (g != null && g.refundable)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 16),
                child: PrimaryButton(
                  label: l.refundMoney,
                  icon: LucideIcons.undo2,
                  tone: Tone.danger,
                  onPressed: () async {
                    final done = await showRefundSheet(context, g, vm.refund);
                    if (done && context.mounted) showMessage(context, l.refundedToast);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
