import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/role_tab_bar.dart';
import '../../../app/routes.dart';
import '../../../core/di/injection.dart';
import '../../../core/presentation/failure_text.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/status_text.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../domain/organizer_events_domain.dart';
import 'managed_event_controller.dart';

/// Вкладки экрана события (чипсы M-B3).
enum EventSection { overview, tickets, seating, orders, promo, staff, sales, history, checkIn }

extension on EventSection {
  String label(AppLocalizations l) => switch (this) {
        EventSection.overview => l.secOverview,
        EventSection.tickets => l.secTickets,
        EventSection.seating => l.secSeating,
        EventSection.orders => l.secOrders,
        EventSection.promo => l.secPromo,
        EventSection.staff => l.secStaff,
        EventSection.sales => l.secSales,
        EventSection.history => l.secHistory,
        EventSection.checkIn => l.secCheckIn,
      };

  String route(int id) => switch (this) {
        EventSection.overview => Routes.manageEvent(id),
        EventSection.tickets => Routes.ticketTypes(id),
        EventSection.seating => Routes.seating(id),
        EventSection.orders => Routes.eventAttendees(id),
        EventSection.promo => Routes.campaigns(id),
        EventSection.staff => Routes.staff(id),
        EventSection.sales => Routes.activation(id),
        EventSection.history => Routes.history(id),
        EventSection.checkIn => Routes.analytics(id),
      };
}

/// Каркас вкладок события организатора: «Мои события» › название,
/// карточка с меню действий, чипсы разделов и плавающая навигация.
class EventShell extends StatefulWidget {
  const EventShell({
    super.key,
    required this.eventId,
    required this.section,
    required this.body,
    this.footer,
    this.onChanged,
  });

  final int eventId;
  final EventSection section;
  final Widget body;

  /// Закреплённые снизу кнопки (сохранить схему и т.п.).
  final Widget? footer;

  /// Событие изменилось через меню — страница может перечитать свои данные.
  final VoidCallback? onChanged;

  @override
  State<EventShell> createState() => _EventShellState();
}

class _EventShellState extends State<EventShell> {
  final _events = sl<ManagedEventController>();
  final _chips = ScrollController();

  @override
  void initState() {
    super.initState();
    _events.ensure(widget.eventId);
    // Активный чип должен быть виден, даже если он в конце ряда.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chips.hasClients) return;
      final i = EventSection.values.indexOf(widget.section);
      _chips.jumpTo((i * 92.0 - 60).clamp(0, _chips.position.maxScrollExtent));
    });
  }

  @override
  void dispose() {
    _chips.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return ListenableBuilder(
      listenable: _events,
      builder: (context, _) {
        final e = _events.of(widget.eventId);
        final sections = [
          for (final s in EventSection.values)
            if (s != EventSection.seating || (e?.assignedSeating ?? false)) s,
        ];
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  subtitle: l.myEvents,
                  title: e?.title ?? l.eventFallback,
                  onBack: () => context.canPop() ? context.pop() : context.go(Routes.organizer),
                ),
                if (e != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 12),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          EventImage(url: e.imageUrl, label: e.title, height: 56, width: 56, radius: 12),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  [if (e.startsAt != null) Fmt.dateTime(e.startsAt!), if (e.venueLine.isNotEmpty) e.venueLine].join(' · '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.caption.copyWith(color: c.textMuted),
                                ),
                                const SizedBox(height: 6),
                                TagLabel(e.status.text(l), tone: e.status.tone),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: l.eventActions,
                            onPressed: _events.isBusy ? null : () => showEventMenu(context, e, onChanged: widget.onChanged),
                            icon: Icon(LucideIcons.ellipsisVertical, size: 20, color: c.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    controller: _chips,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.side),
                    itemCount: sections.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final s = sections[i];
                      return FilterChipPill(
                        label: s.label(l),
                        active: s == widget.section,
                        onTap: () {
                          if (s != widget.section) context.replace(s.route(widget.eventId));
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: widget.body),
                ?widget.footer,
              ],
            ),
          ),
          bottomNavigationBar: const RoleTabBar(tabs: RoleTabs.organizer, current: Routes.organizer),
        );
      },
    );
  }
}

/// Меню «⋮» события: редактировать, копия, публикация, отмена.
Future<void> showEventMenu(BuildContext context, EventInfo e, {VoidCallback? onChanged}) async {
  final l = context.l10n;
  final action = await showModalBottomSheet<Object>(
    context: context,
    builder: (sheet) {
      final c = sheet.colors;
      Widget item(IconData icon, String label, Object value, [Color? color]) => ListTile(
            leading: Icon(icon, size: 20, color: color ?? c.text),
            title: Text(label, style: AppText.bodyStrong.copyWith(color: color ?? c.text, fontSize: 15)),
            onTap: () => Navigator.of(sheet).pop(value),
          );
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 8),
              child: Text(l.eventActions, style: AppText.headerTitle.copyWith(color: c.text)),
            ),
            item(LucideIcons.pencil, l.actEdit, 'edit'),
            item(LucideIcons.copy, l.actDuplicate, EventAction.duplicate),
            if (e.status == EventStatus.draft) item(LucideIcons.send, l.actPublish, EventAction.publish),
            if (e.status == EventStatus.published) item(LucideIcons.eyeOff, l.actUnpublish, EventAction.unpublish),
            if (e.status != EventStatus.cancelled && e.status != EventStatus.completed)
              item(LucideIcons.ban, l.actCancelEvent, EventAction.cancel, c.danger),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
  if (!context.mounted || action == null) return;
  if (action == 'edit') {
    await context.push(Routes.editEvent(e.id));
    await sl<ManagedEventController>().ensure(e.id, force: true);
    onChanged?.call();
    return;
  }
  await runEventAction(context, e, action as EventAction, onDone: onChanged);
}

/// Выполняет действие над событием с подтверждением отмены и сообщением.
Future<void> runEventAction(BuildContext context, EventInfo e, EventAction action, {VoidCallback? onDone}) async {
  final l = context.l10n;
  if (action == EventAction.cancel) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.cancelEventTitle),
        content: Text(l.cancelEventBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.actionKeep)),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: Text(l.actCancelEvent, style: TextStyle(color: d.colors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
  }
  final (result, failure) = await sl<ManagedEventController>().act(e, action);
  if (!context.mounted) return;
  if (failure != null) {
    showMessage(context, failure.text(context));
    return;
  }
  showMessage(context, switch (action) {
    EventAction.publish => l.publishedToast,
    EventAction.unpublish => l.unpublishedToast,
    EventAction.cancel => l.cancelledToast,
    EventAction.duplicate => l.duplicatedToast,
  });
  onDone?.call();
  if (action == EventAction.duplicate && result != null) context.push(Routes.manageEvent(result.id));
}

/// Отступы содержимого вкладки события.
const sectionPadding = EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24);
