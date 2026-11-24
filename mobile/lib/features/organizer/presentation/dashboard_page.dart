import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/role_tab_bar.dart';
import '../../../app/routes.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/organizer_events_domain.dart';

class DashboardViewModel extends Loadable<List<DashboardEvent>> {
  DashboardViewModel(GetOrganizerDashboard get) : super(get.call);

  DashboardGroup group = DashboardGroup.upcoming;
  bool _picked = false;

  @override
  Future<void> load() async {
    await super.load();
    // Открываем вкладку, где сейчас что-то есть: идущее событие важнее.
    if (!_picked && data != null) {
      group = DashboardGroup.values.firstWhere((g) => count(g) > 0, orElse: () => DashboardGroup.upcoming);
      notifyListeners();
    }
  }

  void setGroup(DashboardGroup g) {
    group = g;
    _picked = true;
    notifyListeners();
  }

  int count(DashboardGroup g) => (data ?? const []).where((e) => e.group == g).length;

  List<DashboardEvent> get visible => (data ?? const []).where((e) => e.group == group).toList();

  DashboardEvent? get live => (data ?? const []).where((e) => e.group == DashboardGroup.active).firstOrNull;
}

String groupLabel(DashboardGroup g) => switch (g) {
      DashboardGroup.active => 'Active',
      DashboardGroup.upcoming => 'Upcoming',
      DashboardGroup.draft => 'Draft',
      DashboardGroup.completed => 'Completed',
      DashboardGroup.cancelled => 'Cancelled',
    };

/// O1 · Organizer dashboard (§4.16)
class OrganizerDashboardPage extends StatelessWidget {
  const OrganizerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final all = vm.data ?? const [];
    return RoleScaffold(
      tabs: RoleTabs.organizer,
      current: Routes.organizer,
      title: 'Events',
      subtitle: vm.data == null ? null : '${all.length} events · ${vm.count(DashboardGroup.draft)} draft',
      action: IconButton(
        tooltip: 'Create an event',
        onPressed: () async {
          await context.push(Routes.newEvent);
          vm.load();
        },
        icon: const Icon(Icons.add, color: AppColors.ink),
      ),
      body: Column(
        children: [
          if (vm.data != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: UnderlineTabs(
                labels: [for (final g in DashboardGroup.values) '${groupLabel(g)} · ${vm.count(g)}'],
                current: DashboardGroup.values.indexOf(vm.group),
                onSelect: (i) => vm.setGroup(DashboardGroup.values[i]),
              ),
            ),
          Expanded(
            child: LoadableView<List<DashboardEvent>>(
              state: vm,
              builder: (context, _) {
                final list = vm.visible;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 16, AppSpacing.sideList, 24),
                  children: [
                    if (all.isEmpty) ...[
                      const MessageView(
                        icon: Icons.event_note_outlined,
                        title: 'Create your first event',
                        message: 'Creating events and issuing free tickets costs nothing. Paid sales are '
                            'activated per event when you need them.',
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: 'Create an event',
                        onPressed: () async {
                          await context.push(Routes.newEvent);
                          vm.load();
                        },
                      ),
                    ] else if (list.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text('No ${groupLabel(vm.group).toLowerCase()} events.',
                            style: AppText.bodySecondary.copyWith(color: AppColors.neutral600)),
                      ),
                    for (final row in list) ...[
                      row.group == DashboardGroup.active ? _LiveCard(row: row) : _EventRow(row: row),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.row});

  final DashboardEvent row;

  @override
  Widget build(BuildContext context) {
    final e = row.event;
    final a = row.analytics;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BlueprintFrame(
        background: AppColors.accent100,
        color: AppColors.accent300,
        cornerColor: AppColors.accent700,
        child: InkWell(
          onTap: () => context.push(Routes.manageEvent(e.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ACTIVE NOW · DOORS OPEN', style: AppText.fieldLabel.copyWith(color: AppColors.accent700)),
              const SizedBox(height: 6),
              Text(e.title, style: AppText.screenTitle.copyWith(color: AppColors.ink)),
              Text(e.venueLine, style: AppText.meta.copyWith(color: AppColors.neutral700)),
              if (a != null) ...[
                const SizedBox(height: 14),
                StatQuad(cells: [
                  (Fmt.count(a.checkedIn), 'Checked in'),
                  (Fmt.count(a.ticketsSold), 'Issued'),
                  ('${a.checkInPercentage.round()}%', 'Attendance'),
                  (Fmt.moneyShort(a.grossRevenue), 'Gross · demo'),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.row});

  final DashboardEvent row;

  @override
  Widget build(BuildContext context) {
    final e = row.event;
    final a = row.analytics;
    final sold = a == null ? '—' : '${Fmt.count(a.ticketsSold)} / ${Fmt.count(e.capacity ?? a.totalCapacity)}';
    return ListRow(
      overline: e.startsAt == null ? null : Fmt.dayStamp(e.startsAt!),
      title: e.title,
      subtitle: [
        if (row.group == DashboardGroup.draft && !e.paidSalesActivated) 'Draft',
        'Sold $sold',
        if (a != null && a.grossRevenue > 0) Fmt.moneyShort(a.grossRevenue),
      ].join(' · '),
      trailing: TagLabel(groupLabel(row.group), filled: row.group == DashboardGroup.upcoming),
      onTap: () => context.push(Routes.manageEvent(e.id)),
    );
  }
}
