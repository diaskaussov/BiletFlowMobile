import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../app/main_tab_bar.dart';
import '../../../../app/routes.dart';
import '../../../../core/presentation/failure_text.dart';
import '../../../../core/presentation/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/floating_nav_bar.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/event_stats.dart';
import '../view_models/event_summary_view_model.dart';

/// A8 · Статистика входа по событию — данные сервера `/checkin/stats`.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<EventSummaryViewModel>();
    final s = vm.stats;

    Widget body;
    if (s == null && vm.isLoading) {
      body = const LoadingView();
    } else if (s == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.side),
          child: MessageView(
            icon: LucideIcons.chartPie,
            title: l.statsUnavailable,
            message: vm.failure?.text(context) ?? '',
            actionLabel: l.tryAgain,
            onAction: vm.load,
          ),
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.side, 12, AppSpacing.side, 24),
          children: [
            AppCard(
              radius: 20,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 132,
                    child: CustomPaint(
                      painter: _RingPainter(value: s.ratio, track: c.border, fill: c.primary),
                      child: Center(
                        child: Text(Fmt.percent(s.checkedIn, s.registered), style: AppText.statNumeral.copyWith(color: c.text)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.entered, style: AppText.label.copyWith(color: c.textMuted)),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text('${Fmt.count(s.checkedIn)} / ${Fmt.count(s.registered)}',
                              style: AppText.heroMetric.copyWith(color: c.text, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 4),
                        Text(l.stillToCome(s.notCheckedIn), style: AppText.meta.copyWith(color: c.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Tiles(stats: s),
            if (s.byTicketType.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.section),
              SectionLabel(l.byTicketType),
              const SizedBox(height: 4),
              for (final t in s.byTicketType)
                ShareRow(label: t.name, value: '${t.checkedIn} / ${t.registered}', ratio: t.ratio, color: c.success),
            ],
            const SizedBox(height: AppSpacing.section),
            SectionLabel(l.recentEntries),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: s.recent.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(l.noEntriesYet, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
                    )
                  : Column(
                      children: [
                        for (final (i, r) in s.recent.indexed)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: i == s.recent.length - 1 ? null : Border(bottom: BorderSide(color: c.border)),
                            ),
                            child: Row(
                              children: [
                                InitialAvatar(r.attendeeName, size: 36),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.attendeeName, style: AppText.cardTitle.copyWith(color: c.text, fontWeight: FontWeight.w600)),
                                      Text([?r.ticketType, ?r.checkedInBy].join(' · '), style: AppText.finePrint.copyWith(color: c.textMuted)),
                                    ],
                                  ),
                                ),
                                if (r.at != null) Text(Fmt.time(r.at!), style: AppText.statusStrip.copyWith(color: c.textMuted)),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LargeHeader(
              title: l.navStats,
              context_: vm.event?.title,
              onContextTap: () => context.go(Routes.events),
              action: CircleIconButton(icon: LucideIcons.refreshCw, tooltip: l.actionRetry, onPressed: vm.load),
            ),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: const ScannerTabBar(current: ScannerTab.stats),
    );
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles({required this.stats});

  final EventStats stats;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    Widget tile(int value, String label, [Color? color]) => Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Fmt.count(value), style: AppText.screenTitle.copyWith(color: color ?? c.text, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(label, style: AppText.meta.copyWith(color: c.textMuted, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
    return Column(
      children: [
        Row(children: [tile(stats.registered, l.registered), const SizedBox(width: 10), tile(stats.checkedIn, l.entered, c.successText)]),
        const SizedBox(height: 10),
        Row(children: [tile(stats.notCheckedIn, l.notArrived), const SizedBox(width: 10), tile(stats.cancelled, l.cancelledStat, c.dangerText)]),
        const SizedBox(height: 10),
        Row(children: [tile(stats.refunded, l.refundedStat), const SizedBox(width: 10), tile(stats.reversed, l.reversals)]),
      ],
    );
  }
}

/// Кольцо прогресса входа (A8 «Ring»).
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.value, required this.track, required this.fill});

  final double value;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Offset.zero & size;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(stroke / 2), 0, math.pi * 2, false, p..color = track);
    if (value > 0) {
      canvas.drawArc(rect.deflate(stroke / 2), -math.pi / 2, math.pi * 2 * value.clamp(0, 1), false, p..color = fill);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.fill != fill || old.track != track;
}
