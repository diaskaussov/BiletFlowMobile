import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/field_painters.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../domain/entities/scan_result.dart';
import '../verdict_copy.dart';
import '../view_models/verdict_view_model.dart';
import '../widgets/reversal_sheet.dart';

/// B4–B10. Результат занимает весь экран и остаётся, пока администратор
/// не нажмёт «дальше», — чтобы не спутать прошлый билет с текущим.
class VerdictPage extends StatefulWidget {
  const VerdictPage({super.key, required this.result});

  final ScanResult result;

  @override
  State<VerdictPage> createState() => _VerdictPageState();
}

class _VerdictPageState extends State<VerdictPage> {
  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsController>().settings;
    if (s.soundOnResult) SystemSound.play(SystemSoundType.click);
    if (widget.result.verdict.isRejection && s.vibrateOnReject) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VerdictViewModel>();
    final r = vm.result;
    final v = r.verdict;
    final gate = context.watch<SettingsController>().settings.gate;
    final stats = vm.active.stats;
    const paper = AppPalette.onStrong;

    final strip = Row(
      children: [
        Expanded(
          child: Text(
            '${gate.toUpperCase()} · ${Fmt.timeWithSeconds(r.scannedAt)}',
            style: AppText.statusStrip.copyWith(color: paper),
          ),
        ),
        Text(
          v.admits
              ? (stats == null ? 'ADMITTED' : '${Fmt.count(stats.checkedIn)} / ${Fmt.count(stats.registered)} IN')
              : 'NOT ADMITTED',
          style: AppText.statusStrip.copyWith(color: paper),
        ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: VerdictCopy.field(v, context.colors),
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (v.isRejection && v != Verdict.campaignCode)
              const CustomPaint(painter: HatchPainter()),
            if (v == Verdict.campaignCode) const CustomPaint(painter: VerticalRulesPainter()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sideDark, 18, AppSpacing.sideDark, AppSpacing.bottomClearance,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    strip,
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: AppSpacing.statement, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _VerdictMark(verdict: v),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    vm.isReversed ? 'REVERSED' : VerdictCopy.word(v),
                                    style: VerdictCopy.wordStyle(v).copyWith(color: paper),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Divider(color: paper.withValues(alpha: 0.25)),
                            const SizedBox(height: 24),
                            ..._body(context, vm),
                          ],
                        ),
                      ),
                    ),
                    ..._actions(context, vm),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, VerdictViewModel vm) {
    final r = vm.result;
    final t = r.ticket;
    const paper = AppPalette.onStrong;
    final muted = paper.withValues(alpha: 0.72);
    final name = t?.attendeeName;

    Widget label(String s) => SectionLabel(s, color: muted);
    Widget person() => name == null
        ? const SizedBox.shrink()
        : Text(name, style: AppText.personName.copyWith(color: paper));
    Widget prose(String s) => Text(s, style: AppText.body.copyWith(color: paper));
    Widget fine(String s) => Text(s, style: AppText.finePrint.copyWith(color: muted));
    Widget grid(List<(String, String)> rows) => DetailGrid(rows: rows, color: paper);
    const gap = SizedBox(height: AppSpacing.block);

    switch (r.verdict) {
      case Verdict.valid:
        return [
          label(vm.isReversed ? 'Check-in reversed' : 'Checked in'),
          const SizedBox(height: 8),
          person(),
          const SizedBox(height: 4),
          Text(vm.isReversed ? 'Ticket is valid again' : '1 admission', style: AppText.meta.copyWith(color: muted)),
          gap,
          grid([
            if (t?.ticketType case final type?) ('Ticket type', type),
            if (t?.seat case final seat?) ('Seat', seat),
            ('Ticket ID', r.displayTicketId),
            if (t?.orderNumber case final order?) ('Order', order),
          ]),
          if (r.ticketId == null) ...[
            gap,
            fine('The server did not return a ticket ID, so this check-in can only be '
                'reversed from the organizer dashboard.'),
          ],
        ];

      case Verdict.alreadyUsed:
        final first = t?.checkedInAt;
        return [
          if (first != null) ...[
            label('First check-in'),
            const SizedBox(height: 6),
            Text(Fmt.time(first), style: AppText.listTitle.copyWith(color: paper)),
            Text(
              [if (t?.checkedInBy case final by?) 'by $by', Fmt.ago(first)].join(' · '),
              style: AppText.meta.copyWith(color: muted),
            ),
            gap,
          ],
          person(),
          const SizedBox(height: 12),
          grid([
            if (t?.ticketType case final type?) ('Ticket type', type),
            ('Ticket ID', r.displayTicketId),
            ('Status', 'Checked in'),
          ]),
          gap,
          prose('One ticket admits once, whether it was shown on paper or on a phone. '
              'If this is a genuine mistake, reverse the earlier check-in from the attendee record.'),
        ];

      case Verdict.repeatScan:
        final prev = r.previousScanAt ?? r.scannedAt;
        final seconds = r.scannedAt.difference(prev).inSeconds;
        return [
          prose('This is the ticket you scanned $seconds ${seconds == 1 ? 'second' : 'seconds'} ago. '
              'It is still one admission — no second check-in was recorded and nothing needs fixing.'),
          gap,
          person(),
          const SizedBox(height: 12),
          grid([
            ('Ticket ID', r.displayTicketId),
            ('Checked in', '${Fmt.timeWithSeconds(prev)} · this gate'),
            ('Admissions', '1'),
          ]),
        ];

      case Verdict.refunded || Verdict.cancelled:
        final refunded = r.verdict == Verdict.refunded;
        return [
          person(),
          const SizedBox(height: 12),
          grid([
            if (t?.ticketType case final type?) ('Ticket type', type),
            ('Ticket ID', r.displayTicketId),
            if (t?.refundedAt case final at?) (refunded ? 'Refunded' : 'Cancelled', Fmt.shortDateTime(at)),
            ('Status', 'Void — no admission'),
          ]),
          gap,
          prose(refunded
              ? 'The order was refunded, so this code cannot admit anyone. Direct the holder to the '
                  'organizer\'s desk or to support in the BiletFlow app; gate staff cannot reinstate a refunded ticket.'
              : 'The ticket was cancelled, so this code cannot admit anyone. Direct the holder to the '
                  'organizer\'s desk or to support in the BiletFlow app.'),
        ];

      case Verdict.unknownCode:
        return [
          prose('This QR does not belong to any BiletFlow ticket. It may be a different service\'s code, '
              'a screenshot of a cropped ticket, or a damaged print.'),
          gap,
          grid([
            ('Read at', Fmt.timeWithSeconds(r.scannedAt)),
            ('Payload', _preview(r.code)),
          ]),
          gap,
          label('Try this'),
          const SizedBox(height: 8),
          for (final step in const [
            '1 — Ask for the full ticket, not a crop.',
            '2 — Wipe the lens and re-scan.',
            '3 — Look the attendee up by name.',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(step, style: AppText.bodySecondary.copyWith(color: paper)),
            ),
          if (r.serverMessage case final m?) ...[gap, fine('Server: $m')],
        ];

      case Verdict.wrongEvent:
        final here = vm.event;
        return [
          prose('This is a real, valid ticket — for a different event. It cannot be admitted here.'),
          gap,
          label('Ticket is for'),
          const SizedBox(height: 6),
          Text(t?.eventTitle ?? 'Another event', style: AppText.listTitle.copyWith(color: paper)),
          if (_eventLine(t?.eventStartsAt, t?.eventVenue) case final line?)
            Text(line, style: AppText.meta.copyWith(color: muted)),
          gap,
          label('You are scanning for'),
          const SizedBox(height: 6),
          Text(here?.title ?? '—', style: AppText.listTitle.copyWith(color: paper)),
          if (_eventLine(here?.startsAt, here?.venueLine) case final line?)
            Text(line, style: AppText.meta.copyWith(color: muted)),
          if (vm.switchTarget != null) ...[
            gap,
            fine('You are assigned to both events. Switch events if the holder is genuinely at the right door.'),
          ],
          if (r.serverMessage case final m?) ...[gap, fine('Server: $m')],
        ];

      case Verdict.campaignCode:
        return [
          label('This is not an admission ticket'),
          const SizedBox(height: 10),
          prose('A campaign QR only opens the event page with a discount applied. '
              'It can never admit anyone, no matter how many times it is scanned.'),
          gap,
          grid([
            ('Campaign', r.campaign?.campaignName ?? r.campaign?.promoCode ?? '—'),
            if (r.campaign?.campaignName != null && r.campaign?.promoCode != null)
              ('Code', r.campaign!.promoCode!),
            if (r.campaign?.discount case final d?) ('Discount', d),
            ('Event', r.ticket?.eventTitle ?? vm.event?.title ?? '—'),
          ]),
          gap,
          prose('Ask the holder for the ticket they received by email or in their BiletFlow account, '
              'or look them up by name.'),
        ];
    }
  }

  List<Widget> _actions(BuildContext context, VerdictViewModel vm) {
    final r = vm.result;
    void next() => context.pop();
    void findByName([String? query]) {
      final q = query == null ? '' : '?q=${Uri.encodeQueryComponent(query)}';
      context.push('${Routes.search}$q');
    }

    final (String primary, (String, VoidCallback?)? secondary) = switch (r.verdict) {
      Verdict.valid => (
          'Scan next ticket',
          vm.isReversed ? null : ('Undo this check-in', vm.canUndo ? () => _undo(context, vm) : null),
        ),
      Verdict.alreadyUsed => (
          'Scan next ticket',
          ('Open attendee record', () => findByName(r.ticket?.attendeeName ?? r.ticket?.ticketId)),
        ),
      Verdict.repeatScan => ('Continue scanning', null),
      Verdict.refunded || Verdict.cancelled => (
          'Scan next ticket',
          ('Copy ticket ID', () => _copy(context, r.displayTicketId)),
        ),
      Verdict.unknownCode => ('Scan again', ('Find by name', () => findByName())),
      Verdict.wrongEvent => (
          'Scan next ticket',
          vm.switchTarget != null
              ? ('Switch to that event', () {
                  vm.switchToTicketEvent();
                  context.pop();
                })
              : ('Find by name', () => findByName()),
        ),
      Verdict.campaignCode => ('Scan the real ticket', ('Find by name', () => findByName())),
    };

    return [
      ResultPrimaryButton(label: primary, onPressed: next, textColor: VerdictCopy.field(r.verdict, context.colors)),
      if (secondary != null) ...[
        const SizedBox(height: AppSpacing.actionGap),
        SecondaryButton(label: secondary.$1, onDark: true, onPressed: secondary.$2),
      ],
    ];
  }

  Future<void> _undo(BuildContext context, VerdictViewModel vm) async {
    final r = vm.result;
    final session = context.read<SessionController>().session;
    final gate = context.read<SettingsController>().settings.gate;
    final done = await showReversalSheet(
      context,
      attendeeName: r.ticket?.attendeeName ?? 'this ticket',
      ticketLabel: r.displayTicketId,
      checkedInAt: r.scannedAt,
      gate: gate,
      recordedBy: '${session?.shortName ?? 'You'} (you)',
      onConfirm: vm.undo,
    );
    if (done && context.mounted) showMessage(context, 'Check-in reversed. The ticket is valid again.');
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    showMessage(context, 'Ticket ID copied.');
  }

  static String _preview(String code) {
    final oneLine = code.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (oneLine.isEmpty) return 'empty';
    return oneLine.length <= 28 ? oneLine : '${oneLine.substring(0, 27)}…';
  }

  static String? _eventLine(DateTime? at, String? venue) {
    final parts = [
      if (at != null) Fmt.relativeDay(at),
      if (venue != null && venue.isNotEmpty) venue,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

/// Знак вердикта: квадрат 54 pt, рамка 2 pt (пунктир у повтора).
class _VerdictMark extends StatelessWidget {
  const _VerdictMark({required this.verdict});

  final Verdict verdict;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      VerdictCopy.icon(verdict),
      size: VerdictCopy.iconSize(verdict),
      color: AppPalette.onStrong,
    );
    if (verdict == Verdict.repeatScan) {
      return SizedBox.square(
        dimension: AppSizes.verdictMark,
        child: CustomPaint(
          painter: const DashedBorderPainter(color: AppPalette.onStrong),
          child: Center(child: icon),
        ),
      );
    }
    return Container(
      width: AppSizes.verdictMark,
      height: AppSizes.verdictMark,
      decoration: BoxDecoration(border: Border.all(color: AppPalette.onStrong, width: 2)),
      child: Center(child: icon),
    );
  }
}
