import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Основная кнопка светлого экрана: заливка accent, 50 pt. Одна на экран.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonPrimary,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.accent.withValues(alpha: 0.45);
            }
            if (states.contains(WidgetState.pressed)) return AppColors.accent700;
            return AppColors.accent;
          }),
          foregroundColor: const WidgetStatePropertyAll(AppColors.paper),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        ),
        child: isLoading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.paper,
                ),
              )
            : Text(label.toUpperCase(), style: AppText.buttonPrimary),
      ),
    );
  }
}

/// Вторичная кнопка: прозрачная, рамка 1 pt. На тёмном поле — светлая рамка.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.onDark = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool onDark;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? AppColors.paper : AppColors.ink;
    final border =
        onDark ? AppColors.paper.withValues(alpha: 0.35) : AppColors.divider;
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonSecondary,
      child: OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled)
                  ? fg.withValues(alpha: 0.35)
                  : fg),
          overlayColor: WidgetStatePropertyAll(fg.withValues(alpha: 0.08)),
          side: WidgetStatePropertyAll(BorderSide(color: border)),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: AppText.buttonSecondary,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Главная кнопка экрана результата: заливка paper, 56 pt — самый крупный
/// объект на экране (§04).
class ResultPrimaryButton extends StatelessWidget {
  const ResultPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor = AppColors.ink,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonResult,
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.pressed)
                  ? AppColors.neutral200
                  : AppColors.paper),
          foregroundColor: WidgetStatePropertyAll(textColor),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        ),
        child: Text(label.toUpperCase(), style: AppText.buttonResult),
      ),
    );
  }
}

/// Текстовая кнопка 44 pt без рамки — только для обратимых переходов.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.accent700,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonGhost,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(color),
          overlayColor: WidgetStatePropertyAll(color.withValues(alpha: 0.10)),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        ),
        child: Text(label, style: AppText.buttonGhost),
      ),
    );
  }
}
