import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/role_tab_bar.dart';
import '../../../app/routes.dart';
import '../../../core/di/injection.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/presentation/status_text.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/organizer_events_domain.dart';
import 'event_shell.dart';
import 'managed_event_controller.dart';

/// Фильтры-чипсы M-B1.
enum DashboardFilter { all, drafts, published, past, cancelled }

class DashboardViewModel extends Loadable<List<DashboardEvent>> {
  DashboardViewModel(GetOrganizerDashboard get) : super(get.call);

  DashboardFilter filter = DashboardFilter.all;
  String query = '';

  void setFilter(DashboardFilter f) {
    filter = f;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  static bool _matches(DashboardEvent e, DashboardFilter f) => switch (f) {
        DashboardFilter.all => true,
        DashboardFilter.drafts => e.group == DashboardGroup.draft,
        DashboardFilter.published => e.group == DashboardGroup.active || e.group == DashboardGroup.upcoming,
        DashboardFilter.past => e.group == DashboardGroup.completed,
        DashboardFilter.cancelled => e.group == DashboardGroup.cancelled,
      };

  int count(DashboardFilter f) => (data ?? const []).where((e) => _matches(e, f)).length;

  List<DashboardEvent> get visible {
    final q = query.trim().toLowerCase();
    return [
      for (final e in data ?? const <DashboardEvent>[])
        if (_matches(e, filter) && (q.isEmpty || e.event.title.toLowerCase().contains(q))) e,
    ];
  }
}

/// M-B1 · Мои события организатора (§4.16).
class OrganizerDashboardPage extends StatefulWidget {
  const OrganizerDashboardPage({super.key});

  @override
  State<OrganizerDashboardPage> createState() => _OrganizerDashboardPageState();
}

class _OrganizerDashboardPageState extends State<OrganizerDashboardPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _create(DashboardViewModel vm) async {
    await context.push(Routes.newEvent);
    vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<DashboardViewModel>();
    String chip(DashboardFilter f) => switch (f) {
          DashboardFilter.all => l.filterAllN(vm.count(f)),
          DashboardFilter.drafts => l.filterDraftsN(vm.count(f)),
          DashboardFilter.published => l.filterPublishedN(vm.count(f)),
          DashboardFilter.past => l.filterPastN(vm.count(f)),
          DashboardFilter.cancelled => l.filterCancelledN(vm.count(f)),
        };
    final filters = [for (final f in DashboardFilter.values) if (f == DashboardFilter.all || vm.count(f) > 0 || vm.filter == f) f];

    return RoleScaffold(
      tabs: RoleTabs.organizer,
      current: Routes.organizer,
      title: l.myEvents,
      action: Material(
        color: c.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _create(vm),
          child: Tooltip(
            message: l.createEvent,
            child: SizedBox.square(dimension: 44, child: Icon(LucideIcons.plus, size: 20, color: c.onPrimary)),
          ),
        ),
      ),
      body: LoadableView<List<DashboardEvent>>(
        state: vm,
        builder: (context, all) {
          if (all.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.side),
              children: [
                MessageView(icon: LucideIcons.calendarPlus, title: l.firstEventTitle, message: l.firstEventBody),
                const SizedBox(height: 18),
                PrimaryButton(label: l.createEvent, icon: LucideIcons.plus, onPressed: () => _create(vm)),
              ],
            );
          }
          final list = vm.visible;
          return RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 24),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(children: [
                    for (final f in filters) ...[
                      FilterChipPill(label: chip(f), active: vm.filter == f, onTap: () => vm.setFilter(f)),
                      const SizedBox(width: 8),
                    ],
                  ]),
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  controller: _search,
                  compact: true,
                  leadingIcon: LucideIcons.search,
                  hintText: l.searchByTitle,
                  onChanged: vm.setQuery,
                ),
                const SizedBox(height: 16),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(l.nothingFound, textAlign: TextAlign.center, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
                  ),
                for (final row in list) ...[
                  _EventCard(row: row, onChanged: vm.load),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.row, required this.onChanged});

  final DashboardEvent row;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final e = row.event;
    final a = row.analytics;
    final capacity = e.capacity ?? a?.totalCapacity ?? 0;
    final sold = a?.ticketsSold ?? 0;
    final live = row.group == DashboardGroup.active;
    return AppCard(
      borderColor: live ? c.primary.withValues(alpha: 0.5) : null,
      onTap: () async {
        sl<ManagedEventController>().put(e);
        await context.push(Routes.manageEvent(e.id));
        onChanged();
      },
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventImage(url: e.imageUrl, label: e.title, height: 64, width: 64, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      [if (e.startsAt != null) Fmt.dateTime(e.startsAt!), if ((e.city ?? '').isNotEmpty) e.city!].join(' · '),
                      style: AppText.meta.copyWith(color: c.textMuted),
                    ),
                    const SizedBox(height: 6),
                    live ? TagLabel(l.evLive, tone: Tone.primary) : TagLabel(e.status.text(l), tone: e.status.tone),
                  ],
                ),
              ),
              IconButton(
                tooltip: l.eventActions,
                visualDensity: VisualDensity.compact,
                onPressed: () => showEventMenu(context, e, onChanged: onChanged),
                icon: Icon(LucideIcons.ellipsisVertical, size: 20, color: c.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Text(l.soldOf(Fmt.count(sold), Fmt.count(capacity)),
                  style: AppText.meta.copyWith(color: c.textMuted, fontWeight: FontWeight.w500)),
            ),
            Text(Fmt.money(a?.grossRevenue ?? 0, freeWord: false), style: AppText.bodyStrong.copyWith(color: c.text, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          ProgressStrip(value: capacity == 0 ? 0 : sold / capacity),
        ],
      ),
    );
  }
}
