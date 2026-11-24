import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/result.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/form_widgets.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../../../shared/domain/entities/insights.dart';
import '../domain/organizer_events_domain.dart';
import '../domain/organizer_operations_domain.dart';
import 'event_shell.dart';

class EventHub {
  const EventHub({required this.event, this.analytics, this.sales = const []});

  final EventInfo event;
  final EventAnalytics? analytics;
  final List<({DateTime day, int tickets})> sales;
}

class EventHubViewModel extends Loadable<EventHub> {
  EventHubViewModel({required this.eventId, required GetManagedEvent get, required GetSalesOverTime sales})
      : super(() async {
          final r = await get(eventId);
          if (r case Err(:final failure)) return Err(failure);
          final a = (await get.analytics(eventId)).valueOrNull;
          final s = (await sales(eventId)).valueOrNull ?? const [];
          return Ok(EventHub(event: r.valueOrNull!, analytics: a, sales: s));
        });

  final int eventId;
}

/// M-B3 · Обзор события: предупреждение об активации, KPI, продажи по типам,
/// эффективность промокодов.
class EventHubPage extends StatelessWidget {
  const EventHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<EventHubViewModel>();
    return EventShell(
      eventId: vm.eventId,
      section: EventSection.overview,
      onChanged: vm.load,
      body: LoadableView<EventHub>(
        state: vm,
        builder: (context, hub) {
          final e = hub.event;
          final a = hub.analytics ?? const EventAnalytics();
          final capacity = e.capacity ?? a.totalCapacity;
          return RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: sectionPadding,
              children: [
                if (!e.paidSalesActivated && e.status != EventStatus.cancelled) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.warningSoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.warning.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(LucideIcons.triangleAlert, size: 20, color: c.warningText),
                            const SizedBox(width: 10),
                            Expanded(child: Text(l.salesNotActive, style: AppText.label.copyWith(color: c.warningText))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: c.warningStrong,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => context.replace(Routes.activation(e.id)),
                            child: Text(l.actActivate, style: AppText.bodyStrong.copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(children: [
                  _Kpi(label: l.kpiSold, value: '${Fmt.count(a.ticketsSold)} / ${Fmt.count(capacity)}', ratio: capacity == 0 ? 0 : a.ticketsSold / capacity),
                  const SizedBox(width: 10),
                  _Kpi(label: l.kpiGross, value: Fmt.money(a.grossRevenue, freeWord: false)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _Kpi(label: l.kpiNet, value: Fmt.money(a.netRevenue, freeWord: false)),
                  const SizedBox(width: 10),
                  _Kpi(label: l.kpiAttendance, value: '${a.checkInPercentage.round()}%'),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _Kpi(label: l.kpiOrders, value: Fmt.count(a.totalOrders), soft: true),
                  const SizedBox(width: 10),
                  _Kpi(label: l.kpiDiscounts, value: Fmt.money(a.totalDiscounts, freeWord: false), soft: true),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _Kpi(label: l.kpiRefunds, value: Fmt.money(a.totalRefunds, freeWord: false), soft: true),
                  const SizedBox(width: 10),
                  _Kpi(label: l.kpiRemaining, value: Fmt.count(a.ticketsRemaining), soft: true),
                ]),
                if (a.byTicketType.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.salesByType, style: AppText.sectionLabel.copyWith(color: c.text)),
                        for (final (i, t) in a.byTicketType.indexed) ...[
                          const SizedBox(height: 12),
                          _Bar(
                            label: t.name,
                            value: '${Fmt.count(t.sold)} / ${Fmt.count(t.quantity)}',
                            ratio: t.quantity == 0 ? 0 : t.sold / t.quantity,
                            color: AppPalette.seriesAt(i),
                            height: 10,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (hub.sales.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.salesOverTime, style: AppText.sectionLabel.copyWith(color: c.text)),
                        const SizedBox(height: 12),
                        BarStrip(
                          values: [for (final x in hub.sales) x.tickets],
                          startLabel: Fmt.date(hub.sales.first.day),
                          endLabel: Fmt.date(hub.sales.last.day),
                        ),
                      ],
                    ),
                  ),
                ],
                if (a.campaigns.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.promoEffect, style: AppText.sectionLabel.copyWith(color: c.text)),
                        for (final p in a.campaigns) ...[
                          const SizedBox(height: 12),
                          _Bar(
                            label: p.name,
                            value: p.maxRedemptions == null ? l.redeemed(p.redemptions) : l.redeemedOf('${p.redemptions}', '${p.maxRedemptions}'),
                            ratio: p.maxRedemptions == null || p.maxRedemptions == 0 ? (p.redemptions > 0 ? 1 : 0) : p.redemptions / p.maxRedemptions!,
                            color: c.primary,
                            height: 6,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, this.ratio, this.soft = false});

  final String label;
  final String value;
  final double? ratio;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: soft ? c.neutralSoft : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: soft ? null : Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.caption.copyWith(color: c.textMuted)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: AppText.headerTitle.copyWith(color: c.text, fontSize: soft ? 17 : 20)),
            ),
            if (ratio != null) ...[
              const SizedBox(height: 6),
              ProgressStrip(value: ratio!, height: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value, required this.ratio, required this.color, required this.height});

  final String label;
  final String value;
  final double ratio;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Text(label, style: AppText.bodyStrong.copyWith(color: c.text))),
          Text(value, style: AppText.label.copyWith(color: c.textMuted)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(children: [
            Container(height: height, color: color.withValues(alpha: 0.15)),
            FractionallySizedBox(widthFactor: ratio.clamp(0, 1), child: Container(height: height, color: color)),
          ]),
        ),
      ],
    );
  }
}
