import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/main_tab_bar.dart';
import '../../../../app/routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../domain/entities/assigned_event.dart';
import '../view_models/events_view_model.dart';

/// A2 · No events assigned / A3 · Assigned events
class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventsViewModel>();
    final session = context.watch<SessionController>().session;
    final schedule = vm.schedule;
    final failure = vm.failure;

    Widget body;
    if (vm.isLoading) {
      body = const LoadingView();
    } else if (schedule == null && failure != null) {
      body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideList, vertical: 40),
        child: MessageView(
          icon: failure is NetworkFailure ? Icons.wifi_off : Icons.error_outline,
          title: failure is NetworkFailure ? 'No connection' : 'Could not load events',
          message: failure.message,
          actionLabel: 'Try again',
          onAction: vm.load,
        ),
      );
    } else if (schedule == null || schedule.isEmpty) {
      body = _Empty(email: session?.email ?? '', onRetry: vm.load);
    } else {
      body = RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 18, AppSpacing.sideList, 24),
          children: [
            if (schedule.featured case final featured?) ...[
              SectionLabel(
                schedule.today.isNotEmpty ? 'Today · ${schedule.today.length}' : 'Next up',
              ),
              const SizedBox(height: 12),
              _FeaturedCard(event: featured, isToday: schedule.today.contains(featured)),
            ],
            ..._section(context, 'Today', schedule.today.skip(1).toList()),
            ..._section(
              context,
              'Upcoming',
              schedule.upcoming.where((e) => e != schedule.featured).toList(),
              total: schedule.upcoming.length,
            ),
            ..._section(
              context,
              'Past',
              schedule.past.where((e) => e != schedule.featured).toList(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 18, AppSpacing.sideList, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text('Events', style: AppText.screenTitle.copyWith(color: AppColors.ink)),
                  ),
                  Text(
                    session?.shortName ?? '',
                    style: AppText.meta.copyWith(color: AppColors.neutral600),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: const MainTabBar(current: MainTab.events),
    );
  }

  List<Widget> _section(
    BuildContext context,
    String title,
    List<AssignedEvent> events, {
    int? total,
  }) {
    if (events.isEmpty) return const [];
    return [
      const SizedBox(height: AppSpacing.section),
      SectionLabel('$title · ${total ?? events.length}'),
      const SizedBox(height: 4),
      for (final e in events)
        ListRow(
          overline: e.startsAt == null ? null : Fmt.dayStamp(e.startsAt!),
          title: e.title,
          subtitle: [
            if (e.venueLine.isNotEmpty) e.venueLine,
            if (e.capacity != null) '${Fmt.count(e.capacity!)} capacity',
          ].join(' · '),
          trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.neutral500),
          onTap: () {
            context.read<EventsViewModel>().open(e);
            context.push(Routes.eventSummary(e.id));
          },
        ),
    ];
  }
}

/// «Today's event card» — единственная тонированная карточка (§06).
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.event, required this.isToday});

  final AssignedEvent event;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<EventsViewModel>();
    final stats = context.watch<EventsViewModel>().statsFor(event.id);
    final gate = context.watch<SettingsController>().settings.gate;
    final when = event.startsAt == null ? null : Fmt.relativeDay(event.startsAt!);

    return BlueprintFrame(
      background: AppColors.accent100,
      color: AppColors.accent300,
      cornerColor: AppColors.accent700,
      padding: const EdgeInsets.all(18),
      child: InkWell(
        onTap: () {
          vm.open(event);
          context.push(Routes.eventSummary(event.id));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isToday
                  ? 'DOORS OPEN · ${gate.toUpperCase()}'
                  : (event.startsAt == null ? 'ASSIGNED' : Fmt.dayStamp(event.startsAt!)),
              style: AppText.fieldLabel.copyWith(color: AppColors.accent700),
            ),
            const SizedBox(height: 8),
            Text(event.title, style: AppText.screenTitle.copyWith(color: AppColors.ink)),
            const SizedBox(height: 4),
            Text(
              [if (event.venueLine.isNotEmpty) event.venueLine, ?when].join(' · '),
              style: AppText.meta.copyWith(color: AppColors.neutral700),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _Stat(value: stats == null ? '—' : Fmt.count(stats.checkedIn), label: 'Checked in'),
                const SizedBox(width: 28),
                _Stat(value: stats == null ? '—' : Fmt.count(stats.registered), label: 'Issued'),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Open scanner',
              onPressed: () {
                vm.open(event);
                context.push(Routes.scanner);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppText.statNumeral.copyWith(color: AppColors.ink)),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: AppText.fieldLabel.copyWith(color: AppColors.neutral600)),
      ],
    );
  }
}

/// A2 — аккаунт есть, событий нет.
class _Empty extends StatelessWidget {
  const _Empty({required this.email, required this.onRetry});

  final String email;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 60, AppSpacing.sideList, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MessageView(
            icon: Icons.event_busy_outlined,
            title: 'Nothing assigned yet',
            message: 'An organizer has to add you as an event admin before an '
                'event appears here. Ask them for the email you signed in with.',
            actionLabel: 'Check again',
            onAction: onRetry,
          ),
          const Spacer(),
          Text(
            'Signed in as $email',
            style: AppText.finePrint.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }
}
