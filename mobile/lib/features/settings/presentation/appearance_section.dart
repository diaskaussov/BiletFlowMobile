import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/presentation/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/screen_header.dart';
import '../domain/entities/appearance.dart';
import 'appearance_controller.dart';

/// Язык и тема — в профиле каждой роли и в настройках сканера.
class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  static String languageName(AppLanguage l) => switch (l) {
        AppLanguage.ru => 'Русский',
        AppLanguage.kk => 'Қазақша',
        AppLanguage.en => 'English',
      };

  Future<void> _pick<T>(BuildContext context, String title, List<T> options, T current, String Function(T) label, ValueChanged<T> onPick) async {
    final c = context.colors;
    final picked = await showModalBottomSheet<T>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.headerTitle.copyWith(color: c.text)),
              const SizedBox(height: 8),
              for (final o in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(label(o), style: AppText.body.copyWith(color: c.text)),
                  trailing: o == current ? Icon(LucideIcons.check, color: c.primary) : null,
                  onTap: () => Navigator.of(sheet).pop(o),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onPick(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final a = context.watch<AppearanceController>();
    String themeName(ThemePreference t) => switch (t) {
          ThemePreference.system => l.themeSystem,
          ThemePreference.light => l.themeLight,
          ThemePreference.dark => l.themeDark,
        };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l.appearance),
        ValueRow(
          icon: LucideIcons.languages,
          label: l.language,
          value: languageName(a.preferences.language),
          onTap: () => _pick<AppLanguage>(context, l.language, AppLanguage.values, a.preferences.language, languageName, a.setLanguage),
        ),
        ValueRow(
          icon: LucideIcons.moon,
          label: l.theme,
          value: themeName(a.preferences.theme),
          onTap: () => _pick<ThemePreference>(context, l.theme, ThemePreference.values, a.preferences.theme, themeName, a.setTheme),
        ),
      ],
    );
  }
}
