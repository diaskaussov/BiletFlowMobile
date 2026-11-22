import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Таблица «подпись / значение» в две колонки, шаг 10 / 20 (§07).
class DetailGrid extends StatelessWidget {
  const DetailGrid({super.key, required this.rows, this.color = AppColors.ink});

  final List<(String, String)> rows;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, (label, value)) in rows.indexed) ...[
          if (i > 0) const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppText.detail.copyWith(color: color.withValues(alpha: 0.72)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: AppText.detail.copyWith(color: color),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Сетка 2 × 2 с линиями 1 pt между ячейками (§07).
class StatQuad extends StatelessWidget {
  const StatQuad({super.key, required this.cells});

  /// Ровно четыре пары «число, подпись».
  final List<(String, String)> cells;

  @override
  Widget build(BuildContext context) {
    Widget cell((String, String) c) => Expanded(
          child: Container(
            color: AppColors.bg,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.$1, style: AppText.statNumeral.copyWith(color: AppColors.ink)),
                const SizedBox(height: 6),
                Text(
                  c.$2.toUpperCase(),
                  style: AppText.fieldLabel.copyWith(color: AppColors.neutral600),
                ),
              ],
            ),
          ),
        );

    return Container(
      color: AppColors.divider,
      padding: const EdgeInsets.all(1),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(children: [cell(cells[0]), const SizedBox(width: 1), cell(cells[1])]),
          ),
          const SizedBox(height: 1),
          IntrinsicHeight(
            child: Row(children: [cell(cells[2]), const SizedBox(width: 1), cell(cells[3])]),
          ),
        ],
      ),
    );
  }
}

/// Полоса прогресса 10 pt: рамка 1 pt, заливка accent, квадратные концы.
class ProgressStrip extends StatelessWidget {
  const ProgressStrip({super.key, required this.value, this.height = 10});

  /// 0…1
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(border: Border.all(color: AppColors.divider)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: const ColoredBox(color: AppColors.accent),
      ),
    );
  }
}

/// Метка «IN 19:43» и похожие (.tag).
class TagLabel extends StatelessWidget {
  const TagLabel(this.text, {super.key, this.filled = false});

  final String text;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? AppColors.accent100 : null,
        border: Border.all(color: filled ? AppColors.accent300 : AppColors.divider),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppText.tag.copyWith(
          color: filled ? AppColors.accent800 : AppColors.neutral700,
        ),
      ),
    );
  }
}

/// Рамка-чертёж: тонкая рамка + уголки 11 pt со смещением −6 (§07).
class BlueprintFrame extends StatelessWidget {
  const BlueprintFrame({
    super.key,
    required this.child,
    this.color = AppColors.divider,
    this.cornerColor = AppColors.neutral600,
    this.padding = const EdgeInsets.all(16),
    this.background,
  });

  final Widget child;
  final Color color;
  final Color cornerColor;
  final EdgeInsets padding;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _CornersPainter(cornerColor),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: color),
        ),
        child: child,
      ),
    );
  }
}

class _CornersPainter extends CustomPainter {
  _CornersPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const arm = 11.0;
    const o = -6.0;
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    final l = o, t = o, r = size.width - o, b = size.height - o;
    canvas
      ..drawLine(Offset(l, t), Offset(l + arm, t), p)
      ..drawLine(Offset(l, t), Offset(l, t + arm), p)
      ..drawLine(Offset(r, t), Offset(r - arm, t), p)
      ..drawLine(Offset(r, t), Offset(r, t + arm), p)
      ..drawLine(Offset(l, b), Offset(l + arm, b), p)
      ..drawLine(Offset(l, b), Offset(l, b - arm), p)
      ..drawLine(Offset(r, b), Offset(r - arm, b), p)
      ..drawLine(Offset(r, b), Offset(r, b - arm), p);
  }

  @override
  bool shouldRepaint(_CornersPainter old) => old.color != color;
}

/// Строка списка 52–64 pt с линией снизу; вся строка — зона нажатия.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.overline,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? overline;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (overline != null) ...[
                    Text(
                      overline!,
                      style: AppText.fieldLabel.copyWith(color: AppColors.accent700),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(title, style: AppText.listTitle.copyWith(color: AppColors.ink)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppText.meta.copyWith(color: AppColors.neutral600)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Строка «подпись — значение» для настроек и статусов.
class ValueRow extends StatelessWidget {
  const ValueRow({super.key, required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppText.body.copyWith(color: AppColors.ink)),
            ),
            Text(value, style: AppText.bodySecondary.copyWith(color: AppColors.neutral700)),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.neutral500),
            ],
          ],
        ),
      ),
    );
  }
}
