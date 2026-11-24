import 'dart:typed_data';

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
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../../catalog/domain/catalog_domain.dart';
import '../../catalog/presentation/calendar_sheet.dart';
import '../domain/tickets_domain.dart';
import '../../../core/presentation/failure_text.dart';

class OrderViewModel extends Loadable<OrderDetails> {
  OrderViewModel({
    required this.orderId,
    required GetOrderDetails get,
    required this._cancel,
    required this._files,
    required this._event,
  })  : super(() => get(orderId));

  final int orderId;
  final CancelOrder _cancel;
  final GetTicketFile _files;
  final GetEvent _event;

  Future<Failure?> cancel() {
    final d = data;
    if (d == null) return Future.value(null);
    return run(() => _cancel(d), reload: true);
  }

  Future<Result<Uint8List>> pdf(int ticketId) => _files.pdf(ticketId);

  Future<Result<Uint8List>> calendar() => _event.calendar(data?.order.eventId ?? 0);

  Future<Result<EventInfo>> event() {
    final id = data?.order.eventId;
    if (id == null) return Future.value(const Err(ValidationFailure('This order has no event.', code: 'orderNoEvent')));
    return _event(id);
  }
}

/// W6 · Order confirmed — tickets issued
class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  Future<void> _sharePdf(BuildContext context, OrderViewModel vm, TicketInfo t) async {
    final r = await vm.pdf(t.id);
    if (!context.mounted) return;
    switch (r) {
      case Ok(:final value):
        await const DocumentActions().share(value, name: '${t.displayId}.pdf', mimeType: 'application/pdf');
      case Err(:final failure):
        showMessage(context, failure.text(context));
    }
  }

  Future<void> _cancel(BuildContext context, OrderViewModel vm) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Cancel this order?', style: AppText.headerTitle.copyWith(color: context.colors.text)),
        content: Text(
          'All tickets in the order become invalid and will be refused at the gate. '
          'Refunds follow the organizer\'s policy.',
          style: AppText.body.copyWith(color: context.colors.textMuted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('KEEP')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('CANCEL ORDER')),
        ],
      ),
    );
    if (ok != true) return;
    final f = await vm.cancel();
    if (context.mounted) reportResult(context, f, success: 'Order cancelled.');
  }

  Future<void> _calendar(BuildContext context, OrderViewModel vm) async {
    final r = await vm.event();
    if (!context.mounted) return;
    switch (r) {
      case Ok(:final value):
        await showCalendarSheet(context, event: value, icsFile: vm.calendar);
      case Err(:final failure):
        showMessage(context, failure.text(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: vm.data?.order.number ?? 'Order',
              subtitle: vm.data?.order.eventTitle,
              onBack: () => context.canPop() ? context.pop() : context.go(Routes.myTickets),
            ),
            Expanded(
              child: LoadableView<OrderDetails>(
                state: vm,
                builder: (context, d) {
                  final o = d.order;
                  final issued = d.tickets.length;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 22, AppSpacing.sideLight, 24),
                    children: [
                      Text(
                        o.status == OrderStatus.completed
                            ? (issued == 1 ? 'Your ticket is ready' : '$issued tickets are yours')
                            : o.status.label,
                        style: AppText.screenTitle.copyWith(color: context.colors.text),
                      ),
                      if (o.attendeeEmail != null)
                        Text('Confirmation sent to ${o.attendeeEmail}', style: AppText.meta.copyWith(color: context.colors.textMuted)),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: SecondaryButton(
                            label: 'Add to calendar',
                            onPressed: () => _calendar(context, vm),
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('Your tickets'),
                      const SizedBox(height: 8),
                      if (d.tickets.isEmpty)
                        Text('Tickets are issued after payment is confirmed.',
                            style: AppText.bodySecondary.copyWith(color: context.colors.textMuted)),
                      for (final t in d.tickets)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: context.colors.surface, border: Border.all(color: context.colors.border)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(t.attendeeName ?? o.attendeeName ?? 'Attendee',
                                      style: AppText.listTitle.copyWith(color: context.colors.text)),
                                ),
                                TagLabel(t.status.label, filled: t.status == TicketStatus.valid),
                              ]),
                              const SizedBox(height: 8),
                              DetailGrid(rows: [
                                if (t.ticketTypeName != null) ('Type', t.ticketTypeName!),
                                if (t.seat != null) ('Seat', t.seat!),
                                ('Ticket ID', t.displayId),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                Expanded(child: SecondaryButton(label: 'Show QR', onPressed: () => context.push(Routes.ticket(t.id)))),
                                const SizedBox(width: 10),
                                Expanded(child: SecondaryButton(label: 'PDF', onPressed: () => _sharePdf(context, vm, t))),
                              ]),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Show the QR on your phone or on paper. Each ticket admits one person once — '
                        'a printed copy and the screen copy are the same ticket, not two.',
                        style: AppText.finePrint.copyWith(color: context.colors.textMuted),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('Order'),
                      const SizedBox(height: 8),
                      DetailGrid(rows: [
                        ('Status', o.status.label),
                        for (final i in o.items)
                          ('${i.quantity} × ${i.ticketTypeName}', Fmt.money(i.subtotal)),
                        if (o.discount > 0) ('Discount${o.promoCode == null ? '' : ' ${o.promoCode}'}', '− ${Fmt.money(o.discount, freeWord: false)}'),
                        ('Total', Fmt.money(o.total)),
                        if (o.total > 0) ('Method', 'Sandbox payment'),
                        if (o.createdAt != null) ('Placed', Fmt.shortDateTime(o.createdAt!)),
                      ]),
                      const SizedBox(height: AppSpacing.block),
                      if (o.status == OrderStatus.completed || o.status == OrderStatus.pending)
                        GhostButton(label: 'Cancel order', onPressed: vm.isBusy ? null : () => _cancel(context, vm)),
                      GhostButton(
                        label: 'Get help with this order',
                        onPressed: () => context.push(
                          '${Routes.newSupportCase(Routes.attendeeSupport)}?orderId=${o.id}'
                          '${o.eventId == null ? '' : '&eventId=${o.eventId}'}'
                          '&about=${Uri.encodeQueryComponent(o.number)}',
                        ),
                      ),
                    ],
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
