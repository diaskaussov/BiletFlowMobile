import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/platform/document_actions.dart';
import '../../../core/presentation/loadable.dart';
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
import '../domain/organizer_operations_domain.dart';

// ─── O5 attendees ──────────────────────────────────────────────────────────

class EventAttendeesViewModel extends Loadable<List<AttendeeRow>> {
  EventAttendeesViewModel({required this.eventId, required GetEventAttendees get}) : super(() => get(eventId));

  final int eventId;
  AttendeeFilter filter = AttendeeFilter.all;
  String query = '';

  List<AttendeeRow> get visible => filterAttendees(data ?? const [], filter, query);

  int count(AttendeeFilter f) => filterAttendees(data ?? const [], f, '').length;

  void setFilter(AttendeeFilter f) {
    filter = f;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }
}

String _filterLabel(AttendeeFilter f) => switch (f) {
      AttendeeFilter.all => 'All',
      AttendeeFilter.checkedIn => 'Checked in',
      AttendeeFilter.notArrived => 'Not arrived',
      AttendeeFilter.refunded => 'Refunded',
      AttendeeFilter.campaign => 'Campaign orders',
    };

/// O5 · Attendees & orders (§4.9)
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventAttendeesViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Attendees',
              subtitle: vm.data == null ? null : '${vm.data!.length} tickets',
              onBack: () => context.pop(),
              trailing: IconButton(
                tooltip: 'Export CSV',
                onPressed: vm.data == null
                    ? null
                    : () => const DocumentActions().share(
                          utf8.encode(attendeesCsv(vm.visible)),
                          name: 'attendees-event-${vm.eventId}.csv',
                          mimeType: 'text/csv',
                        ),
                icon: const Icon(Icons.ios_share, size: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 14, AppSpacing.sideList, 0),
              child: LabeledTextField(
                controller: _search,
                leadingIcon: Icons.search,
                hintText: 'Name, email or ticket ID',
                onChanged: vm.setQuery,
              ),
            ),
            if (vm.data != null)
              UnderlineTabs(
                labels: [for (final f in AttendeeFilter.values) '${_filterLabel(f)} · ${vm.count(f)}'],
                current: AttendeeFilter.values.indexOf(vm.filter),
                onSelect: (i) => vm.setFilter(AttendeeFilter.values[i]),
              ),
            Expanded(
              child: LoadableView<List<AttendeeRow>>(
                state: vm,
                builder: (context, _) {
                  final rows = vm.visible;
                  if (rows.isEmpty) {
                    return ListView(children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.sideList),
                        child: Text('No attendees match.', style: AppText.bodySecondary.copyWith(color: context.colors.textMuted)),
                      ),
                    ]);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideList),
                    itemCount: rows.length,
                    itemBuilder: (context, i) {
                      final r = rows[i];
                      final t = r.ticket;
                      return ListRow(
                        title: t.attendeeName ?? 'Attendee',
                        subtitle: [
                          ?t.attendeeEmail,
                          [?t.ticketTypeName, ?t.seat, t.displayId].join(' · '),
                          if (r.order != null) '${r.order!.number}${r.order!.promoCode == null ? '' : ' · ${r.order!.promoCode}'}',
                        ].join('\n'),
                        trailing: TagLabel(t.status.label, filled: t.status == TicketStatus.valid),
                        onTap: r.order == null ? null : () => context.push(Routes.eventOrder(vm.eventId, r.order!.id), extra: r.order),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── O6 order & refund ─────────────────────────────────────────────────────

class ManagedOrder {
  const ManagedOrder({required this.order, required this.tickets});

  final OrderInfo order;
  final List<TicketInfo> tickets;
}

class ManageOrderViewModel extends Loadable<ManagedOrder> {
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
              if (mine.isEmpty) return const Err(ServerFailure('Order not found.', statusCode: 404));
              return Ok(ManagedOrder(order: mine.first.order!, tickets: [for (final x in mine) x.ticket]));
            },
            Err.new,
          );
        });

  final int eventId;
  final int orderId;
  final RefundOrder _refund;

  Future<Failure?> refund(String reason) => run(() => _refund(data!.order, reason), reload: true);
}

/// O6 · Refund an order (§4.9, UC5)
class ManageOrderPage extends StatefulWidget {
  const ManageOrderPage({super.key});

  @override
  State<ManageOrderPage> createState() => _ManageOrderPageState();
}

class _ManageOrderPageState extends State<ManageOrderPage> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManageOrderViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: vm.data?.order.number ?? 'Order', subtitle: vm.data?.order.attendeeName, onBack: () => context.pop()),
            Expanded(
              child: LoadableView<ManagedOrder>(
                state: vm,
                builder: (context, d) {
                  final o = d.order;
                  final used = d.tickets.where((t) => t.status == TicketStatus.checkedIn).length;
                  final refundable = o.status == OrderStatus.completed || o.status == OrderStatus.pending;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 18, AppSpacing.sideLight, 24),
                    children: [
                      DetailGrid(rows: [
                        ('Status', o.status.label),
                        ('Attendee', o.attendeeName ?? '—'),
                        if (o.attendeeEmail != null) ('Email', o.attendeeEmail!),
                        for (final i in o.items) ('${i.quantity} × ${i.ticketTypeName}', Fmt.money(i.subtotal)),
                        if (o.discount > 0) ('Discount ${o.promoCode ?? ''}', '− ${Fmt.money(o.discount, freeWord: false)}'),
                        ('Paid', '${Fmt.money(o.total)} · sandbox'),
                        if (o.createdAt != null) ('Placed', Fmt.shortDateTime(o.createdAt!)),
                        ('Checked in', '$used of ${d.tickets.length} tickets'),
                      ]),
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('Tickets'),
                      for (final t in d.tickets)
                        ListRow(
                          title: t.displayId,
                          subtitle: [?t.ticketTypeName, ?t.seat].join(' · '),
                          trailing: TagLabel(t.status.label),
                        ),
                      if (refundable) ...[
                        const SizedBox(height: AppSpacing.section),
                        SectionLabel('Confirm full refund', color: context.colors.primary),
                        const SizedBox(height: 8),
                        Text(
                          'All tickets become invalid immediately and will be refused at the gate. Seats return '
                          'to the map. The attendee is emailed automatically.',
                          style: AppText.bodySecondary.copyWith(color: context.colors.textMuted),
                        ),
                        if (used > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            '$used ticket${used == 1 ? ' was' : 's were'} already checked in. Refunding does not undo the '
                            'admission — reverse the check-in first if that was a mistake.',
                            style: AppText.bodySecondary.copyWith(color: context.colors.text),
                          ),
                        ],
                        const SizedBox(height: 12),
                        LabeledTextField(
                          label: 'Reason recorded in the audit log',
                          controller: _reason,
                          hintText: 'Attendee could not attend — requested by email',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        const DemoNotice(text: 'The refund runs through the payment sandbox. No money moves.'),
                      ],
                    ],
                  );
                },
              ),
            ),
            if (vm.data != null &&
                (vm.data!.order.status == OrderStatus.completed || vm.data!.order.status == OrderStatus.pending))
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
                child: PrimaryButton(
                  label: 'Refund ${Fmt.money(vm.data!.order.total, freeWord: false)}',
                  isLoading: vm.isBusy,
                  onPressed: () async {
                    final f = await vm.refund(_reason.text);
                    if (context.mounted) reportResult(context, f, success: 'Order refunded.');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
