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
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../domain/tickets_domain.dart';

class MyTicketsViewModel extends Loadable<MyTickets> {
  MyTicketsViewModel(GetMyTickets get) : super(get.call);

  int tab = 0;

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }
}

/// W8 · My tickets & orders
class MyTicketsPage extends StatelessWidget {
  const MyTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyTicketsViewModel>();
    final d = vm.data;
    return RoleScaffold(
      tabs: RoleTabs.attendee,
      current: Routes.myTickets,
      title: 'My tickets',
      body: Column(
        children: [
          if (d != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: UnderlineTabs(
                labels: [
                  'Upcoming · ${d.upcoming.length}',
                  'Past · ${d.past.length}',
                  'Refunded · ${d.refunded.length}',
                ],
                current: vm.tab,
                onSelect: vm.setTab,
              ),
            ),
          Expanded(
            child: LoadableView<MyTickets>(
              state: vm,
              builder: (context, d) {
                final groups = [d.upcoming, d.past, d.refunded][vm.tab];
                if (groups.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.sideList),
                    children: [
                      MessageView(
                        icon: Icons.confirmation_number_outlined,
                        title: vm.tab == 0 ? 'No upcoming tickets' : 'Nothing here',
                        message: vm.tab == 0
                            ? 'Tickets you buy or register for appear here with their QR codes.'
                            : 'Tickets show up here after the event or after a refund.',
                        actionLabel: vm.tab == 0 ? 'Browse events' : null,
                        onAction: () => context.go(Routes.catalog),
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 14, AppSpacing.sideList, 24),
                  itemCount: groups.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => _GroupCard(group: groups[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final TicketGroup group;

  @override
  Widget build(BuildContext context) {
    final g = group;
    final count = g.tickets.length;
    final status = g.allVoid
        ? g.tickets.first.status.label
        : g.tickets.any((t) => t.status == TicketStatus.checkedIn)
            ? 'Used'
            : 'Valid';
    final orderId = g.orderId;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: context.colors.surface, border: Border.all(color: context.colors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  g.startsAt == null ? 'DATE TBA' : Fmt.dayStamp(g.startsAt!),
                  style: AppText.fieldLabel.copyWith(color: context.colors.primary),
                ),
              ),
              TagLabel(status, filled: status == 'Valid'),
            ],
          ),
          const SizedBox(height: 6),
          Text(g.eventTitle ?? 'Event', style: AppText.listTitle.copyWith(color: context.colors.text)),
          Text(
            [
              ?g.venue,
              '$count ${count == 1 ? 'ticket' : 'tickets'}',
              if (g.seats.isNotEmpty) g.seats.join(', '),
            ].where((s) => s.isNotEmpty).join(' · '),
            style: AppText.meta.copyWith(color: context.colors.textMuted),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: count == 1 ? 'View ticket' : 'View tickets',
            onPressed: () => count == 1
                ? context.push(Routes.ticket(g.tickets.first.id))
                : orderId != null
                    ? context.push(Routes.order(orderId))
                    : context.push(Routes.ticket(g.tickets.first.id)),
          ),
        ],
      ),
    );
  }
}
