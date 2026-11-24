import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
import '../domain/tickets_domain.dart';
import '../../../core/presentation/failure_text.dart';

class TicketViewModel extends Loadable<TicketInfo> {
  TicketViewModel({required this.ticketId, required GetTicket get, required this._files})
      : super(() => get(ticketId));

  final int ticketId;
  final GetTicketFile _files;

  Uint8List? qr;

  @override
  Future<void> load() async {
    await super.load();
    final r = await _files.qr(ticketId);
    if (r case Ok(:final value)) {
      qr = value;
      notifyListeners();
    }
  }

  Future<Result<Uint8List>> pdf() => _files.pdf(ticketId);
}

/// W7 · Ticket — крупный QR для входа, печать и PDF (§4.7, UC7).
class TicketPage extends StatelessWidget {
  const TicketPage({super.key});

  Future<void> _withPdf(BuildContext context, TicketViewModel vm, Future<void> Function(Uint8List) use) async {
    final r = await vm.pdf();
    if (!context.mounted) return;
    switch (r) {
      case Ok(:final value):
        await use(value);
      case Err(:final failure):
        showMessage(context, failure.text(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketViewModel>();
    const actions = DocumentActions();
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Admission ticket', subtitle: vm.data?.displayId, onBack: () => context.pop()),
            Expanded(
              child: LoadableView<TicketInfo>(
                state: vm,
                builder: (context, t) {
                  final usable = t.status == TicketStatus.valid;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 20, AppSpacing.sideLight, 24),
                    children: [
                      BlueprintFrame(
                        background: context.colors.surface,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BILETFLOW ADMISSION TICKET', style: AppText.fieldLabel.copyWith(color: context.colors.primary)),
                            const SizedBox(height: 8),
                            Text(t.eventTitle ?? 'Event', style: AppText.screenTitle.copyWith(color: context.colors.text)),
                            if (t.eventStartsAt != null)
                              Text(Fmt.dateTime(t.eventStartsAt!), style: AppText.meta.copyWith(color: context.colors.textMuted)),
                            if (t.eventVenue != null && t.eventVenue!.isNotEmpty)
                              Text(t.eventVenue!, style: AppText.meta.copyWith(color: context.colors.textMuted)),
                            const SizedBox(height: 18),
                            Center(
                              child: Opacity(
                                opacity: usable ? 1 : 0.25,
                                child: Container(
                                  width: 240,
                                  height: 240,
                                  color: context.colors.surface,
                                  alignment: Alignment.center,
                                  child: vm.qr == null
                                      ? const LoadingView()
                                      : Image.memory(vm.qr!, width: 240, height: 240, filterQuality: FilterQuality.none),
                                ),
                              ),
                            ),
                            if (!usable)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Center(
                                  child: TagLabel(t.status.label),
                                ),
                              ),
                            const SizedBox(height: 18),
                            Row(children: [
                              Text('ADMITS', style: AppText.fieldLabel.copyWith(color: context.colors.textMuted)),
                              const SizedBox(width: 8),
                              Text('1', style: AppText.statNumeral.copyWith(color: context.colors.text)),
                            ]),
                            const SizedBox(height: 10),
                            DetailGrid(rows: [
                              if (t.attendeeName != null) ('Attendee', t.attendeeName!),
                              if (t.ticketTypeName != null) ('Ticket type', t.ticketTypeName!),
                              if (t.seat != null) ('Section / Row / Seat', t.seat!),
                              ('Ticket ID', t.displayId),
                              if (t.orderId != null) ('Order', 'ORD-${t.orderId.toString().padLeft(4, '0')}'),
                              if (t.createdAt != null) ('Issued', Fmt.shortDateTime(t.createdAt!)),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Keep the QR clean and unfolded. This ticket admits one person once; the digital and '
                        'printed copies share one identifier.',
                        style: AppText.finePrint.copyWith(color: context.colors.textMuted),
                      ),
                      const SizedBox(height: AppSpacing.block),
                      PrimaryButton(
                        label: 'Print',
                        onPressed: () => _withPdf(context, vm, (b) => actions.printPdf(b, name: t.displayId)),
                      ),
                      const SizedBox(height: AppSpacing.actionGap),
                      SecondaryButton(
                        label: 'Download PDF',
                        onPressed: () => _withPdf(
                          context,
                          vm,
                          (b) => actions.share(b, name: '${t.displayId}.pdf', mimeType: 'application/pdf'),
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
