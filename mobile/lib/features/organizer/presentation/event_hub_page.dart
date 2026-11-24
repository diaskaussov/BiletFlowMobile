import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../../../shared/domain/entities/insights.dart';
import '../domain/organizer_events_domain.dart';
import '../../../core/presentation/failure_text.dart';

class EventHub {
  const EventHub({required this.event, this.analytics});

  final EventInfo event;
  final EventAnalytics? analytics;
}

class EventHubViewModel extends Loadable<EventHub> {
  EventHubViewModel({required this.eventId, required GetManagedEvent get, required this._change})
      : super(() async {
          final r = await get(eventId);
          if (r case Err(:final failure)) return Err(failure);
          final a = (await get.analytics(eventId)).valueOrNull;
          return Ok(EventHub(event: r.valueOrNull!, analytics: a));
        });

  final int eventId;
  final ChangeEventState _change;

  Future<(EventInfo?, Failure?)> act(EventAction action) async {
    EventInfo? result;
    final f = await run(() => _change(data!.event, action), onOk: (EventInfo e) => result = e, reload: action != EventAction.duplicate);
    return (result, f);
  }
}

/// Обзор события организатора — точка входа в O3–O10.
class EventHubPage extends StatelessWidget {
  const EventHubPage({super.key});

  Future<void> _act(BuildContext context, EventHubViewModel vm, EventAction action) async {
    if (action == EventAction.cancel) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Cancel this event?', style: AppText.headerTitle.copyWith(color: context.colors.text)),
          content: Text(
            'Sales stop and every ticket becomes invalid. Attendees are notified. Records stay in the event history.',
            style: AppText.body.copyWith(color: context.colors.textMuted),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('KEEP')),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('CANCEL EVENT')),
          ],
        ),
      );
      if (ok != true) return;
    }
    final (result, failure) = await vm.act(action);
    if (!context.mounted) return;
    if (failure != null) {
      showMessage(context, failure.text(context));
      return;
    }
    switch (action) {
      case EventAction.publish:
        showMessage(context, 'Published. Attendees can register now.');
      case EventAction.unpublish:
        showMessage(context, 'Unpublished. The event is a draft again.');
      case EventAction.cancel:
        showMessage(context, 'Event cancelled.');
      case EventAction.duplicate:
        showMessage(context, 'Copied into a new draft without orders, tickets or check-ins.');
        if (result != null) context.pushReplacement(Routes.manageEvent(result.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventHubViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: vm.data?.event.title ?? 'Event',
              subtitle: vm.data?.event.status.label,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: LoadableView<EventHub>(
                state: vm,
                builder: (context, hub) {
                  final e = hub.event;
                  final a = hub.analytics;
                  final id = e.id;
                  Future<void> open(String route) async {
                    await context.push(route);
                    vm.load();
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 18, AppSpacing.sideLight, 24),
                    children: [
                      Wrap(spacing: 6, runSpacing: 6, children: [
                        TagLabel(e.status.label, filled: e.status == EventStatus.published),
                        TagLabel(e.visibility.label),
                        if (e.assignedSeating) TagLabel('Assigned seating', onTap: () => open(Routes.seating(id))),
                      ]),
                      const SizedBox(height: 12),
                      DetailGrid(rows: [
                        if (e.startsAt != null) ('When', Fmt.range(e.startsAt!, e.endsAt)),
                        if (e.fullAddress.isNotEmpty) ('Venue', e.fullAddress),
                        if (e.capacity != null) ('Capacity', Fmt.count(e.capacity!)),
                      ]),
                      if (a != null) ...[
                        const SizedBox(height: 16),
                        StatQuad(cells: [
                          (Fmt.count(a.ticketsSold), 'Sold'),
                          (Fmt.count(a.ticketsRemaining), 'Remaining'),
                          (Fmt.count(a.checkedIn), 'Checked in'),
                          (Fmt.moneyShort(a.grossRevenue), 'Gross · demo'),
                        ]),
                      ],
                      const SizedBox(height: AppSpacing.block),
                      if (e.status == EventStatus.draft)
                        PrimaryButton(label: 'Publish', isLoading: vm.isBusy, onPressed: () => _act(context, vm, EventAction.publish)),
                      if (e.status == EventStatus.published)
                        SecondaryButton(label: 'Unpublish', onPressed: vm.isBusy ? null : () => _act(context, vm, EventAction.unpublish)),
                      const SizedBox(height: AppSpacing.actionGap),
                      Row(children: [
                        Expanded(child: SecondaryButton(label: 'Edit', onPressed: () => open(Routes.editEvent(id)))),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SecondaryButton(
                            label: 'Duplicate',
                            onPressed: vm.isBusy ? null : () => _act(context, vm, EventAction.duplicate),
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('Manage'),
                      ValueRow(label: 'Ticket types & inventory', value: '', onTap: () => open(Routes.ticketTypes(id))),
                      if (e.assignedSeating) ValueRow(label: 'Seating', value: '', onTap: () => open(Routes.seating(id))),
                      ValueRow(
                        label: 'Paid sales',
                        value: e.paidSalesActivated ? 'Active' : 'Not activated',
                        onTap: () => open(Routes.activation(id)),
                      ),
                      ValueRow(label: 'Attendees & orders', value: a == null ? '' : Fmt.count(a.totalOrders), onTap: () => open(Routes.eventAttendees(id))),
                      ValueRow(label: 'Analytics', value: '', onTap: () => open(Routes.analytics(id))),
                      ValueRow(label: 'Campaigns & promo codes', value: '', onTap: () => open(Routes.campaigns(id))),
                      ValueRow(label: 'Check-in staff', value: '', onTap: () => open(Routes.staff(id))),
                      ValueRow(label: 'Activity timeline', value: '', onTap: () => open(Routes.history(id))),
                      const SizedBox(height: AppSpacing.section),
                      if (e.status != EventStatus.cancelled && e.status != EventStatus.completed)
                        GhostButton(label: 'Cancel event', onPressed: vm.isBusy ? null : () => _act(context, vm, EventAction.cancel)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
