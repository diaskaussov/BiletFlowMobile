import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/main_tab_bar.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/server_address.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/controllers/session_controller.dart';
import '../../events/presentation/controllers/active_event_controller.dart';
import '../domain/entities/scanner_settings.dart';
import 'settings_controller.dart';

/// A6 · Settings & sign out
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _update(BuildContext context, ScannerSettings next) async {
    final failure = await context.read<SettingsController>().update(next);
    if (failure != null && context.mounted) showMessage(context, failure.message);
  }

  Future<void> _editGate(BuildContext context, ScannerSettings s) async {
    final controller = TextEditingController(text: s.gate);
    final gate = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assigned gate', style: AppText.headerTitle.copyWith(color: context.colors.text)),
        content: LabeledTextField(
          controller: controller,
          autofocus: true,
          hintText: 'Gate 3',
          textInputAction: TextInputAction.done,
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL', style: AppText.buttonGhost.copyWith(color: context.colors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text('SAVE', style: AppText.buttonGhost.copyWith(color: context.colors.primary)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (gate != null && context.mounted) await _update(context, s.copyWith(gate: gate));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>().session;
    final s = context.watch<SettingsController>().settings;
    final eventsCount = context.watch<ActiveEventController>().assigned.length;

    Widget toggle(String label, bool value, ScannerSettings Function(bool) apply) {
      return Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.border)),
        ),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(label, style: AppText.body.copyWith(color: context.colors.text)),
          value: value,
          activeThumbColor: context.colors.surface,
          activeTrackColor: context.colors.primary,
          onChanged: (v) => _update(context, apply(v)),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 18, AppSpacing.sideLight, 24),
          children: [
            Text('Settings', style: AppText.screenTitle.copyWith(color: context.colors.text)),
            const SizedBox(height: AppSpacing.block),
            Text(session?.fullName ?? '', style: AppText.listTitle.copyWith(color: context.colors.text)),
            Text(session?.email ?? '', style: AppText.meta.copyWith(color: context.colors.textMuted)),
            const SizedBox(height: 10),
            Row(
              children: [
                const TagLabel('Event admin', filled: true),
                const SizedBox(width: 8),
                TagLabel('$eventsCount ${eventsCount == 1 ? 'event' : 'events'}'),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            const SectionLabel('Scanning'),
            toggle('Torch on by default', s.torchOnByDefault, (v) => s.copyWith(torchOnByDefault: v)),
            toggle('Sound on result', s.soundOnResult, (v) => s.copyWith(soundOnResult: v)),
            toggle('Vibrate on reject', s.vibrateOnReject, (v) => s.copyWith(vibrateOnReject: v)),
            const ValueRow(label: 'Language', value: 'English'),
            const SizedBox(height: AppSpacing.section),
            const SectionLabel('Gate'),
            ValueRow(label: 'Assigned gate', value: s.gate, onTap: () => _editGate(context, s)),
            const ValueRow(label: 'Reverse check-in permission', value: 'Checked by server'),
            const SizedBox(height: AppSpacing.section),
            SecondaryButton(
              label: 'Sign out',
              onPressed: () => context.read<SessionController>().signOut(),
            ),
            const SizedBox(height: 14),
            Text(
              'BiletFlow Scanner ${AppConfig.appVersion} · ${context.watch<ServerAddress>().current}',
              style: AppText.finePrint.copyWith(color: context.colors.textMuted),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainTabBar(current: MainTab.settings),
    );
  }
}
