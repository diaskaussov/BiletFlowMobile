import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../checkin/presentation/widgets/reversal_sheet.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../domain/entities/attendee.dart';
import '../view_models/attendee_view_model.dart';
import '../../../../core/presentation/failure_text.dart';

/// C3 · Attendee record — ручная отметка, по одному билету за раз.
class AttendeePage extends StatelessWidget {
  const AttendeePage({super.key});

  Future<void> _checkIn(BuildContext context, List<String> ids) async {
    final failure = await context.read<AttendeeViewModel>().checkIn(ids);
    if (!context.mounted) return;
    showMessage(
      context,
      failure?.text(context) ??
          (ids.length == 1 ? 'Checked in.' : '${ids.length} tickets checked in.'),
    );
  }

  Future<void> _reverse(BuildContext context, Attendee a, AttendeeTicket t) async {
    final vm = context.read<AttendeeViewModel>();
    final done = await showReversalSheet(
      context,
      attendeeName: a.fullName,
      ticketLabel: t.code ?? t.id,
      checkedInAt: t.checkedInAt,
      gate: context.read<SettingsController>().settings.gate,
      recordedBy: t.checkedInBy ?? vm.staffName,
      onConfirm: (reason) => vm.undo(t.id, reason),
    );
    if (done && context.mounted) showMessage(context, 'Check-in reversed. The ticket is valid again.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AttendeeViewModel>();
    final a = vm.attendee;

    Widget body;
    if (vm.isLoading) {
      body = const LoadingView();
    } else if (a == null) {
      body = Padding(
        padding: const EdgeInsets.all(AppSpacing.sideLight),
        child: MessageView(
          icon: Icons.person_off_outlined,
          title: 'Attendee not found',
          message: vm.failure?.text(context) ?? 'This record is not available.',
          actionLabel: 'Try again',
          onAction: vm.load,
        ),
      );
    } else {
      final pending = a.tickets.where((t) => t.canCheckIn).map((t) => t.id).toList();
      body = Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 26, AppSpacing.sideLight, 16),
              children: [
                Text(a.fullName, style: AppText.personName.copyWith(color: context.colors.text)),
                const SizedBox(height: 4),
                Text(
                  [a.email, a.orderNumber].whereType<String>().join(' · '),
                  style: AppText.meta.copyWith(color: context.colors.textMuted),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TagLabel(
                    pending.isEmpty
                        ? 'All tickets used or void'
                        : '${pending.length} ${pending.length == 1 ? 'ticket' : 'tickets'} not arrived',
                    filled: pending.isNotEmpty,
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                const SectionLabel('Tickets in this order'),
                const SizedBox(height: 4),
                for (final t in a.tickets)
                  _TicketRow(
                    ticket: t,
                    busy: vm.isBusy,
                    onCheckIn: () => _checkIn(context, [t.id]),
                    onReverse: () => _reverse(context, a, t),
                  ),
                if (a.history.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.section),
                  const SectionLabel('History'),
                  const SizedBox(height: 8),
                  for (final h in a.history)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${Fmt.shortDateTime(h.at)} — ${h.text}',
                        style: AppText.bodySecondary.copyWith(color: context.colors.textMuted),
                      ),
                    ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pending.length > 1) ...[
                  PrimaryButton(
                    label: pending.length == 2 ? 'Check in both tickets' : 'Check in all ${pending.length} tickets',
                    isLoading: vm.isBusy,
                    onPressed: () => _checkIn(context, pending),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Manual check-ins are recorded against your name and appear in the '
                  'organizer\'s activity timeline.',
                  style: AppText.finePrint.copyWith(color: context.colors.textMuted),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Attendee', onBack: () => context.pop()),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({
    required this.ticket,
    required this.busy,
    required this.onCheckIn,
    required this.onReverse,
  });

  final AttendeeTicket ticket;
  final bool busy;
  final VoidCallback onCheckIn;
  final VoidCallback onReverse;

  @override
  Widget build(BuildContext context) {
    final t = ticket;
    final status = switch (t.status) {
      AttendeeTicketStatus.valid => 'valid',
      AttendeeTicketStatus.checkedIn => 'checked in ${t.checkedInAt == null ? '' : Fmt.time(t.checkedInAt!)}'.trim(),
      AttendeeTicketStatus.refunded => 'refunded',
      AttendeeTicketStatus.cancelled => 'cancelled',
    };
    final Widget trailing = switch (t.status) {
      AttendeeTicketStatus.valid => SizedBox(
          width: 112,
          child: SecondaryButton(label: 'Check in', onPressed: busy ? null : onCheckIn),
        ),
      AttendeeTicketStatus.checkedIn => SizedBox(
          width: 112,
          child: SecondaryButton(label: 'Undo', onPressed: busy ? null : onReverse),
        ),
      _ => const TagLabel('Void'),
    };
    return ListRow(
      title: t.type,
      subtitle: [t.label, ?t.seat, status].join(' · '),
      trailing: trailing,
    );
  }
}
