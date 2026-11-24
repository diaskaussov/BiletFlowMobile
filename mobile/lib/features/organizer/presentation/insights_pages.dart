import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/error/result.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/presentation/status_text.dart';
import '../../../core/theme/app_palette.dart';
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
import 'event_shell.dart';

// ─── вкладка «Вход» ────────────────────────────────────────────────────────

class AnalyticsData {
  const AnalyticsData({required this.analytics, this.overview});

  final EventAnalytics analytics;
  final CheckInOverview? overview;
}

class AnalyticsViewModel extends Loadable<AnalyticsData> {
  AnalyticsViewModel({
    required this.eventId,
    required GetManagedEvent event,
    required GetCheckInOverview overview,
  }) : super(() async {
          final a = await event.analytics(eventId);
          if (a case Err(:final failure)) return Err(failure);
          return Ok(AnalyticsData(analytics: a.valueOrNull!, overview: (await overview(eventId)).valueOrNull));
        });

  final int eventId;
}

/// Вход: явка, по типам билетов, последние проходы (§4.8, §4.15).
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<AnalyticsViewModel>();
    return EventShell(
      eventId: vm.eventId,
      section: EventSection.checkIn,
      body: LoadableView<AnalyticsData>(
        state: vm,
        builder: (context, d) {
          final a = d.analytics;
          final o = d.overview;
          final registered = o?.registered ?? a.totalAttendees;
          final inside = o?.checkedIn ?? a.checkedIn;
          return RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: sectionPadding,
              children: [
                AppCard(
                  radius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.kpiAttendance, style: AppText.label.copyWith(color: c.textMuted)),
                      const SizedBox(height: 4),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(Fmt.percent(inside, registered), style: AppText.heroMetric.copyWith(color: c.text, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(l.enteredOf(inside, registered), style: AppText.bodySecondary.copyWith(color: c.textMuted)),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      ProgressStrip(value: registered == 0 ? 0 : inside / registered, height: 10, color: c.success),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                StatQuad(cells: [
                  (Fmt.count(inside), l.entered),
                  (Fmt.count(o?.notCheckedIn ?? a.absent), l.notArrived),
                  (Fmt.count((o?.refunded ?? 0) + (o?.cancelled ?? 0)), l.refundedVoid),
                  (Fmt.count(o?.reversed ?? 0), l.reversals),
                ]),
                if (o != null && o.byTicketType.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.section),
                  SectionLabel(l.byTicketType),
                  const SizedBox(height: 4),
                  for (final (i, t) in o.byTicketType.indexed)
                    ShareRow(
                      label: t.name,
                      value: '${t.checkedIn} / ${t.registered}',
                      ratio: t.registered == 0 ? 0 : t.checkedIn / t.registered,
                      color: AppPalette.seriesAt(i),
                    ),
                ],
                const SizedBox(height: AppSpacing.section),
                SectionLabel(l.recentEntries),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: (o?.recent ?? const []).isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(l.noEntriesYet, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
                        )
                      : Column(children: [
                          for (final (i, r) in o!.recent.indexed)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(border: i == o.recent.length - 1 ? null : Border(bottom: BorderSide(color: c.border))),
                              child: Row(children: [
                                InitialAvatar(r.who, size: 36),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.who, style: AppText.cardTitle.copyWith(color: c.text, fontWeight: FontWeight.w600)),
                                      if (r.by != null) Text(r.by!, style: AppText.finePrint.copyWith(color: c.textMuted)),
                                    ],
                                  ),
                                ),
                                if (r.at != null) Text(Fmt.time(r.at!), style: AppText.statusStrip.copyWith(color: c.textMuted)),
                              ]),
                            ),
                        ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── вкладка «История» ─────────────────────────────────────────────────────

class TimelineViewModel extends Loadable<List<AuditEntry>> {
  TimelineViewModel({required this.eventId, required GetTimeline get}) : super(() => get(eventId));

  final int eventId;
  AuditKind? kind;

  void setKind(AuditKind? k) {
    kind = k;
    notifyListeners();
  }

  List<AuditEntry> get visible => [for (final e in data ?? const <AuditEntry>[]) if (kind == null || e.kind == kind) e];

  int count(AuditKind? k) => k == null ? (data?.length ?? 0) : (data ?? const []).where((e) => e.kind == k).length;
}

/// История события — журнал действий только для чтения (§4.16, UC12).
class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<TimelineViewModel>();
    final kinds = <AuditKind?>[null, for (final k in AuditKind.values) if (vm.count(k) > 0 || vm.kind == k) k];
    return EventShell(
      eventId: vm.eventId,
      section: EventSection.history,
      body: LoadableView<List<AuditEntry>>(
        state: vm,
        builder: (context, _) => ListView(
          padding: sectionPadding,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(children: [
                for (final k in kinds) ...[
                  FilterChipPill(
                    label: k == null ? l.allN(vm.count(null)) : '${k.text(l)} · ${vm.count(k)}',
                    active: vm.kind == k,
                    onTap: () => vm.setKind(k),
                  ),
                  const SizedBox(width: 8),
                ],
              ]),
            ),
            const SizedBox(height: 16),
            if (vm.visible.isEmpty) Text(l.noHistory, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
            for (final (i, e) in vm.visible.indexed)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 20,
                      child: Column(children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
                        ),
                        if (i != vm.visible.length - 1) Expanded(child: Container(width: 2, color: c.border)),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              [if (e.at != null) Fmt.shortDateTime(e.at!), e.kind.text(l), if (e.userId != null) l.userNo('${e.userId}')].join(' · '),
                              style: AppText.caption.copyWith(color: c.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(e.description, style: AppText.bodySecondary.copyWith(color: c.text)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(l.auditTrailNote, style: AppText.finePrint.copyWith(color: c.textMuted)),
          ],
        ),
      ),
    );
  }
}
