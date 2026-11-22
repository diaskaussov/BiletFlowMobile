import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

/// Поле «дата и время»: показывает значение, по нажатию — системные
/// выбор даты, затем времени.
class DateTimeField extends StatelessWidget {
  const DateTimeField({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final initial = value ?? now.add(const Duration(days: 7));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null) return;
    onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.meta.copyWith(color: AppColors.neutral600)),
        const SizedBox(height: 5),
        InkWell(
          onTap: () => _pick(context),
          child: Container(
            height: AppSizes.textField,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.divider)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null ? 'Choose' : '${Fmt.date(value!)} · ${Fmt.time(value!)}',
                    style: AppText.input.copyWith(color: value == null ? AppColors.neutral500 : AppColors.ink),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.neutral600),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Переключатель с подписью — для настроек форм.
class LabeledSwitch extends StatelessWidget {
  const LabeledSwitch({super.key, required this.label, required this.value, required this.onChanged, this.hint});

  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppText.body.copyWith(color: AppColors.ink)),
      subtitle: hint == null ? null : Text(hint!, style: AppText.meta.copyWith(color: AppColors.neutral600)),
      value: value,
      activeThumbColor: AppColors.paper,
      activeTrackColor: AppColors.accent,
      onChanged: onChanged,
    );
  }
}

/// Столбики (§07 Bar chart): 96 pt, зазор 5 pt, линия основания,
/// подписи на концах. Последние столбики темнее — по свежести.
class BarStrip extends StatelessWidget {
  const BarStrip({super.key, required this.values, this.startLabel, this.endLabel, this.height = 96});

  final List<num> values;
  final String? startLabel;
  final String? endLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final max = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);
    const shades = [AppColors.accent300, AppColors.accent400, AppColors.accent500];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, v) in values.indexed) ...[
                if (i > 0) const SizedBox(width: 5),
                Expanded(
                  child: Tooltip(
                    message: '$v',
                    child: Container(
                      height: (v / max * height).clamp(2, height).toDouble(),
                      color: shades[(i * shades.length / values.length).floor().clamp(0, 2)],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.neutral500),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(startLabel ?? '', style: AppText.fieldLabel.copyWith(color: AppColors.neutral600)),
            const Spacer(),
            Text(endLabel ?? '', style: AppText.fieldLabel.copyWith(color: AppColors.neutral600)),
          ],
        ),
      ],
    );
  }
}

/// Горизонтальная полоса «имя · значение» с долей — продажи по типам.
class ShareRow extends StatelessWidget {
  const ShareRow({super.key, required this.label, required this.value, required this.ratio});

  final String label;
  final String value;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(label, style: AppText.bodySecondary.copyWith(color: AppColors.ink))),
            Text(value, style: AppText.detail.copyWith(color: AppColors.neutral700)),
          ]),
          const SizedBox(height: 6),
          Container(
            height: 10,
            decoration: BoxDecoration(border: Border.all(color: AppColors.divider)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio.clamp(0, 1),
              child: const ColoredBox(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
