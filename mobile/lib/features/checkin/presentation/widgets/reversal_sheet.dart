import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/presentation/failure_text.dart';
import '../../../../core/presentation/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/labeled_text_field.dart';

/// C4 · Отмена входа — единственное разрушительное действие контролёра,
/// за подтверждением с причиной. Возвращает true, если отмена выполнена.
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
        _error = failure.text(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final at = widget.checkedInAt;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.reverseTitle(widget.attendeeName), style: AppText.headerTitle.copyWith(color: c.text)),
            const SizedBox(height: 6),
            Text(l.reverseBody, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
            const SizedBox(height: 16),
            AppCard(
              color: c.bg,
              child: DetailGrid(rows: [
                if (at != null) (l.checkedInLabel, '${Fmt.timeWithSeconds(at)} · ${widget.gate}'),
                (l.recordedBy, widget.recordedBy),
                (l.ticketLabel, widget.ticketLabel),
              ]),
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: l.reasonRequired,
              controller: _reason,
              hintText: l.reasonHint,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() => _error = null),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              InfoBanner(text: _error!, tone: Tone.danger),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              label: l.undoEntry,
              icon: LucideIcons.undo2,
              tone: Tone.danger,
              isLoading: _busy,
              onPressed: _reason.text.trim().isEmpty ? null : _confirm,
            ),
            const SizedBox(height: 8),
            GhostButton(label: l.actionKeep, color: c.textMuted, onPressed: _busy ? null : () => Navigator.of(context).pop(false)),
          ],
        ),
      ),
    );
  }
}
