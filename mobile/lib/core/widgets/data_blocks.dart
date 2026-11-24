import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Карточка TicketTon: surface, рамка border, скругление 16.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = AppRadius.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor ?? c.border),
    );
    return Material(
      color: color ?? c.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

/// Пары «подпись — значение» (детали заказа, билета).
class DetailGrid extends StatelessWidget {
  const DetailGrid({super.key, required this.rows, this.color});

  final List<(String, String)> rows;

  /// Цвет текста на цветном фоне (карточка результата).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final value = color ?? c.text;
    final label = color?.withValues(alpha: 0.75) ?? c.textMuted;
    return Column(
      children: [
        for (final (i, (l, v)) in rows.indexed) ...[
          if (i > 0) const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l, style: AppText.bodySecondary.copyWith(color: label)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(v, textAlign: TextAlign.right, style: AppText.detail.copyWith(color: value)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Плитка показателя (Components «KPI»): подпись, крупное значение, подсказка.
class KpiTile extends StatelessWidget {
  const KpiTile({super.key, required this.label, required this.value, this.hint, this.valueColor});

  final String label;
  final String value;
  final String? hint;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      radius: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppText.meta.copyWith(color: c.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.statNumeral.copyWith(color: valueColor ?? c.text)),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint!, style: AppText.finePrint.copyWith(color: c.textMuted), maxLines: 2),
          ],
        ],
      ),
    );
  }
}

/// Сетка показателей в две колонки.
class StatQuad extends StatelessWidget {
  const StatQuad({super.key, required this.cells});

  /// Пары «значение, подпись».
  final List<(String, String)> cells;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 2) {
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: KpiTile(label: cells[i].$2, value: cells[i].$1)),
            const SizedBox(width: 10),
            Expanded(
              child: i + 1 < cells.length ? KpiTile(label: cells[i + 1].$2, value: cells[i + 1].$1) : const SizedBox(),
            ),
          ],
        ),
      ));
      if (i + 2 < cells.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }
}

/// Полоса прогресса 6 pt со скруглёнными концами (A3 «Вошло 87 из 150»).
class ProgressStrip extends StatelessWidget {
  const ProgressStrip({super.key, required this.value, this.height = 6, this.color});

  /// 0…1
  final double value;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fill = color ?? c.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: fill.withValues(alpha: 0.14),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: ColoredBox(color: fill),
        ),
      ),
    );
  }
}

/// Бейдж-пилюля со статусом и точкой (Components «StatusBadge»).
class TagLabel extends StatelessWidget {
  const TagLabel(this.text, {super.key, this.filled = false, this.onTap, this.tone, this.dot = true});

  final String text;

  /// Старый флаг «выделить» — то же, что tone: primary.
  final bool filled;
  final VoidCallback? onTap;
  final Tone? tone;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final t = context.colors.tone(tone ?? (filled ? Tone.primary : Tone.neutral));
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: t.dot, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Flexible(child: Text(text, style: AppText.badge.copyWith(color: t.fg), overflow: TextOverflow.ellipsis)),
          if (onTap != null) ...[
            const SizedBox(width: 2),
            Icon(LucideIcons.chevronRight, size: 12, color: t.fg),
          ],
        ],
      ),
    );
    if (onTap == null) return badge;
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTap),
          child: Align(widthFactor: 1, child: badge),
        ),
      ),
    );
  }
}

/// Раньше «рамка-чертёж»; в TicketTon — выделенная карточка.
class BlueprintFrame extends StatelessWidget {
  const BlueprintFrame({
    super.key,
    required this.child,
    this.color,
    this.cornerColor,
    this.padding = const EdgeInsets.all(16),
    this.background,
  });

  final Widget child;
  final Color? color;
  final Color? cornerColor;
  final EdgeInsets padding;
  final Color? background;

  @override
  Widget build(BuildContext context) =>
      AppCard(padding: padding, color: background, borderColor: color, child: child);
}

/// Строка списка: заголовок, подпись, справа бейдж или шеврон.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.overline,
    this.trailing,
    this.onTap,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final String? overline;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (overline != null) ...[
                    Text(overline!, style: AppText.caption.copyWith(color: c.textMuted)),
                    const SizedBox(height: 2),
                  ],
                  Text(title, style: AppText.listTitle.copyWith(color: c.text)),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppText.meta.copyWith(color: c.textMuted)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            if (trailing == null && onTap != null) ...[
              const SizedBox(width: 8),
              Icon(LucideIcons.chevronRight, size: 18, color: c.textMuted),
            ],
          ],
        ),
      ),
    );
  }
}

/// Строка «подпись — значение» в настройках и профиле.
class ValueRow extends StatelessWidget {
  const ValueRow({super.key, required this.label, required this.value, this.onTap, this.icon});

  final String label;
  final String value;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
        child: Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 20, color: c.textMuted), const SizedBox(width: 12)],
            Expanded(child: Text(label, style: AppText.body.copyWith(color: c.text))),
            Text(value, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(LucideIcons.chevronRight, size: 18, color: c.textMuted),
            ],
          ],
        ),
      ),
    );
  }
}

/// Кружок с инициалом (A8 «Последние входы», M-B13 пользователи).
class InitialAvatar extends StatelessWidget {
  const InitialAvatar(this.name, {super.key, this.size = 40});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final letter = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.primaryTint, shape: BoxShape.circle),
      child: Text(letter, style: AppText.bodyStrong.copyWith(color: c.primary, fontSize: size * 0.4)),
    );
  }
}

/// Цветная плашка с иконкой: ошибка входа, предупреждение, подсказка.
class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.text, this.tone = Tone.info, this.icon, this.action});

  final String text;
  final Tone tone;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.colors.tone(tone);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ??
                switch (tone) {
                  Tone.danger => LucideIcons.circleAlert,
                  Tone.warning => LucideIcons.triangleAlert,
                  Tone.success => LucideIcons.circleCheck,
                  _ => LucideIcons.info,
                },
            size: 18,
            color: t.fg,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppText.label.copyWith(color: t.fg))),
          if (action != null) ...[const SizedBox(width: 8), action!],
        ],
      ),
    );
  }
}
