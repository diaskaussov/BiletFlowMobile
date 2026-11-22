import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/error/result.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/form_widgets.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../shared/domain/entities/insights.dart';
import '../domain/organizer_events_domain.dart';
import '../domain/organizer_operations_domain.dart';

// ─── O7 analytics ──────────────────────────────────────────────────────────

class AnalyticsData {
  const AnalyticsData({required this.analytics, required this.sales, this.overview});

  final EventAnalytics analytics;
  final List<({DateTime day, int tickets})> sales;
  final CheckInOverview? overview;
}

class AnalyticsViewModel extends Loadable<AnalyticsData> {
  AnalyticsViewModel({
    required int eventId,
    required GetManagedEvent event,
    required GetSalesOverTime sales,
    required GetCheckInOverview overview,
  }) : super(() async {
          final a = await event.analytics(eventId);
          if (a case Err(:final failure)) return Err(failure);
          return Ok(AnalyticsData(
            analytics: a.valueOrNull!,
            sales: (await sales(eventId)).valueOrNull ?? const [],
            overview: (await overview(eventId)).valueOrNull,
          ));
        });
}

/// O7 · Analytics (§4.15, UC11) — всё из заказов, билетов и проходов.
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Analytics', subtitle: 'From orders, tickets and check-ins', onBack: () => context.pop()),
            Expanded(
              child: LoadableView<AnalyticsData>(
                state: vm,
                builder: (context, d) {
                  final a = d.analytics;
                  final maxSold = a.byTicketType.fold<int>(1, (m, t) => t.sold > m ? t.sold : m);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 18, AppSpacing.sideLight, 24),
                    children: [
                      StatQuad(cells: [
                        (Fmt.count(a.ticketsSold), 'Sold'),
                        (Fmt.count(a.ticketsRemaining), 'Remaining'),
                        ('${a.percentageSold.round()}%', 'Of capacity'),
                        (Fmt.moneyShort(a.grossRevenue), 'Gross · demo'),
                      ]),
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('Sales over time · tickets per day'),
                      const SizedBox(height: 10),
                      if (d.sales.isEmpty)
                        Text('No completed orders yet.', style: AppText.bodySecondary.copyWith(color: AppColors.neutral600))
                      else
                        BarStrip(
                          values: [for (final s in d.sales) s.tickets],
                          startLabel: Fmt.date(d.sales.first.day),
                          endLabel: Fmt.date(d.sales.last.day),
                        ),
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('By ticket type'),
                      for (final t in a.byTicketType)
                        ShareRow(
                          label: t.name,
                          value: '${Fmt.count(t.sold)} · ${Fmt.money(t.revenue, freeWord: false)}',
                          ratio: t.sold / maxSold,
                        ),
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('Revenue · KZT, demonstration'),
                      const SizedBox(height: 8),
                      DetailGrid(rows: [
                        ('Gross sales', Fmt.money(a.grossRevenue, freeWord: false)),
                        ('Campaign discounts', '− ${Fmt.money(a.totalDiscounts, freeWord: false)}'),
                        ('Refunds', '− ${Fmt.money(a.totalRefunds, freeWord: false)}'),
                        ('Net · estimated payout', Fmt.money(a.netRevenue, freeWord: false)),
                        ('Orders', Fmt.count(a.totalOrders)),
                      ]),
                      if (a.campaigns.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.section),
                        const SectionLabel('Campaigns'),
                        const SizedBox(height: 8),
                        DetailGrid(rows: [
                          for (final c in a.campaigns)
                            (c.name, '${c.redemptions}${c.maxRedemptions == null ? '' : ' / ${c.maxRedemptions}'} redeemed'),
                        ]),
                      ],
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('Attendance'),
                      const SizedBox(height: 8),
                      Text('${a.checkInPercentage.round()}%', style: AppText.heroMetric.copyWith(color: AppColors.ink)),
                      Text('checked in', style: AppText.meta.copyWith(color: AppColors.neutral600)),
                      const SizedBox(height: 10),
                      DetailGrid(rows: [
                        ('Checked in', Fmt.count(a.checkedIn)),
                        ('Absent holders', Fmt.count(a.absent)),
                        if (d.overview != null) ('Reversals', Fmt.count(d.overview!.reversed)),
                      ]),
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

// ─── O9 timeline ───────────────────────────────────────────────────────────

class TimelineViewModel extends Loadable<List<AuditEntry>> {
  TimelineViewModel({required int eventId, required GetTimeline get}) : super(() => get(eventId));

  AuditKind? kind;

  void setKind(AuditKind? k) {
    kind = k;
    notifyListeners();
  }

  List<AuditEntry> get visible => [for (final e in data ?? const <AuditEntry>[]) if (kind == null || e.kind == kind) e];

  int count(AuditKind? k) => k == null ? (data?.length ?? 0) : (data ?? const []).where((e) => e.kind == k).length;
}

/// O9 · Activity timeline (§4.16, UC12) — только чтение.
class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TimelineViewModel>();
    final kinds = <AuditKind?>[null, ...AuditKind.values];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Activity timeline', subtitle: 'Audit trail', onBack: () => context.pop()),
            if (vm.data != null)
              UnderlineTabs(
                labels: [for (final k in kinds) '${k?.label ?? 'All'} · ${vm.count(k)}'],
                current: kinds.indexOf(vm.kind),
                onSelect: (i) => vm.setKind(kinds[i]),
              ),
            Expanded(
              child: LoadableView<List<AuditEntry>>(
                state: vm,
                builder: (context, _) => ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideList, vertical: 8),
                  children: [
                    for (final e in vm.visible)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 86,
                              child: Text(e.at == null ? '' : Fmt.shortDateTime(e.at!),
                                  style: AppText.detail.copyWith(color: AppColors.neutral600)),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.actionType.replaceAll('_', ' '), style: AppText.fieldLabel.copyWith(color: AppColors.accent700)),
                                  Text(e.description, style: AppText.bodySecondary.copyWith(color: AppColors.ink)),
                                  if (e.userId != null)
                                    Text('User #${e.userId}', style: AppText.meta.copyWith(color: AppColors.neutral500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text('Entries cannot be edited or deleted. Platform admins can read the same trail.',
                        style: AppText.finePrint.copyWith(color: AppColors.neutral600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
