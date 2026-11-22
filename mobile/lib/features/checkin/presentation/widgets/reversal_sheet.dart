import 'package:flutter/material.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../../../../core/widgets/screen_header.dart';

/// C4 · Reverse a check-in. Единственное разрушительное действие
/// администратора — за подтверждением, которое называет кого и когда.
///
/// Возвращает true, если отмена выполнена.
Future<bool> showReversalSheet(
  BuildContext context, {
  required String attendeeName,
  required String ticketLabel,
  required DateTime? checkedInAt,
  required String gate,
  required String recordedBy,
  required Future<Failure?> Function(String reason) onConfirm,
}) async {
  final done = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.neutral900.withValues(alpha: 0.55),
    builder: (_) => _ReversalSheet(
      attendeeName: attendeeName,
      ticketLabel: ticketLabel,
      checkedInAt: checkedInAt,
      gate: gate,
      recordedBy: recordedBy,
      onConfirm: onConfirm,
    ),
  );
  return done ?? false;
}

class _ReversalSheet extends StatefulWidget {
  const _ReversalSheet({
    required this.attendeeName,
    required this.ticketLabel,
    required this.checkedInAt,
    required this.gate,
    required this.recordedBy,
    required this.onConfirm,
  });

  final String attendeeName;
  final String ticketLabel;
  final DateTime? checkedInAt;
  final String gate;
  final String recordedBy;
  final Future<Failure?> Function(String reason) onConfirm;

  @override
  State<_ReversalSheet> createState() => _ReversalSheetState();
}

class _ReversalSheetState extends State<_ReversalSheet> {
  final _reason = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final failure = await widget.onConfirm(_reason.text);
    if (!mounted) return;
    if (failure == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _busy = false;
        _error = failure.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final at = widget.checkedInAt;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sheetInset,
        AppSpacing.sheetInset,
        AppSpacing.sheetInset,
        AppSpacing.sheetInset + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: AppColors.bg,
          elevation: 12,
          child: BlueprintFrame(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Confirm reversal', color: AppColors.accent700),
                  const SizedBox(height: 10),
                  Text(
                    'Undo the check-in for ${widget.attendeeName}?',
                    style: AppText.listTitle.copyWith(color: AppColors.ink, fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The ticket becomes valid again and can be scanned once more. '
                    'The reversal is logged with your name and cannot be deleted.',
                    style: AppText.bodySecondary.copyWith(color: AppColors.neutral700),
                  ),
                  const SizedBox(height: 18),
                  DetailGrid(rows: [
                    if (at != null) ('Checked in', '${Fmt.timeWithSeconds(at)} · ${widget.gate}'),
                    ('Recorded by', widget.recordedBy),
                    ('Ticket', widget.ticketLabel),
                  ]),
                  const SizedBox(height: 18),
                  LabeledTextField(
                    label: 'Reason (required)',
                    controller: _reason,
                    hintText: 'Scanned the wrong person',
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: AppText.bodySecondary.copyWith(color: AppColors.ink)),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Keep',
                          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Undo check-in',
                          isLoading: _busy,
                          onPressed: _reason.text.trim().isEmpty ? null : _confirm,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
