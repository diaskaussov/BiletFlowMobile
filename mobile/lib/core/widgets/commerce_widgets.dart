import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Картинка события. Без картинки — тонированный блок с категорией,
/// как плейсхолдер в веб-макетах.
class EventImage extends StatelessWidget {
  const EventImage({super.key, this.url, this.label, this.height = 120});

  final String? url;
  final String? label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: double.infinity,
      color: AppColors.accent200,
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(10),
      child: Text(
        (label ?? 'Event').toUpperCase(),
        style: AppText.fieldLabel.copyWith(color: AppColors.accent800),
      ),
    );
    final u = url;
    if (u == null || u.isEmpty) return placeholder;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        u,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
        loadingBuilder: (context, child, progress) => progress == null ? child : placeholder,
      ),
    );
  }
}

/// «− 2 +» — выбор количества билетов (W2).
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.max = 99,
    this.enabled = true,
  });

  final int value;
  final int max;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, String label, VoidCallback? onTap) => Semantics(
          button: true,
          label: label,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: AppSizes.minTap,
              height: AppSizes.minTap,
              decoration: BoxDecoration(border: Border.all(color: AppColors.divider)),
              child: Icon(icon, size: 18, color: onTap == null ? AppColors.neutral400 : AppColors.ink),
            ),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(Icons.remove, 'Fewer', enabled && value > 0 ? () => onChanged(value - 1) : null),
        SizedBox(
          width: 36,
          child: Text('$value', textAlign: TextAlign.center, style: AppText.statNumeral.copyWith(fontSize: 20, color: AppColors.ink)),
        ),
        button(Icons.add, 'More', enabled && value < max ? () => onChanged(value + 1) : null),
      ],
    );
  }
}

/// Вкладка-фильтр с подчёркиванием: «UPCOMING · 2».
class UnderlineTab extends StatelessWidget {
  const UnderlineTab({super.key, required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSizes.minTap),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: active ? AppColors.accent : Colors.transparent, width: 2)),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppText.sectionLabel.copyWith(color: active ? AppColors.accent : AppColors.neutral600),
        ),
      ),
    );
  }
}

/// Горизонтальный ряд вкладок с прокруткой, если не помещаются.
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({super.key, required this.labels, required this.current, required this.onSelect});

  final List<String> labels;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideList),
      child: Row(
        children: [
          for (final (i, l) in labels.indexed) ...[
            if (i > 0) const SizedBox(width: 18),
            UnderlineTab(label: l, active: i == current, onTap: () => onSelect(i)),
          ],
        ],
      ),
    );
  }
}

/// Выбор одного варианта из нескольких (чипы с рамкой).
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.label,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T) label;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final o in options)
          InkWell(
            onTap: () => onSelected(o),
            child: Container(
              constraints: const BoxConstraints(minHeight: 38),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: o == selected ? AppColors.accent : null,
                border: Border.all(color: o == selected ? AppColors.accent : AppColors.divider),
              ),
              child: Text(
                label(o),
                style: AppText.bodySecondary.copyWith(color: o == selected ? AppColors.paper : AppColors.ink, height: 1.2),
              ),
            ),
          ),
      ],
    );
  }
}

/// Полоса «DEMONSTRATION PAYMENT» — §4.6: демо-платежи не выдаются за настоящие.
class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        border: Border.all(color: AppColors.divider),
      ),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: 'DEMONSTRATION. ', style: AppText.sectionLabel.copyWith(color: AppColors.ink)),
          TextSpan(
            text: text ??
                'This academic build uses a payment sandbox. No money moves, no card is stored, '
                    'and every amount shown is simulated.',
            style: AppText.meta.copyWith(color: AppColors.neutral700),
          ),
        ]),
      ),
    );
  }
}
