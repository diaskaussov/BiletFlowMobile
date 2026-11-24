import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/role_tab_bar.dart';
import '../../../app/routes.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/catalog_domain.dart';

class CatalogViewModel extends Loadable<List<EventListing>> {
  CatalogViewModel(BrowseEvents browse) : super(browse.call);

  EventFilter _filter = const EventFilter();
  EventFilter get filter => _filter;

  List<EventListing> get visible => applyFilter(data ?? const [], _filter, DateTime.now());

  List<String> get cities => _distinct((l) => l.event.city);
  List<String> get categories => _distinct((l) => l.event.category);

  List<String> _distinct(String? Function(EventListing) pick) =>
      {for (final l in data ?? const <EventListing>[]) ?pick(l)}.toList()..sort();

  void setFilter(EventFilter f) {
    _filter = f;
    notifyListeners();
  }
}

/// W1 · Афиша событий.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilters(CatalogViewModel vm) async {
    final next = await showModalBottomSheet<EventFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(initial: vm.filter, cities: vm.cities, categories: vm.categories),
    );
    if (next != null) vm.setFilter(next.copyWith(query: vm.filter.query));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<CatalogViewModel>();
    final count = vm.filter.activeCount;

    return RoleScaffold(
      tabs: RoleTabs.attendee,
      current: Routes.catalog,
      title: l.navEvents,
      subtitle: vm.data == null ? null : l.upcomingN(vm.visible.length),
      action: CircleIconButton(
        icon: LucideIcons.scanQrCode,
        tooltip: l.scanCampaignQr,
        onPressed: () => context.push('${Routes.catalog}/scan-promo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 8),
            child: Row(
              children: [
                Expanded(
                  child: LabeledTextField(
                    controller: _search,
                    compact: true,
                    leadingIcon: LucideIcons.search,
                    hintText: l.catalogSearch,
                    textInputAction: TextInputAction.search,
                    onChanged: (q) => vm.setFilter(vm.filter.copyWith(query: q)),
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  backgroundColor: c.primary,
                  child: Material(
                    color: count > 0 ? c.primaryTint : c.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: c.border)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: vm.data == null ? null : () => _openFilters(vm),
                      child: Tooltip(
                        message: count > 0 ? l.filtersN(count) : l.filters,
                        child: SizedBox.square(
                          dimension: 48,
                          child: Icon(LucideIcons.slidersHorizontal, size: 18, color: count > 0 ? c.primary : c.text),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LoadableView<List<EventListing>>(
              state: vm,
              builder: (context, _) {
                final list = vm.visible;
                if (list.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.side),
                    children: [
                      MessageView(
                        icon: LucideIcons.calendarX,
                        title: vm.filter.isEmpty ? l.noUpcoming : l.nothingMatches,
                        message: vm.filter.isEmpty ? l.noUpcomingHint : l.nothingMatchesHint,
                        actionLabel: vm.filter.isEmpty ? null : l.clearFilters,
                        onAction: () {
                          _search.clear();
                          vm.setFilter(const EventFilter());
                        },
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  onRefresh: vm.load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, i) => _EventCard(listing: list[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.listing});

  final EventListing listing;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final e = listing.event;
    final price = listing.minPrice;
    final priceText = !listing.hasTickets
        ? l.soldOut
        : price == null
            ? ''
            : price == 0
                ? l.free
                : l.fromPrice(Fmt.money(price));
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push(Routes.publicEvent(e.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
            child: EventImage(url: e.imageUrl, label: e.category ?? e.title, height: 140, radius: 0),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (e.startsAt != null)
                  Text(Fmt.dateTime(e.startsAt!), style: AppText.caption.copyWith(color: c.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(e.title, style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  [e.venueLine, ?e.category].where((s) => s.isNotEmpty).join(' · '),
                  style: AppText.meta.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(priceText, style: AppText.bodyStrong.copyWith(color: listing.hasTickets ? c.text : c.danger, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (e.assignedSeating) TagLabel(l.seatedTag, tone: Tone.info, dot: false),
                    if (price == 0 && listing.hasTickets) ...[
                      const SizedBox(width: 6),
                      TagLabel(l.registrationTag, tone: Tone.success, dot: false),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial, required this.cities, required this.categories});

  final EventFilter initial;
  final List<String> cities;
  final List<String> categories;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late EventFilter f = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.filters, style: AppText.headerTitle.copyWith(color: c.text, fontSize: 20)),
              const SizedBox(height: 16),
              SectionLabel(l.cityFilter),
              const SizedBox(height: 8),
              ChoiceChips<String?>(
                options: [null, ...widget.cities],
                selected: f.city,
                label: (x) => x ?? l.anyOption,
                onSelected: (x) => setState(() => f = f.copyWith(city: () => x)),
              ),
              const SizedBox(height: 18),
              SectionLabel(l.whenFilter),
              const SizedBox(height: 8),
              ChoiceChips<WhenFilter>(
                options: WhenFilter.values,
                selected: f.when,
                label: (w) => switch (w) {
                  WhenFilter.any => l.anyTime,
                  WhenFilter.today => l.today,
                  WhenFilter.weekend => l.thisWeekend,
                  WhenFilter.next30 => l.next30,
                },
                onSelected: (w) => setState(() => f = f.copyWith(when: w)),
              ),
              const SizedBox(height: 18),
              SectionLabel(l.categoryLabel),
              const SizedBox(height: 8),
              ChoiceChips<String?>(
                options: [null, ...widget.categories],
                selected: f.category,
                label: (x) => x ?? l.anyOption,
                onSelected: (x) => setState(() => f = f.copyWith(category: () => x)),
              ),
              const SizedBox(height: 18),
              SectionLabel(l.priceFilter),
              const SizedBox(height: 8),
              ChoiceChips<PriceFilter>(
                options: PriceFilter.values,
                selected: f.price,
                label: (p) => switch (p) {
                  PriceFilter.any => l.anyPrice,
                  PriceFilter.free => l.freeOnly,
                  PriceFilter.under5000 => l.under5000,
                },
                onSelected: (p) => setState(() => f = f.copyWith(price: p)),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: l.showEvents, onPressed: () => Navigator.of(context).pop(f)),
              GhostButton(
                label: l.actionReset,
                color: c.textMuted,
                onPressed: () => Navigator.of(context).pop(EventFilter(query: widget.initial.query)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
