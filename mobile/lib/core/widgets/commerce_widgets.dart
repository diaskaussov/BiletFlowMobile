import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'data_blocks.dart';

/// Градиенты обложек-заглушек: событие без картинки получает стабильный
/// цвет по названию (M-B1 «Thumb»).
const _coverGradients = [
  [Color(0xFF6D4AFF), Color(0xFFA78BFA)],
  [Color(0xFF2563EB), Color(0xFF60A5FA)],
  [Color(0xFFDB2777), Color(0xFFF472B6)],
  [Color(0xFF059669), Color(0xFF34D399)],
  [Color(0xFFEA580C), Color(0xFFFBBF24)],
];

LinearGradient coverGradient(String seed) {
  final g = _coverGradients[seed.codeUnits.fold<int>(0, (a, b) => a + b) % _coverGradients.length];
  return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: g);
}

/// Картинка события; без неё — градиентная обложка.
class EventImage extends StatelessWidget {
  const EventImage({super.key, this.url, this.label, this.height = 120, this.width, this.radius = AppRadius.card});

  final String? url;

  /// Название или категория — от них зависит цвет заглушки.
  final String? label;
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(gradient: coverGradient(label ?? ''), borderRadius: BorderRadius.circular(radius)),
      alignment: Alignment.center,
      child: Icon(LucideIcons.ticket, color: Colors.white.withValues(alpha: 0.85), size: height > 80 ? 36 : 22),
    );
    final u = url;
    if (u == null || u.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: Image.network(
          u,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder,
          loadingBuilder: (context, child, progress) => progress == null ? child : placeholder,
        ),
      ),
    );
  }
}

/// «− 2 +» — выбор количества билетов.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key, required this.value, required this.onChanged, this.max = 99, this.enabled = true});

  final int value;
  final int max;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget button(IconData icon, String label, VoidCallback? onTap) => Semantics(
          button: true,
          label: label,
          child: Material(
            color: onTap == null ? c.bg : c.primaryTint,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox.square(
                dimension: 40,
                child: Icon(icon, size: 18, color: onTap == null ? c.textMuted.withValues(alpha: 0.5) : c.primary),
              ),
            ),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(LucideIcons.minus, '−', enabled && value > 0 ? () => onChanged(value - 1) : null),
        SizedBox(
          width: 36,
          child: Text('$value', textAlign: TextAlign.center, style: AppText.cardTitle.copyWith(color: c.text, fontSize: 17)),
        ),
        button(LucideIcons.plus, '+', enabled && value < max ? () => onChanged(value + 1) : null),
      ],
    );
  }
}

/// Чип-фильтр (M-B1 «Все 4»): активный — тёмный, остальные — с рамкой.
class FilterChipPill extends StatelessWidget {
  const FilterChipPill({super.key, required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: active,
      button: true,
      child: Material(
        color: active ? c.text : c.surface,
        shape: StadiumBorder(side: active ? BorderSide.none : BorderSide(color: c.border)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Text(
              label,
              style: AppText.meta.copyWith(
                color: active ? c.bg : c.textMuted,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Старое имя одиночной вкладки-фильтра.
class UnderlineTab extends StatelessWidget {
  const UnderlineTab({super.key, required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FilterChipPill(label: label, active: active, onTap: onTap);
}

/// Ряд чипов-фильтров с горизонтальной прокруткой.
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({super.key, required this.labels, required this.current, required this.onSelect});

  final List<String> labels;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 8),
      child: Row(
        children: [
          for (final (i, l) in labels.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            FilterChipPill(label: l, active: i == current, onTap: () => onSelect(i)),
          ],
        ],
      ),
    );
  }
}

/// Выбор одного варианта (категория, тип скидки, способ оплаты).
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({super.key, required this.options, required this.selected, required this.onSelected, required this.label});

  final List<T> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T) label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final o in options)
          Material(
            color: o == selected ? c.primaryTint : c.surface,
            shape: StadiumBorder(side: BorderSide(color: o == selected ? c.primary : c.border)),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () => onSelected(o),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (o == selected) ...[Icon(LucideIcons.check, size: 14, color: c.primary), const SizedBox(width: 6)],
                    Text(
                      label(o),
                      style: AppText.meta.copyWith(
                        color: o == selected ? c.primary : c.text,
                        fontWeight: o == selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Плашка «демонстрационный режим» (§4.6: демо-платежи не выдаются за настоящие).
class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) => InfoBanner(
        tone: Tone.warning,
        icon: LucideIcons.flaskConical,
        text: text ??
            'Demonstration build: payments run in a sandbox. No money moves and no card is stored.',
      );
}
