import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Основная кнопка: заливка primary, 56 pt, скругление 16 (A1 «Войти»).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.large = false,
    this.tone,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final IconData? trailingIcon;

  /// 64 pt — главная кнопка экрана результата («Следующий»).
  final bool large;

  /// danger — «Вернуть деньги», success — подтверждение.
  final Tone? tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = switch (tone) {
      Tone.danger => c.danger,
      Tone.success => c.success,
      _ => c.primary,
    };
    return SizedBox(
      width: double.infinity,
      height: large ? AppSizes.buttonLarge : AppSizes.buttonPrimary,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return bg.withValues(alpha: isLoading ? 0.8 : 0.4);
            if (s.contains(WidgetState.pressed)) return Color.alphaBlend(Colors.black.withValues(alpha: 0.12), bg);
            return bg;
          }),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(large ? AppRadius.buttonLarge : AppRadius.button)),
          ),
          elevation: const WidgetStatePropertyAll(0),
        ),
        child: isLoading
            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: large ? 22 : 20, color: Colors.white), const SizedBox(width: 8)],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: (large ? AppText.buttonLarge : AppText.buttonPrimary).copyWith(color: Colors.white),
                    ),
                  ),
                  if (trailingIcon != null) ...[const SizedBox(width: 8), Icon(trailingIcon, size: large ? 22 : 20, color: Colors.white)],
                ],
              ),
      ),
    );
  }
}

/// Вторичная кнопка: фон surface, рамка border (A4 «Отменить вход»).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.onDark = false,
    this.icon,
    this.compact = false,
    this.tone,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Полупрозрачная кнопка поверх камеры («Фонарик», «Ввести код»).
  final bool onDark;
  final IconData? icon;

  /// 40 pt — кнопка внутри карточки («Отметить вход», «Вернуть деньги»).
  final bool compact;

  /// Цвет текста: danger для «Вернуть деньги», primary для действий в списке.
  final Tone? tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = onDark
        ? Colors.white
        : switch (tone) {
            Tone.danger => c.dangerText,
            Tone.primary => c.primary,
            _ => c.text,
          };
    final radius = BorderRadius.circular(onDark ? AppRadius.pill : (compact ? AppRadius.md : AppRadius.button));
    return SizedBox(
      width: compact || onDark ? null : double.infinity,
      height: compact ? AppSizes.buttonSmall : (onDark ? 48 : AppSizes.buttonSecondary),
      child: OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: compact ? 14 : 16)),
          backgroundColor: WidgetStatePropertyAll(onDark ? Colors.white.withValues(alpha: 0.15) : (tone == Tone.primary && compact ? c.primaryTint : c.surface)),
          foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.disabled) ? fg.withValues(alpha: 0.4) : fg),
          overlayColor: WidgetStatePropertyAll(fg.withValues(alpha: 0.08)),
          side: WidgetStatePropertyAll(
            onDark || (tone == Tone.primary && compact) ? BorderSide.none : BorderSide(color: c.border),
          ),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: radius)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: compact ? 16 : 18), const SizedBox(width: 8)],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: compact || onDark ? AppText.buttonSmall : AppText.buttonSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Главная кнопка экрана результата — 64 pt (A4 «Следующий»).
class ResultPrimaryButton extends StatelessWidget {
  const ResultPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) =>
      PrimaryButton(label: label, onPressed: onPressed, large: true, trailingIcon: icon);
}

/// Текстовая кнопка 44 pt — для второстепенных переходов.
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, this.onPressed, this.color, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.colors.primary;
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonGhost,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: fg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 6)],
            Text(label, style: AppText.buttonSmall.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}

/// Круглая кнопка-иконка 44 pt (A3 действие в шапке).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, required this.onPressed, this.tooltip, this.badge = false});

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  /// Точка-уведомление в углу.
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final button = Material(
      color: c.surface,
      shape: CircleBorder(side: BorderSide(color: c.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox.square(
          dimension: AppSizes.minTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: c.text),
              if (badge)
                Positioned(
                  top: 10,
                  right: 11,
                  child: Container(width: 8, height: 8, decoration: BoxDecoration(color: c.danger, shape: BoxShape.circle)),
                ),
            ],
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
