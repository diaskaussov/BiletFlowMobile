import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../events/presentation/controllers/active_event_controller.dart';
import 'connection_controller.dart';

/// A5 · Offline — проверка блокируется, а не копится в очередь.
class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  Future<void> _retry(BuildContext context) async {
    final ok = await context.read<ConnectionController>().retry();
    if (!context.mounted) return;
    if (ok) {
      showMessage(context, 'Connection restored. Scanning resumed.');
      context.pop();
    } else {
      showMessage(context, 'Still no connection to the server.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ConnectionController>();
    final hasEvent = context.watch<ActiveEventController>().event != null;
    final last = c.lastSyncAt;
    final online = c.isOnline;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Connection', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 26, AppSpacing.sideLight, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    color: online ? AppColors.accent100 : AppColors.neutral900,
                    child: Row(
                      children: [
                        Icon(
                          online ? Icons.wifi : Icons.wifi_off,
                          size: 18,
                          color: online ? AppColors.accent800 : AppColors.paper,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            online ? 'CONNECTED — SCANNING AVAILABLE' : 'NO CONNECTION — SCANNING PAUSED',
                            style: AppText.statusStrip.copyWith(
                              color: online ? AppColors.accent800 : AppColors.paper,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Tickets are verified on the server, so scanning stays paused until the device '
                    'reconnects. Nothing scanned during an outage is stored on the phone.',
                    style: AppText.body.copyWith(color: AppColors.neutral700),
                  ),
                  const SizedBox(height: AppSpacing.block),
                  ValueRow(
                    label: 'Last sync',
                    value: last == null
                        ? 'Never'
                        : '${Fmt.timeWithSeconds(last)} · ${Fmt.ago(last)}',
                  ),
                  const ValueRow(label: 'Check-ins pending', value: '0'),
                  ValueRow(label: 'Device network', value: c.hasNetwork ? 'Available' : 'Off'),
                  ValueRow(label: 'Server', value: c.serverReachable ? 'Reachable' : 'Unreachable'),
                  const SizedBox(height: AppSpacing.section),
                  const SectionLabel('What staff should do'),
                  const SizedBox(height: 8),
                  Text(
                    'Hold the queue or record names manually and re-scan once the connection '
                    'returns. Offline check-in is deferred past this release.',
                    style: AppText.bodySecondary.copyWith(color: AppColors.neutral700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Retry connection',
                    isLoading: c.isChecking,
                    onPressed: () => _retry(context),
                  ),
                  if (hasEvent) ...[
                    const SizedBox(height: AppSpacing.actionGap),
                    SecondaryButton(
                      label: 'Find attendee by name',
                      onPressed: () => context.push(Routes.search),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
