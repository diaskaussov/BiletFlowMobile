import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
import '../../../core/widgets/commerce_widgets.dart';
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

/// W7 · Билет — крупный QR для входа, печать и PDF (§4.7, UC7).
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
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<TicketViewModel>();
    const actions = DocumentActions();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(subtitle: vm.data?.displayId, title: l.admissionTicket, onBack: () => context.pop()),
            Expanded(
              child: LoadableView<TicketInfo>(
                state: vm,
                builder: (context, t) {
                  final expired = t.isExpired(DateTime.now());
                  final usable = t.status == TicketStatus.valid && !expired;
                  final (badgeText, badgeTone) = t.badge(l, DateTime.now());
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
                    children: [
                      Container(
                        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(AppRadius.panel), border: Border.all(color: c.border)),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                              decoration: BoxDecoration(
                                gradient: coverGradient(t.eventTitle ?? ''),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.panel)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.eventTitle ?? l.eventFallback, style: AppText.headerTitle.copyWith(color: Colors.white, fontSize: 20)),
                                  if (t.eventStartsAt != null)
                                    Text(Fmt.dateTime(t.eventStartsAt!), style: AppText.meta.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                                  if ((t.eventVenue ?? '').isNotEmpty)
                                    Text(t.eventVenue!, style: AppText.meta.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Opacity(
                                    opacity: usable ? 1 : 0.25,
                                    child: Container(
                                      width: 240,
                                      height: 240,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                      alignment: Alignment.center,
                                      child: vm.qr == null
                                          ? const LoadingView()
                                          : Image.memory(vm.qr!, filterQuality: FilterQuality.none),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TagLabel(usable ? l.admitsOne : badgeText, tone: usable ? Tone.success : badgeTone),
                                  const SizedBox(height: 16),
                                  DetailGrid(rows: [
                                    if (t.attendeeName != null) (l.attendeeLabel, t.attendeeName!),
                                    if (t.ticketTypeName != null) (l.ticketTypeLabel, t.ticketTypeName!),
                                    if (t.seat != null) (l.seatLabelShort, t.seat!),
                                    (l.ticketIdLabel, t.displayId),
                                    if (t.orderId != null) (l.orderTitle, l.orderNo('${t.orderId}')),
                                    if (t.createdAt != null) (l.issuedLabel, Fmt.shortDateTime(t.createdAt!)),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(l.qrKeepNote, textAlign: TextAlign.center, style: AppText.finePrint.copyWith(color: c.textMuted)),
                      const SizedBox(height: AppSpacing.block),
                      Row(children: [
                        Expanded(
                          child: SecondaryButton(
                            label: l.print,
                            icon: LucideIcons.printer,
                            onPressed: () => _withPdf(context, vm, (b) => actions.printPdf(b, name: t.displayId)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SecondaryButton(
                            label: 'PDF',
                            icon: LucideIcons.download,
                            onPressed: () => _withPdf(context, vm, (b) => actions.share(b, name: '${t.displayId}.pdf', mimeType: 'application/pdf')),
                          ),
                        ),
                      ]),
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
