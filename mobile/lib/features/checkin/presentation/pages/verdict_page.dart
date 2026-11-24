import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../core/presentation/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../domain/entities/scan_result.dart';
import '../verdict_copy.dart';
import '../view_models/verdict_view_model.dart';
import '../widgets/reversal_sheet.dart';

/// A4.1–A4.7 · Результат проверки. Занимает весь экран, чтобы контролёр не
/// спутал прошлый билет с текущим. «Проходите» закрывается сам через 3 с.
class VerdictPage extends StatefulWidget {
  const VerdictPage({super.key, required this.result});

  final ScanResult result;

  static const autoClose = Duration(seconds: 3);

  @override
  State<VerdictPage> createState() => _VerdictPageState();
}

class _VerdictPageState extends State<VerdictPage> {
  Timer? _timer;
  int _left = VerdictPage.autoClose.inSeconds;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsController>().settings;
    final v = widget.result.verdict;
    if (s.soundOnResult) SystemSound.play(SystemSoundType.click);
    if (v.isRejection && s.vibrateOnReject) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    if (v == Verdict.valid) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _left--);
        if (_left <= 0) {
          t.cancel();
          Navigator.of(context).maybePop();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {});
  }

  Future<void> _undo(VerdictViewModel vm) async {
    _stopTimer();
    final r = vm.result;
    final session = context.read<SessionController>().session;
    final done = await showReversalSheet(
      context,
      attendeeName: r.ticket?.attendeeName ?? context.l10n.guest,
      ticketLabel: r.displayTicketId,
      checkedInAt: r.scannedAt,
      gate: context.read<SettingsController>().settings.gate,
      recordedBy: '${session?.shortName ?? ''} (${context.l10n.you})',
      onConfirm: vm.undo,
    );
    if (done && mounted) showMessage(context, context.l10n.reversedBody);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<VerdictViewModel>();
    final r = vm.result;
    final v = r.verdict;
    final fill = vm.isReversed ? const Color(0xFF5B3BE0) : VerdictCopy.fill(v);
    final t = r.ticket;

    final lines = <(String, bool)>[]; // (текст, крупно)
    if (vm.isReversed) {
      lines.add((t?.attendeeName ?? l.guest, true));
      lines.add((l.reversedBody, false));
    } else {
      switch (v) {
        case Verdict.valid:
          lines.add((t?.attendeeName ?? l.guest, true));
          final detail = [?t?.ticketType, ?t?.seat].join(' · ');
          lines.add((detail.isEmpty ? l.admission : detail, false));
        case Verdict.repeatScan:
          lines.add((t?.attendeeName ?? l.guest, true));
          final prev = r.previousScanAt ?? r.scannedAt;
          lines.add((l.repeatBody(r.scannedAt.difference(prev).inSeconds), false));
        case Verdict.alreadyUsed:
          if (t?.checkedInAt != null) lines.add((l.entryMarkedAt(Fmt.time(t!.checkedInAt!)), true));
          if (t?.checkedInBy != null) lines.add((l.scannedBy(t!.checkedInBy!), false));
          if (t?.attendeeName != null) lines.add(('${t!.attendeeName}${t.ticketType == null ? '' : ' · ${t.ticketType}'}', false));
        case Verdict.cancelled:
          lines.add(([?t?.attendeeName, ?t?.ticketType].join(' · '), true));
          lines.add((l.orderCancelledByOrganizer, false));
        case Verdict.refunded:
          lines.add(([?t?.attendeeName, ?t?.ticketType].join(' · '), true));
          lines.add((t?.refundedAt == null ? l.refundedNoEntry : l.refundedOn(Fmt.date(t!.refundedAt!)), false));
        case Verdict.unknownCode:
          lines.add((l.checkCodeOrFind, false));
        case Verdict.wrongEvent:
          lines.add((l.ticketIsFor, false));
          lines.add((t?.eventTitle ?? l.anotherEvent, true));
          if (t?.eventStartsAt != null) lines.add((Fmt.dateTime(t!.eventStartsAt!), false));
        case Verdict.campaignCode:
          final camp = r.campaign;
          if (camp?.campaignName != null) lines.add((l.campaignLabel(camp!.campaignName!), true));
          final code = [?camp?.promoCode, if (camp?.discount != null) '−${camp!.discount}'].join(' · ');
          if (code.isNotEmpty) lines.add((code, false));
          lines.add((l.promoNotTicket, false));
      }
    }

    final actions = <Widget>[
      if (v == Verdict.valid && _timer != null && !vm.isReversed) ...[
        Text(l.closesIn(_left), style: AppText.bodySecondary.copyWith(color: c.textMuted)),
        const SizedBox(height: 12),
      ],
      ResultPrimaryButton(label: l.actionNext, icon: LucideIcons.arrowRight, onPressed: () => context.pop()),
      if (v == Verdict.valid && !vm.isReversed) ...[
        const SizedBox(height: 12),
        SecondaryButton(label: l.undoEntry, icon: LucideIcons.undo2, onPressed: vm.canUndo ? () => _undo(vm) : null),
      ],
      if (v == Verdict.unknownCode) ...[
        const SizedBox(height: 12),
        SecondaryButton(label: l.findGuest, icon: LucideIcons.userSearch, onPressed: () => context.pushReplacement(Routes.search)),
      ],
      if (v == Verdict.wrongEvent && vm.switchTarget != null) ...[
        const SizedBox(height: 12),
        SecondaryButton(
          label: l.switchToEvent,
          onPressed: () {
            vm.switchToTicketEvent();
            context.pop();
          },
        ),
      ],
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 12),
              child: Row(children: [
                Icon(LucideIcons.calendar, size: 16, color: c.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(vm.event?.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: AppText.label.copyWith(color: c.textMuted)),
                ),
                Text(Fmt.timeWithSeconds(r.scannedAt), style: AppText.statusStrip.copyWith(color: c.textMuted)),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.side),
                child: GestureDetector(
                  onTap: _timer == null ? null : _stopTimer,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(AppRadius.result)),
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.45),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 148,
                              height: 148,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                              child: Icon(vm.isReversed ? LucideIcons.undo2 : VerdictCopy.icon(v), size: 88, color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              vm.isReversed ? l.reversedTitle : VerdictCopy.title(l, v),
                              textAlign: TextAlign.center,
                              style: AppText.resultTitle.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            for (final (text, big) in lines.where((x) => x.$1.isNotEmpty))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  style: big
                                      ? AppText.personName.copyWith(color: Colors.white)
                                      : AppText.body.copyWith(color: Colors.white.withValues(alpha: 0.92), fontSize: 17, fontWeight: FontWeight.w500),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.side, 16, AppSpacing.side, 16),
              child: Column(children: actions),
            ),
          ],
        ),
      ),
    );
  }
}
