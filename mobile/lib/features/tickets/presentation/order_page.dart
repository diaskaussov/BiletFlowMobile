import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/platform/document_actions.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/presentation/status_text.dart';
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
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.cancelOrderTitle),
        content: Text(l.cancelOrderBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.actionKeep)),
          TextButton(onPressed: () => Navigator.pop(d, true), child: Text(l.cancelOrder, style: TextStyle(color: d.colors.danger))),
        ],
      ),
    );
    if (ok != true) return;
    final f = await vm.cancel();
    if (context.mounted) reportResult(context, f, success: l.orderCancelledToast);
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
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<OrderViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              subtitle: vm.data?.order.eventTitle,
              title: vm.data == null ? l.orderTitle : l.orderNo('${vm.data!.order.id}'),
              onBack: () => context.canPop() ? context.pop() : context.go(Routes.myTickets),
            ),
            Expanded(
              child: LoadableView<OrderDetails>(
                state: vm,
                builder: (context, d) {
                  final o = d.order;
                  final issued = d.tickets.length;
                  final done = o.status == OrderStatus.completed;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
                    children: [
                      AppCard(
                        color: done ? c.successSoft : null,
                        borderColor: done ? Colors.transparent : null,
                        child: Row(children: [
                          Icon(done ? LucideIcons.circleCheckBig : LucideIcons.receipt, size: 28, color: done ? c.successText : c.textMuted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  done ? (issued == 1 ? l.ticketReady : l.ticketsReady(issued)) : o.status.text(l),
                                  style: AppText.headerTitle.copyWith(color: done ? c.successText : c.text),
                                ),
                                if (o.attendeeEmail != null)
                                  Text(l.confirmationSent(o.attendeeEmail!), style: AppText.meta.copyWith(color: done ? c.successText : c.textMuted)),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(label: l.addToCalendar, icon: LucideIcons.calendarPlus, compact: true, onPressed: () => _calendar(context, vm)),
                      const SizedBox(height: AppSpacing.section),
                      SectionLabel(l.yourTickets),
                      const SizedBox(height: 10),
                      if (d.tickets.isEmpty) Text(l.ticketsAfterPayment, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
                      for (final t in d.tickets) ...[
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(t.attendeeName ?? o.attendeeName ?? l.attendeeLabel,
                                      style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                                ),
                                Builder(builder: (_) {
                                  final (text, tone) = t.badge(l, DateTime.now());
                                  return TagLabel(text, tone: tone);
                                }),
                              ]),
                              const SizedBox(height: 4),
                              Text([?t.ticketTypeName, ?t.seat, t.displayId].join(' · '), style: AppText.meta.copyWith(color: c.textMuted)),
                              const SizedBox(height: 12),
                              Row(children: [
                                Expanded(
                                  child: PrimaryButton(label: l.showQr, icon: LucideIcons.qrCode, onPressed: () => context.push(Routes.ticket(t.id))),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 100,
                                  child: SecondaryButton(label: 'PDF', icon: LucideIcons.download, onPressed: () => _sharePdf(context, vm, t)),
                                ),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(l.showQrNote, style: AppText.finePrint.copyWith(color: c.textMuted)),
                      const SizedBox(height: AppSpacing.section),
                      SectionLabel(l.orderTitle),
                      const SizedBox(height: 10),
                      AppCard(
                        child: DetailGrid(rows: [
                          (l.statusLabel, o.status.text(l)),
                          for (final i in o.items) ('${i.quantity} × ${i.ticketTypeName}', Fmt.money(i.subtotal)),
                          if (o.discount > 0) (l.discountCode(o.promoCode ?? ''), '− ${Fmt.money(o.discount, freeWord: false)}'),
                          (l.totalLabel, Fmt.money(o.total)),
                          if (o.total > 0) (l.methodLabel, l.sandboxPayment),
                          if (o.createdAt != null) (l.placedLabel, Fmt.shortDateTime(o.createdAt!)),
                        ]),
                      ),
                      const SizedBox(height: AppSpacing.block),
                      GhostButton(
                        label: l.helpWithOrder,
                        icon: LucideIcons.lifeBuoy,
                        onPressed: () => context.push(
                          '${Routes.newSupportCase(Routes.attendeeSupport)}?orderId=${o.id}'
                          '${o.eventId == null ? '' : '&eventId=${o.eventId}'}'
                          '&about=${Uri.encodeQueryComponent(l.orderNo('${o.id}'))}',
                        ),
                      ),
                      if (o.status == OrderStatus.completed || o.status == OrderStatus.pending)
                        GhostButton(label: l.cancelOrder, color: c.danger, onPressed: vm.isBusy ? null : () => _cancel(context, vm)),
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
