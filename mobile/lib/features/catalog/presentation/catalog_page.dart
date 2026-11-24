import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/role_tab_bar.dart';
import '../../../app/routes.dart';
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

/// W1 · Event discovery
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
      backgroundColor: context.colors.bg,
      barrierColor: context.colors.scrim,
      builder: (_) => _FilterSheet(initial: vm.filter, cities: vm.cities, categories: vm.categories),
    );
    if (next != null) vm.setFilter(next.copyWith(query: vm.filter.query));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogViewModel>();
    final count = vm.filter.activeCount;

    return RoleScaffold(
      tabs: RoleTabs.attendee,
      current: Routes.catalog,
      title: 'Events',
      subtitle: vm.data == null ? null : '${vm.visible.length} upcoming',
      action: IconButton(
        tooltip: 'Scan a campaign QR',
        onPressed: () => context.push('${Routes.catalog}/scan-promo'),
        icon: Icon(Icons.qr_code_scanner, color: context.colors.text),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 14, AppSpacing.sideList, 0),
            child: Row(
              children: [
                Expanded(
                  child: LabeledTextField(
                    controller: _search,
                    leadingIcon: Icons.search,
                    hintText: 'Search events, venues, organizers',
                    textInputAction: TextInputAction.search,
                    onChanged: (q) => vm.setFilter(vm.filter.copyWith(query: q)),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: vm.data == null ? null : () => _openFilters(vm),
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                      side: BorderSide(color: count > 0 ? context.colors.primary : context.colors.border),
                      foregroundColor: count > 0 ? context.colors.primary : context.colors.text,
                    ),
                    icon: const Icon(Icons.tune, size: 18),
                    label: Text(count > 0 ? 'FILTERS · $count' : 'FILTERS', style: AppText.buttonGhost),
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
                    padding: const EdgeInsets.all(AppSpacing.sideList),
                    children: [
                      MessageView(
                        icon: Icons.event_busy_outlined,
                        title: vm.filter.isEmpty ? 'No upcoming events' : 'Nothing matches',
                        message: vm.filter.isEmpty
                            ? 'Published public events appear here as soon as organizers open registration.'
                            : 'Try another city, date or price.',
                        actionLabel: vm.filter.isEmpty ? null : 'Clear filters',
                        onAction: () {
                          _search.clear();
                          vm.setFilter(const EventFilter());
                        },
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 16, AppSpacing.sideList, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 18),
                  itemBuilder: (context, i) => _EventCard(listing: list[i]),
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
    final e = listing.event;
    final price = listing.minPrice;
    final priceText = !listing.hasTickets
        ? 'SOLD OUT'
        : price == null
            ? ''
            : price == 0
                ? 'FREE'
                : 'FROM ${Fmt.money(price)}';
    return InkWell(
      onTap: () => context.push(Routes.publicEvent(e.id)),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: context.colors.border), color: context.colors.surface),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventImage(url: e.imageUrl, label: e.category, height: 110),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (e.startsAt != null)
                    Text(Fmt.dayStamp(e.startsAt!), style: AppText.fieldLabel.copyWith(color: context.colors.primary)),
                  const SizedBox(height: 4),
                  Text(e.title, style: AppText.listTitle.copyWith(color: context.colors.text)),
                  Text(
                    [e.venueLine, ?e.category].where((s) => s.isNotEmpty).join(' · '),
                    style: AppText.meta.copyWith(color: context.colors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(priceText, style: AppText.sectionLabel.copyWith(color: context.colors.text)),
                      const Spacer(),
                      if (e.assignedSeating) const TagLabel('Seated'),
                      if (price == 0 && listing.hasTickets) ...[
                        const SizedBox(width: 6),
                        const TagLabel('Registration'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.sheetInset, 20, AppSpacing.sheetInset, 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel('Filters', color: context.colors.primary),
              const SizedBox(height: 16),
              const SectionLabel('City'),
              const SizedBox(height: 8),
              ChoiceChips<String?>(
                options: [null, ...widget.cities],
                selected: f.city,
                label: (c) => c ?? 'Any',
                onSelected: (c) => setState(() => f = f.copyWith(city: () => c)),
              ),
              const SizedBox(height: 18),
              const SectionLabel('When'),
              const SizedBox(height: 8),
              ChoiceChips<WhenFilter>(
                options: WhenFilter.values,
                selected: f.when,
                label: (w) => switch (w) {
                  WhenFilter.any => 'Any time',
                  WhenFilter.today => 'Today',
                  WhenFilter.weekend => 'This weekend',
                  WhenFilter.next30 => 'Next 30 days',
                },
                onSelected: (w) => setState(() => f = f.copyWith(when: w)),
              ),
              const SizedBox(height: 18),
              const SectionLabel('Category'),
              const SizedBox(height: 8),
              ChoiceChips<String?>(
                options: [null, ...widget.categories],
                selected: f.category,
                label: (c) => c ?? 'Any',
                onSelected: (c) => setState(() => f = f.copyWith(category: () => c)),
              ),
              const SizedBox(height: 18),
              const SectionLabel('Price'),
              const SizedBox(height: 8),
              ChoiceChips<PriceFilter>(
                options: PriceFilter.values,
                selected: f.price,
                label: (p) => switch (p) {
                  PriceFilter.any => 'Any price',
                  PriceFilter.free => 'Free only',
                  PriceFilter.under5000 => 'Under 5 000 ₸',
                },
                onSelected: (p) => setState(() => f = f.copyWith(price: p)),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Show events', onPressed: () => Navigator.of(context).pop(f)),
              GhostButton(
                label: 'Reset',
                onPressed: () => Navigator.of(context).pop(EventFilter(query: widget.initial.query)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
