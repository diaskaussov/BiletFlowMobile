import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/server_address.dart';
import '../../../core/presentation/failure_text.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/form_widgets.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/controllers/session_controller.dart';
import '../../events/presentation/controllers/active_event_controller.dart';
import '../domain/entities/scanner_settings.dart';
import 'appearance_section.dart';
import 'settings_controller.dart';

/// A6 · Настройки контролёра: сканер, вход, оформление, выход.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _update(BuildContext context, ScannerSettings next) async {
    final failure = await context.read<SettingsController>().update(next);
    if (failure != null && context.mounted) showMessage(context, failure.text(context));
  }

  Future<void> _editGate(BuildContext context, ScannerSettings s) async {
    final l = context.l10n;
    final controller = TextEditingController(text: s.gate);
    final gate = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 16 + MediaQuery.viewInsetsOf(sheet).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.assignedGate, style: AppText.headerTitle.copyWith(color: sheet.colors.text)),
            const SizedBox(height: 16),
            LabeledTextField(
              controller: controller,
              autofocus: true,
              hintText: 'Gate 3',
              textInputAction: TextInputAction.done,
              onSubmitted: (v) => Navigator.of(sheet).pop(v),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: l.actionSave, onPressed: () => Navigator.of(sheet).pop(controller.text)),
          ],
        ),
      ),
    );
    controller.dispose();
    if (gate != null && context.mounted) await _update(context, s.copyWith(gate: gate));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final session = context.watch<SessionController>().session;
    final s = context.watch<SettingsController>().settings;
    final eventsCount = context.watch<ActiveEventController>().assigned.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l.settings, onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        InitialAvatar(session?.fullName ?? '?', size: 48),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(session?.fullName ?? '', style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                              Text(session?.email ?? '', style: AppText.meta.copyWith(color: c.textMuted)),
                              const SizedBox(height: 6),
                              Wrap(spacing: 6, children: [
                                TagLabel(l.roleEventAdmin, tone: Tone.primary),
                                TagLabel(l.eventsCount(eventsCount), dot: false),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  SectionLabel(l.scanningSection),
                  LabeledSwitch(label: l.torchDefault, value: s.torchOnByDefault, onChanged: (v) => _update(context, s.copyWith(torchOnByDefault: v))),
                  LabeledSwitch(label: l.soundOnResult, value: s.soundOnResult, onChanged: (v) => _update(context, s.copyWith(soundOnResult: v))),
                  LabeledSwitch(label: l.vibrateOnReject, value: s.vibrateOnReject, onChanged: (v) => _update(context, s.copyWith(vibrateOnReject: v))),
                  const SizedBox(height: AppSpacing.block),
                  SectionLabel(l.gateSection),
                  ValueRow(icon: LucideIcons.doorOpen, label: l.assignedGate, value: s.gate, onTap: () => _editGate(context, s)),
                  const SizedBox(height: AppSpacing.section),
                  const AppearanceSection(),
                  const SizedBox(height: AppSpacing.section),
                  SecondaryButton(
                    label: l.signOut,
                    icon: LucideIcons.logOut,
                    tone: Tone.danger,
                    onPressed: () => context.read<SessionController>().signOut(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'BiletFlow ${AppConfig.appVersion} · ${l.server}: ${context.watch<ServerAddress>().current}',
                    textAlign: TextAlign.center,
                    style: AppText.finePrint.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
