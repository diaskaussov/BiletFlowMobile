import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/attendee.dart';
import '../view_models/search_view_model.dart';
import '../../../../core/presentation/failure_text.dart';

/// C1 · Find by name / C2 · No matches
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _query =
      TextEditingController(text: context.read<SearchViewModel>().query);
  final _focus = FocusNode();
  String _hint = 'Name, email or ticket code';

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _searchByTicketId() {
    setState(() => _hint = 'Ticket code from under the QR');
    _query.clear();
    context.read<SearchViewModel>().setQuery('');
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'Find attendee',
              subtitle: vm.eventTitle,
              onBack: () => context.pop(),
              side: AppSpacing.sideList,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 16, AppSpacing.sideList, 0),
              child: LabeledTextField(
                controller: _query,
                focusNode: _focus,
                autofocus: vm.query.isEmpty,
                leadingIcon: Icons.search,
                hintText: _hint,
                textInputAction: TextInputAction.search,
                onChanged: vm.setQuery,
                onSubmitted: (_) => vm.refresh(),
              ),
            ),
            if (!vm.isQueryTooShort && vm.allCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 14, AppSpacing.sideList, 0),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All · ${vm.allCount}',
                      active: vm.filter == SearchFilter.all,
                      onTap: () => vm.setFilter(SearchFilter.all),
                    ),
                    const SizedBox(width: 18),
                    _FilterChip(
                      label: 'Not arrived · ${vm.notArrivedCount}',
                      active: vm.filter == SearchFilter.notArrived,
                      onTap: () => vm.setFilter(SearchFilter.notArrived),
                    ),
                  ],
                ),
              ),
            Expanded(child: _results(context, vm)),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 8, AppSpacing.sideList, AppSpacing.bottomClearance),
              child: Text(
                vm.showNoMatches
                    ? 'Attendees who bought under another name will not appear. '
                        'Ask for the order confirmation email.'
                    : 'Search covers this event only. Match on name, email or ticket code.',
                style: AppText.finePrint.copyWith(color: context.colors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _results(BuildContext context, SearchViewModel vm) {
    if (vm.isLoading && vm.allCount == 0) return const LoadingView();
    if (vm.failure case final f?) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.sideList),
        child: MessageView(
          icon: Icons.error_outline,
          title: 'Search failed',
          message: f.text(context),
          actionLabel: 'Try again',
          onAction: vm.refresh,
        ),
      );
    }
    if (vm.showNoMatches) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 48, AppSpacing.sideList, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.search_off, size: 40, color: context.colors.textMuted),
            const SizedBox(height: 18),
            Text(
              'No attendee matches “${vm.query.trim()}”',
              style: AppText.screenTitle.copyWith(color: context.colors.text),
            ),
            const SizedBox(height: 8),
            Text(
              'Check the spelling, or search by the ticket ID printed under the QR code.',
              style: AppText.body.copyWith(color: context.colors.textMuted),
            ),
            const SizedBox(height: 26),
            SecondaryButton(label: 'Search by ticket ID', onPressed: _searchByTicketId),
            const SizedBox(height: 4),
            GhostButton(label: 'Back to scanner', onPressed: () => context.pop()),
          ],
        ),
      );
    }
    final list = vm.visible;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 6, AppSpacing.sideList, 12),
      itemCount: list.length,
      itemBuilder: (context, i) => _AttendeeRow(attendee: list[i]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSizes.minTap),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: active ? context.colors.primary : Colors.transparent, width: 2),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppText.sectionLabel.copyWith(color: active ? context.colors.primary : context.colors.textMuted),
        ),
      ),
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  const _AttendeeRow({required this.attendee});

  final Attendee attendee;

  @override
  Widget build(BuildContext context) {
    final a = attendee;
    final first = a.tickets.firstOrNull;
    final subtitle = a.tickets.length == 1
        ? [first?.type, first?.seat].whereType<String>().join(' · ')
        : '${first?.type ?? 'Tickets'} · ${a.tickets.length} tickets';
    final lastIn = a.lastCheckInAt;
    final Widget trailing;
    if (a.notArrivedCount > 0) {
      trailing = const TagLabel('Check in', filled: true);
    } else if (lastIn != null) {
      trailing = TagLabel('In ${Fmt.time(lastIn)}');
    } else {
      trailing = const TagLabel('Void');
    }
    return ListRow(
      title: a.fullName,
      subtitle: subtitle,
      trailing: trailing,
      onTap: () => context.push(Routes.attendee(a.id)),
    );
  }
}
