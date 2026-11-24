import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/failure_text.dart';
import '../../../../core/presentation/l10n.dart';
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
import 'search_page.dart' show ticketStatusBadge;

/// C3 · Карточка гостя: билеты заказа, ручная отметка, отмена входа.
class AttendeePage extends StatelessWidget {
  const AttendeePage({super.key});

  Future<void> _checkIn(BuildContext context, List<String> ids) async {
    final f = await context.read<AttendeeViewModel>().checkIn(ids);
    if (context.mounted) showMessage(context, f?.text(context) ?? context.l10n.checkedInToast);
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
    if (done && context.mounted) showMessage(context, context.l10n.reversedBody);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<AttendeeViewModel>();
    final a = vm.attendee;

    Widget body;
    if (vm.isLoading) {
      body = const LoadingView();
    } else if (a == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.side),
          child: MessageView(
            icon: LucideIcons.userX,
            title: l.recordUnavailable,
            message: vm.failure?.text(context) ?? '',
            actionLabel: l.tryAgain,
            onAction: vm.load,
          ),
        ),
      );
    } else {
      final pending = [for (final t in a.tickets) if (t.canCheckIn) t.id];
      body = Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 16),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      InitialAvatar(a.fullName, size: 48),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.fullName, style: AppText.headerTitle.copyWith(color: c.text)),
                            Text([?a.email, ?a.orderNumber].join(' · '), style: AppText.meta.copyWith(color: c.textMuted)),
                            const SizedBox(height: 6),
                            TagLabel(
                              pending.isEmpty ? l.allUsedOrVoid : l.notArrivedCount(pending.length),
                              tone: pending.isEmpty ? Tone.neutral : Tone.success,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                SectionLabel(l.ticketsInOrder),
                const SizedBox(height: 10),
                for (final t in a.tickets) ...[
                  _TicketCard(
                    ticket: t,
                    busy: vm.isBusy,
                    onCheckIn: () => _checkIn(context, [t.id]),
                    onReverse: () => _reverse(context, a, t),
                  ),
                  const SizedBox(height: 10),
                ],
                if (a.history.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.block),
                  SectionLabel(l.history),
                  const SizedBox(height: 8),
                  for (final h in a.history)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('${Fmt.shortDateTime(h.at)} — ${h.text}', style: AppText.bodySecondary.copyWith(color: c.textMuted)),
                    ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 16),
            child: Column(
              children: [
                if (pending.length > 1) ...[
                  PrimaryButton(
                    label: l.checkInAll(pending.length),
                    icon: LucideIcons.logIn,
                    isLoading: vm.isBusy,
                    onPressed: () => _checkIn(context, pending),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(l.manualNote, textAlign: TextAlign.center, style: AppText.finePrint.copyWith(color: c.textMuted)),
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
            ScreenHeader(title: l.guest, onBack: () => context.pop()),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.busy, required this.onCheckIn, required this.onReverse});

  final AttendeeTicket ticket;
  final bool busy;
  final VoidCallback onCheckIn;
  final VoidCallback onReverse;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final t = ticket;
    final badge = ticketStatusBadge(l, t.status);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(t.type, style: AppText.listTitle.copyWith(color: c.text))),
              TagLabel(badge.label, tone: badge.tone),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [t.label, ?t.seat, if (t.checkedInAt != null) Fmt.time(t.checkedInAt!)].join(' · '),
            style: AppText.mono.copyWith(color: c.textMuted, fontWeight: FontWeight.w400),
          ),
          if (t.canCheckIn) ...[
            const SizedBox(height: 12),
            PrimaryButton(label: l.markEntry, icon: LucideIcons.logIn, onPressed: busy ? null : onCheckIn),
          ],
          if (t.status == AttendeeTicketStatus.checkedIn) ...[
            const SizedBox(height: 12),
            SecondaryButton(label: l.undoEntry, icon: LucideIcons.undo2, onPressed: busy ? null : onReverse),
          ],
        ],
      ),
    );
  }
}
