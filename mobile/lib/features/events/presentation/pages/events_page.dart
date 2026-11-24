import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/presentation/failure_text.dart';
import '../../../../core/presentation/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/commerce_widgets.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/floating_nav_bar.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/entities/assigned_event.dart';
import '../view_models/events_view_model.dart';

/// A2 · Мои события — выбор события, на котором работает контролёр.
class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  void _open(BuildContext context, AssignedEvent e) {
    context.read<EventsViewModel>().open(e);
    context.go(Routes.scanner);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<EventsViewModel>();
    final schedule = vm.schedule;
    final failure = vm.failure;

    Widget body;
    if (vm.isLoading) {
      body = const LoadingView();
    } else if (schedule == null && failure != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.side),
          child: MessageView(
            icon: failure is NetworkFailure ? LucideIcons.wifiOff : LucideIcons.circleAlert,
            tone: Tone.danger,
            title: failure is NetworkFailure ? l.noConnectionTitle : l.loadFailedTitle,
            message: failure.text(context),
            actionLabel: l.tryAgain,
            onAction: vm.load,
          ),
        ),
      );
    } else if (schedule == null || schedule.isEmpty) {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
        children: [
          AppCard(
            radius: 18,
            padding: const EdgeInsets.all(24),
            color: Colors.transparent,
            child: Column(
              children: [
                Icon(LucideIcons.calendarX, size: 32, color: c.textMuted),
                const SizedBox(height: 10),
                Text(l.noAssignedEvents, textAlign: TextAlign.center, style: AppText.body.copyWith(color: c.textMuted, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(l.noAssignedEventsHint, textAlign: TextAlign.center, style: AppText.meta.copyWith(color: c.textMuted)),
                const SizedBox(height: 16),
                SecondaryButton(label: l.checkAgain, icon: LucideIcons.refreshCw, onPressed: vm.load),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.signedInAs(context.watch<SessionController>().session?.email ?? ''),
            textAlign: TextAlign.center,
            style: AppText.finePrint.copyWith(color: c.textMuted),
          ),
        ],
      );
    } else {
      final now = DateTime.now();
      body = RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 24),
          children: [
            for (final e in [...schedule.today, ...schedule.upcoming]) ...[
              _EventCard(event: e, today: e.isToday(now), onTap: () => _open(context, e)),
              const SizedBox(height: 12),
            ],
            if (schedule.past.isNotEmpty) ...[
              const SizedBox(height: 8),
              SectionLabel(l.pastEvents, color: c.textMuted),
              const SizedBox(height: 10),
              for (final e in schedule.past) ...[
                _EventCard(event: e, today: false, onTap: () => _open(context, e)),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LargeHeader(
              title: l.myEvents,
              action: CircleIconButton(
                icon: LucideIcons.settings,
                tooltip: l.settings,
                onPressed: () => context.push(Routes.settings),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.today, required this.onTap});

  final AssignedEvent event;
  final bool today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final e = event;
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      borderColor: today ? c.primary.withValues(alpha: 0.5) : null,
      onTap: onTap,
      child: Row(
        children: [
          EventImage(label: e.title, height: 76, width: 76, radius: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (today) ...[
                  TagLabel(l.today, tone: Tone.success, dot: false),
                  const SizedBox(height: 4),
                ],
                Text(e.title, style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                if (e.startsAt != null)
                  Text(Fmt.dateTime(e.startsAt!), style: AppText.meta.copyWith(color: c.textMuted, fontWeight: FontWeight.w500)),
                if (e.venueLine.isNotEmpty)
                  Text(e.venueLine, style: AppText.meta.copyWith(color: c.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 20, color: c.textMuted),
        ],
      ),
    );
  }
}
