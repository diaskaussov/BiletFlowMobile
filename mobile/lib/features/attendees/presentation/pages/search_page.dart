import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../app/main_tab_bar.dart';
import '../../../../app/routes.dart';
import '../../../../core/presentation/failure_text.dart';
import '../../../../core/presentation/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/commerce_widgets.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/floating_nav_bar.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/attendee.dart';
import '../view_models/search_view_model.dart';

/// Статус билета гостя для бейджа — общий для A7 и C3.
({String label, Tone tone}) ticketStatusBadge(AppLocalizations l, AttendeeTicketStatus s) => switch (s) {
      AttendeeTicketStatus.valid => (label: l.statusValid, tone: Tone.success),
      AttendeeTicketStatus.checkedIn => (label: l.statusUsed, tone: Tone.info),
      AttendeeTicketStatus.refunded => (label: l.statusRefunded, tone: Tone.warning),
      AttendeeTicketStatus.cancelled => (label: l.statusCancelled, tone: Tone.danger),
    };

/// A7 · Гости — поиск по имени, email, коду билета или номеру заказа.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _query = TextEditingController(text: context.read<SearchViewModel>().query);

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final vm = context.watch<SearchViewModel>();

    Widget results;
    if (vm.isQueryTooShort) {
      results = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.side),
          child: MessageView(icon: LucideIcons.userSearch, title: l.navGuests, message: l.guestSearchStart),
        ),
      );
    } else if (vm.isLoading && vm.allCount == 0) {
      results = const LoadingView();
    } else if (vm.failure != null) {
      results = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.side),
          child: MessageView(
            icon: LucideIcons.circleAlert,
            tone: Tone.danger,
            title: l.loadFailedTitle,
            message: vm.failure!.text(context),
            actionLabel: l.tryAgain,
            onAction: vm.refresh,
          ),
        ),
      );
    } else if (vm.showNoMatches) {
      results = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.side),
          child: MessageView(icon: LucideIcons.searchX, title: l.guestNoMatches(vm.query.trim()), message: l.guestNoMatchesHint),
        ),
      );
    } else {
      final list = vm.visible;
      results = ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 24),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _GuestCard(attendee: list[i]),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LargeHeader(title: l.navGuests, context_: vm.eventTitle, onContextTap: () => context.go(Routes.events)),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 8),
              child: LabeledTextField(
                controller: _query,
                autofocus: vm.query.isEmpty,
                leadingIcon: LucideIcons.search,
                hintText: l.guestSearchHint,
                textInputAction: TextInputAction.search,
                onChanged: vm.setQuery,
                onSubmitted: (_) => vm.refresh(),
              ),
            ),
            if (!vm.isQueryTooShort && vm.allCount > 0)
              UnderlineTabs(
                labels: [l.filterAll(vm.allCount), l.filterNotArrived(vm.notArrivedCount)],
                current: vm.filter.index,
                onSelect: (i) => vm.setFilter(SearchFilter.values[i]),
              ),
            Expanded(child: results),
          ],
        ),
      ),
      bottomNavigationBar: const ScannerTabBar(current: ScannerTab.guests),
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({required this.attendee});

  final Attendee attendee;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<SearchViewModel>();
    final a = attendee;
    final first = a.tickets.first;
    final status = a.notArrivedCount > 0
        ? AttendeeTicketStatus.valid
        : (a.hasArrived ? AttendeeTicketStatus.checkedIn : first.status);
    final badge = ticketStatusBadge(l, status);
    final detail = a.tickets.length == 1
        ? [first.type, ?first.seat].join(' · ')
        : '${first.type} · ${l.ticketsCount(a.tickets.length)}';
    return AppCard(
      onTap: () => context.push(Routes.attendee(a.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.fullName, style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                    if (a.email != null) Text(a.email!, style: AppText.meta.copyWith(color: c.textMuted)),
                    const SizedBox(height: 2),
                    Text(detail, style: AppText.meta.copyWith(color: c.textMuted)),
                  ],
                ),
              ),
              TagLabel(badge.label, tone: badge.tone),
            ],
          ),
          if (a.notArrivedCount > 0) ...[
            const SizedBox(height: 12),
            PrimaryButton(
              label: l.markEntry,
              icon: LucideIcons.logIn,
              isLoading: vm.checkingId == a.id,
              onPressed: () async {
                final f = await vm.checkIn(a);
                if (context.mounted) showMessage(context, f == null ? l.checkedInToast : f.text(context));
              },
            ),
          ],
        ],
      ),
    );
  }
}
