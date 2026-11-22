import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Кнопка «назад»: рисуется квадрат 30 pt, нажимается зона 44 × 44 (§04).
class BackBox extends StatelessWidget {
  const BackBox({super.key, required this.onPressed, this.onDark = false});

  final VoidCallback onPressed;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? AppColors.paper : AppColors.ink;
    final border =
        onDark ? AppColors.paper.withValues(alpha: 0.35) : AppColors.divider;
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.square(
          dimension: AppSizes.minTap,
          child: Center(
            child: Container(
              width: AppSizes.backBox,
              height: AppSizes.backBox,
              decoration: BoxDecoration(border: Border.all(color: border)),
              child: Icon(Icons.chevron_left, size: 18, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

/// Шапка экрана: назад + заголовок 17 pt над подписью капсом 10 pt,
/// тонкая линия снизу (§07).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.side = AppSpacing.sideLight,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double side;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(onBack == null ? side : side - 7, 8, side, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[BackBox(onPressed: onBack!), const SizedBox(width: 5)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppText.headerTitle.copyWith(color: AppColors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!.toUpperCase(),
                    style: AppText.fieldLabel.copyWith(color: AppColors.neutral600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Заголовок секции капсом 11 pt (§02).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color = AppColors.neutral600});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppText.sectionLabel.copyWith(color: color));
  }
}
