import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Кнопка «назад»: круг 44 pt с рамкой.
class BackBox extends StatelessWidget {
  const BackBox({super.key, required this.onPressed, this.onDark = false});

  final VoidCallback onPressed;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: Material(
        color: onDark ? Colors.white.withValues(alpha: 0.15) : c.surface,
        shape: CircleBorder(side: onDark ? BorderSide.none : BorderSide(color: c.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: AppSizes.minTap,
            child: Icon(LucideIcons.chevronLeft, size: 20, color: onDark ? Colors.white : c.text),
          ),
        ),
      ),
    );
  }
}

/// Шапка вложенного экрана: назад, над заголовком — контекст мелким
/// приглушённым шрифтом (M-B3 «Мои события» над названием события).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.side = AppSpacing.side,
  });

  final String title;

  /// Строка над заголовком.
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double side;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(side, 8, side, 12),
      child: Row(
        children: [
          if (onBack != null) ...[BackBox(onPressed: onBack!), const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppText.caption.copyWith(color: c.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  title,
                  style: AppText.headerTitle.copyWith(color: c.text),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// Заголовок блока: «По типам билетов», «Последние входы».
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color, this.trailing});

  final String text;
  final Color? color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final label = Text(text, style: AppText.sectionLabel.copyWith(color: color ?? context.colors.text));
    if (trailing == null) return label;
    return Row(children: [Expanded(child: label), trailing!]);
  }
}
