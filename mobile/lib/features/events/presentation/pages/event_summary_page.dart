import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../checkin/domain/entities/scan_log.dart';
import '../../../checkin/presentation/verdict_copy.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../view_models/event_summary_view_model.dart';

/// A4 · Event summary (§4.8 counts)
class EventSummaryPage extends StatelessWidget {
  const EventSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventSummaryViewModel>();
    final gate = context.watch<SettingsController>().settings.gate;
    final event = vm.event;
    final stats = vm.stats;
    final log = vm.log;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: event?.title ?? 'Event',
              subtitle: '$gate · Summary',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: vm.load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 30, AppSpacing.sideLight, 24),
                  children: [
                    if (vm.isLoading && stats == null)
                      const SizedBox(height: 120, child: LoadingView())
                    else if (stats == null)
                      Text(
                        vm.failure?.message ?? 'Counts are unavailable.',
                        style: AppText.body.copyWith(color: AppColors.neutral700),
                      )
                    else ...[
                      Text(Fmt.count(stats.checkedIn), style: AppText.heroMetric.copyWith(color: AppColors.ink)),
                      const SizedBox(height: 8),
                      Text(
                        'of ${Fmt.count(stats.registered)} issued · ${Fmt.percent(stats.checkedIn, stats.registered)}',
                        style: AppText.bodySecondary.copyWith(color: AppColors.neutral700),
                      ),
                      const SizedBox(height: 14),
                      ProgressStrip(value: stats.ratio),
                      const SizedBox(height: AppSpacing.block),
                      StatQuad(cells: [
                        (Fmt.count(stats.notCheckedIn), 'Not arrived'),
                        (Fmt.count(log.rejected), 'Rejected scans'),
                        (Fmt.count(log.reversed), 'Reversed'),
                        (Fmt.count(log.voided), 'Refunded / void'),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                        'Rejected, reversed and void counts come from this device\'s shift.',
                        style: AppText.finePrint.copyWith(color: AppColors.neutral600),
                      ),
                    ],
                    if (log.admittedByType.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('Admitted here · by ticket type'),
                      const SizedBox(height: 4),
                      for (final MapEntry(:key, :value) in log.admittedByType.entries)
                        ValueRow(label: key, value: Fmt.count(value)),
                    ],
                    const SizedBox(height: AppSpacing.section),
                    const SectionLabel('Recent'),
                    const SizedBox(height: 4),
                    if (log.recent.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No scans on this device yet.',
                          style: AppText.bodySecondary.copyWith(color: AppColors.neutral600),
                        ),
                      )
                    else
                      for (final e in log.recent) _RecentRow(entry: e),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
              child: PrimaryButton(
                label: 'Open scanner',
                onPressed: event == null
                    ? null
                    : () {
                        vm.selectForScanning();
                        context.push(Routes.scanner);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.entry});

  final ScanLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(Fmt.time(entry.at), style: AppText.detail.copyWith(color: AppColors.neutral600)),
          ),
          Expanded(
            child: Text(
              VerdictCopy.logLine(entry),
              style: AppText.bodySecondary.copyWith(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
