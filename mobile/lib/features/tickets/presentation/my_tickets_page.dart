import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/role_tab_bar.dart';
import '../../../app/routes.dart';
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

/// W8 · Мои билеты и заказы.
class MyTicketsPage extends StatelessWidget {
  const MyTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final vm = context.watch<MyTicketsViewModel>();
    final d = vm.data;
    return RoleScaffold(
      tabs: RoleTabs.attendee,
      current: Routes.myTickets,
      title: l.myTickets,
      body: Column(
        children: [
          if (d != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(children: [
                  for (final (i, label) in [l.tabUpcomingN(d.upcoming.length), l.tabPastN(d.past.length), l.tabRefundedN(d.refunded.length)].indexed) ...[
                    FilterChipPill(label: label, active: vm.tab == i, onTap: () => vm.setTab(i)),
                    const SizedBox(width: 8),
                  ],
                ]),
              ),
            ),
          Expanded(
            child: LoadableView<MyTickets>(
              state: vm,
              builder: (context, d) {
                final groups = [d.upcoming, d.past, d.refunded][vm.tab];
                if (groups.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.side),
                    children: [
                      MessageView(
                        icon: LucideIcons.ticket,
                        title: vm.tab == 0 ? l.noUpcomingTickets : l.nothingHere,
                        message: vm.tab == 0 ? l.noUpcomingTicketsHint : l.pastTicketsHint,
                        actionLabel: vm.tab == 0 ? l.browseEvents : null,
                        onAction: () => context.go(Routes.catalog),
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  onRefresh: vm.load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 24),
                    itemCount: groups.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _GroupCard(group: groups[i]),
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

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final TicketGroup group;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final g = group;
    final count = g.tickets.length;
    final (String status, Tone tone) = g.allVoid
        ? (g.tickets.first.status.text(l), g.tickets.first.status.tone)
        : g.tickets.any((t) => t.status == TicketStatus.checkedIn)
            ? (l.statusUsed, Tone.info)
            : eventIsOver(g.startsAt, DateTime.now())
                ? (l.statusExpired, Tone.neutral)
                : (l.statusValid, Tone.success);
    final orderId = g.orderId;
    void open() => count == 1
        ? context.push(Routes.ticket(g.tickets.first.id))
        : orderId != null
            ? context.push(Routes.order(orderId))
            : context.push(Routes.ticket(g.tickets.first.id));
    return AppCard(
      onTap: open,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: c.primaryTint, borderRadius: BorderRadius.circular(12)),
                child: Icon(LucideIcons.qrCode, size: 28, color: c.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.startsAt == null ? l.dateTba : Fmt.dateTime(g.startsAt!),
                        style: AppText.caption.copyWith(color: c.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(g.eventTitle ?? l.eventFallback, style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                    Text(
                      [?g.venue, l.ticketsCount(count), if (g.seats.isNotEmpty) g.seats.join(', ')].where((s) => s.isNotEmpty).join(' · '),
                      style: AppText.meta.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
              ),
              TagLabel(status, tone: tone),
            ],
          ),
          const SizedBox(height: 12),
          SecondaryButton(label: count == 1 ? l.viewTicket : l.viewTickets, icon: LucideIcons.qrCode, compact: true, onPressed: open),
        ],
      ),
    );
  }
}
