import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

/// Поле «дата и время»: по нажатию — системный выбор даты, затем времени.
class DateTimeField extends StatelessWidget {
  const DateTimeField({super.key, required this.label, required this.value, required this.onChanged, this.placeholder});

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? placeholder;

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
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label.copyWith(color: c.textMuted)),
        const SizedBox(height: 8),
        Material(
          color: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
            side: BorderSide(color: c.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.field),
            onTap: () => _pick(context),
            child: Container(
              height: AppSizes.textField,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value == null ? (placeholder ?? '—') : Fmt.dateTime(value!),
                      style: AppText.input.copyWith(color: value == null ? c.textMuted : c.text),
                    ),
                  ),
                  Icon(LucideIcons.calendar, size: 18, color: c.textMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Переключатель с подписью.
class LabeledSwitch extends StatelessWidget {
  const LabeledSwitch({super.key, required this.label, required this.value, required this.onChanged, this.hint});

  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppText.body.copyWith(color: c.text)),
      subtitle: hint == null ? null : Text(hint!, style: AppText.meta.copyWith(color: c.textMuted)),
      value: value,
      activeTrackColor: c.primary,
      onChanged: onChanged,
    );
  }
}

/// Столбчатый график продаж: скруглённые столбики, подписи на концах.
class BarStrip extends StatelessWidget {
  const BarStrip({super.key, required this.values, this.startLabel, this.endLabel, this.height = 96});

  final List<num> values;
  final String? startLabel;
  final String? endLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final max = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, v) in values.indexed) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Tooltip(
                    message: '$v',
                    child: Container(
                      height: (v / max * height).clamp(4, height).toDouble(),
                      decoration: BoxDecoration(
                        color: i == values.length - 1 ? c.primary : c.primary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(startLabel ?? '', style: AppText.caption.copyWith(color: c.textMuted)),
            const Spacer(),
            Text(endLabel ?? '', style: AppText.caption.copyWith(color: c.textMuted)),
          ],
        ),
      ],
    );
  }
}

/// «Early Bird · 60 / 100» с полосой — продажи и входы по типам билетов.
class ShareRow extends StatelessWidget {
  const ShareRow({super.key, required this.label, required this.value, required this.ratio, this.color});

  final String label;
  final String value;
  final double ratio;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(label, style: AppText.label.copyWith(color: c.text))),
            Text(value, style: AppText.detail.copyWith(color: c.textMuted)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 6,
              color: (color ?? c.primary).withValues(alpha: 0.14),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio.clamp(0, 1),
                child: ColoredBox(color: color ?? c.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
