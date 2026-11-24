import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/presentation/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import 'connection_controller.dart';

/// A9 · Нет сети — проверка блокируется, а не копится в очередь (§4.8).
class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  Future<void> _retry(BuildContext context) async {
    final l = context.l10n;
    final ok = await context.read<ConnectionController>().retry();
    if (!context.mounted) return;
    showMessage(context, ok ? l.connectionRestored : l.stillOffline);
    if (ok && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final conn = context.watch<ConnectionController>();
    final last = conn.lastSyncAt;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: conn.isOnline ? c.success : c.danger,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.side, vertical: 12),
              child: Row(children: [
                Icon(conn.isOnline ? LucideIcons.wifi : LucideIcons.wifiOff, size: 20, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(conn.isOnline ? l.connectionRestored : l.scanPaused,
                      style: AppText.bodyStrong.copyWith(color: Colors.white)),
                ),
              ]),
            ),
            if (context.canPop()) ScreenHeader(title: l.noConnectionTitle, onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.panel),
                        border: Border.all(color: c.border),
                      ),
                      child: Icon(LucideIcons.cloudOff, size: 64, color: c.textMuted),
                    ),
                    const SizedBox(height: 20),
                    Text(l.offlineBody, textAlign: TextAlign.center, style: AppText.body.copyWith(color: c.textMuted, fontWeight: FontWeight.w500, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(l.offlineNote, textAlign: TextAlign.center, style: AppText.meta.copyWith(color: c.textMuted)),
                    if (last != null) ...[
                      const SizedBox(height: 8),
                      Text(l.lastSync('${Fmt.timeWithSeconds(last)} · ${Fmt.ago(last)}'),
                          style: AppText.finePrint.copyWith(color: c.textMuted)),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: l.actionRetry,
                      icon: LucideIcons.refreshCw,
                      large: true,
                      isLoading: conn.isChecking,
                      onPressed: () => _retry(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
