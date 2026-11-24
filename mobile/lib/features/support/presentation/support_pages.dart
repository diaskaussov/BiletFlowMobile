import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/role_tab_bar.dart';
import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
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
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/support.dart';
import '../../auth/domain/entities/user_session.dart';
import '../../auth/presentation/controllers/session_controller.dart';
import '../domain/support_domain.dart';
import '../../../core/presentation/safe_notifier.dart';
import '../../../core/presentation/failure_text.dart';

// ─── list ──────────────────────────────────────────────────────────────────

class SupportListViewModel extends Loadable<List<SupportCaseInfo>> {
  SupportListViewModel(super.fetch);

  int tab = 0;

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  List<SupportCaseInfo> get visible => switch (tab) {
        0 => [for (final c in data ?? const <SupportCaseInfo>[]) if (c.status != CaseStatus.resolved) c],
        _ => [for (final c in data ?? const <SupportCaseInfo>[]) if (c.status == CaseStatus.resolved) c],
      };
}

/// Список обращений: участнику — его обращения, организатору — входящие.
class SupportListPage extends StatelessWidget {
  const SupportListPage({super.key, required this.base});

  final String base;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<SupportListViewModel>();
    final role = context.watch<SessionController>().session?.role ?? UserRole.unknown;
    final all = vm.data ?? const <SupportCaseInfo>[];
    final open = all.where((x) => x.status != CaseStatus.resolved).length;
    return RoleScaffold(
      tabs: RoleTabs.of(role),
      current: base,
      title: role == UserRole.organizer ? l.supportInbox : l.navSupport,
      action: Material(
        color: c.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            await context.push(Routes.newSupportCase(base));
            vm.load();
          },
          child: Tooltip(
            message: l.newCase,
            child: SizedBox.square(dimension: 44, child: Icon(LucideIcons.plus, size: 20, color: c.onPrimary)),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.side, 4, AppSpacing.side, 12),
            child: Row(children: [
              FilterChipPill(label: l.openN(open), active: vm.tab == 0, onTap: () => vm.setTab(0)),
              const SizedBox(width: 8),
              FilterChipPill(label: l.resolvedN(all.length - open), active: vm.tab == 1, onTap: () => vm.setTab(1)),
            ]),
          ),
          Expanded(
            child: LoadableView<List<SupportCaseInfo>>(
              state: vm,
              builder: (context, _) {
                final list = vm.visible;
                if (list.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.side),
                    children: [
                      MessageView(
                        icon: LucideIcons.lifeBuoy,
                        title: vm.tab == 0 ? l.noOpenCases : l.noResolvedCases,
                        message: role == UserRole.organizer ? l.supportEmptyOrganizer : l.supportEmptyAttendee,
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  onRefresh: vm.load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final k = list[i];
                      return AppCard(
                        onTap: () async {
                          await context.push(Routes.supportCase(base, k.id), extra: k);
                          vm.load();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text('${k.number} · ${k.category.text(l)}',
                                    style: AppText.meta.copyWith(color: c.textMuted, fontWeight: FontWeight.w600)),
                              ),
                              TagLabel(k.status.text(l), tone: k.status.tone),
                            ]),
                            const SizedBox(height: 8),
                            Text(k.subject, style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (role == UserRole.organizer && k.requesterName != null) k.requesterName!,
                                ?k.eventTitle,
                                if (k.updatedAt != null) Fmt.ago(k.updatedAt!),
                              ].join(' · '),
                              style: AppText.meta.copyWith(color: c.textMuted),
                            ),
                          ],
                        ),
                      );
                    },
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

// ─── new case ──────────────────────────────────────────────────────────────

class NewCaseViewModel extends ChangeNotifier with SafeNotifier {
  NewCaseViewModel(
    this._open, {
    this.eventId,
    this.orderId,
    this.about,
    CaseCategory? category,
    this._contexts,
  })  : category = category ?? (orderId != null ? CaseCategory.ticketDelivery : CaseCategory.eventInfo) {
    if (needsPicker) _loadContexts();
  }

  final OpenCase _open;
  final GetCaseContexts? _contexts;
  final int? eventId;
  final int? orderId;
  final String? about;
  CaseCategory category;
  bool busy = false;
  Failure? error;

  /// Участнику без контекста нужно выбрать событие.
  bool get needsPicker => _contexts != null && eventId == null && orderId == null;
  List<CaseContext>? choices;
  CaseContext? selected;

  Future<void> _loadContexts() async {
    final r = await _contexts!();
    choices = r.valueOrNull ?? const [];
    if (choices!.length == 1) selected = choices!.first;
    notifyListeners();
  }

  void select(CaseContext c) {
    selected = c;
    notifyListeners();
  }

  void setCategory(CaseCategory c) {
    category = c;
    notifyListeners();
  }

  Future<SupportCaseInfo?> submit(String subject, String message) async {
    busy = true;
    error = null;
    notifyListeners();
    final r = await _open(
      NewCase(
        category: category,
        subject: subject,
        message: message,
        eventId: eventId ?? selected?.eventId,
        orderId: orderId ?? selected?.orderId,
      ),
      requireContext: _contexts != null,
    );
    busy = false;
    notifyListeners();
    switch (r) {
      case Ok(:final value):
        return value;
      case Err(:final failure):
        error = failure;
        notifyListeners();
        return null;
    }
  }
}

class NewCasePage extends StatefulWidget {
  const NewCasePage({super.key, required this.categories});

  /// Категории для роли: участнику — про билеты, организатору — про аккаунт и выплаты.
  final List<CaseCategory> categories;

  @override
  State<NewCasePage> createState() => _NewCasePageState();
}

class _NewCasePageState extends State<NewCasePage> {
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<NewCaseViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(subtitle: vm.about, title: l.newCase, onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 20),
                children: [
                  if (vm.needsPicker) ...[
                    SectionLabel(l.eventLabel),
                    const SizedBox(height: 8),
                    if (vm.choices == null)
                      const LinearProgressIndicator(minHeight: 2)
                    else if (vm.choices!.isEmpty)
                      InfoBanner(text: l.noCaseContext, tone: Tone.info)
                    else
                      ChoiceChips<CaseContext?>(
                        options: vm.choices!,
                        selected: vm.selected,
                        label: (x) => x?.eventTitle ?? '',
                        onSelected: (x) => vm.select(x!),
                      ),
                    const SizedBox(height: 20),
                  ],
                  SectionLabel(l.categoryLabel),
                  const SizedBox(height: 8),
                  ChoiceChips<CaseCategory>(
                    options: widget.categories,
                    selected: vm.category,
                    label: (x) => x.text(l),
                    onSelected: vm.setCategory,
                  ),
                  const SizedBox(height: 20),
                  LabeledTextField(label: l.subjectLabel, controller: _subject, hintText: l.subjectHint),
                  const SizedBox(height: 14),
                  LabeledTextField(label: l.messageLabel, controller: _message, maxLines: 6),
                  if (vm.eventId != null || vm.orderId != null) ...[
                    const SizedBox(height: 10),
                    Text(vm.orderId != null ? l.orderAttached : l.eventAttached, style: AppText.finePrint.copyWith(color: c.textMuted)),
                  ],
                  if (vm.error != null) ...[
                    const SizedBox(height: 12),
                    InfoBanner(text: vm.error!.text(context), tone: Tone.danger),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 16),
              child: PrimaryButton(
                label: l.actionSend,
                icon: LucideIcons.send,
                isLoading: vm.busy,
                onPressed: () async {
                  final created = await vm.submit(_subject.text, _message.text);
                  if (created != null && context.mounted) {
                    showMessage(context, l.caseOpened(created.number));
                    context.pop(created);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── thread ────────────────────────────────────────────────────────────────

class SupportThreadViewModel extends Loadable<List<SupportMessageInfo>> {
  SupportThreadViewModel({
    required this.caseId,
    required this.info,
    required GetCaseMessages messages,
    required this._reply,
    required this._status,
  })  : super(() => messages(caseId));

  final int caseId;
  SupportCaseInfo? info;
  final ReplyToCase _reply;
  final ChangeCaseStatus _status;

  Future<Failure?> send(String text) =>
      run(() => _reply(caseId, text), onOk: (SupportMessageInfo m) => setData([...?data, m]));

  Future<Failure?> setStatus(CaseStatus s) => run(() => _status(caseId, s), onOk: (_) {
        final i = info;
        if (i != null) {
          info = SupportCaseInfo(
            id: i.id,
            subject: i.subject,
            category: i.category,
            status: s,
            requesterName: i.requesterName,
            requesterId: i.requesterId,
            eventId: i.eventId,
            eventTitle: i.eventTitle,
            orderId: i.orderId,
            assignedTo: i.assignedTo,
            createdAt: i.createdAt,
            updatedAt: DateTime.now(),
          );
        }
      });
}

/// W9 · Переписка по обращению.
class SupportThreadPage extends StatefulWidget {
  const SupportThreadPage({super.key});

  @override
  State<SupportThreadPage> createState() => _SupportThreadPageState();
}

class _SupportThreadPageState extends State<SupportThreadPage> {
  final _reply = TextEditingController();

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final vm = context.watch<SupportThreadViewModel>();
    final session = context.watch<SessionController>().session;
    final c = vm.info;
    final isOrganizer = session?.role == UserRole.organizer;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(subtitle: c?.number, title: c?.subject ?? l.caseFallback, onBack: () => context.pop()),
            Expanded(
              child: LoadableView<List<SupportMessageInfo>>(
                state: vm,
                builder: (context, messages) => ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 16),
                  children: [
                    if (c != null) ...[
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TagLabel(c.status.text(l), tone: c.status.tone),
                            const SizedBox(height: 10),
                            DetailGrid(rows: [
                              (l.categoryLabel, c.category.text(l)),
                              if (c.eventTitle != null) (l.eventLabel, c.eventTitle!),
                              if (c.orderId != null) (l.orderTitle, l.orderNo('${c.orderId}')),
                              if (c.requesterName != null) (l.openedBy, c.requesterName!),
                              if (c.assignedTo != null) (l.assignedLabel, c.assignedTo!),
                              if (c.createdAt != null) (l.openedLabel, Fmt.shortDateTime(c.createdAt!)),
                            ]),
                          ],
                        ),
                      ),
                      if (isOrganizer) ...[
                        const SizedBox(height: 12),
                        ChoiceChips<CaseStatus>(
                          options: CaseStatus.values,
                          selected: c.status,
                          label: (s) => s.text(l),
                          onSelected: (s) async {
                            final f = await vm.setStatus(s);
                            if (context.mounted) reportResult(context, f);
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                    if (messages.isEmpty) Text(l.noMessages, style: AppText.bodySecondary.copyWith(color: colors.textMuted)),
                    for (final m in messages) _Bubble(message: m, mine: m.senderId == session?.userId),
                    const SizedBox(height: 8),
                    Text(l.repliesNote, textAlign: TextAlign.center, style: AppText.finePrint.copyWith(color: colors.textMuted)),
                    if (!isOrganizer && c != null && c.status != CaseStatus.resolved)
                      GhostButton(
                        label: l.markResolved,
                        icon: LucideIcons.circleCheck,
                        onPressed: () async {
                          final f = await vm.setStatus(CaseStatus.resolved);
                          if (context.mounted) reportResult(context, f);
                        },
                      ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: colors.surface, border: Border(top: BorderSide(color: colors.border))),
              padding: const EdgeInsets.fromLTRB(AppSpacing.side, 10, AppSpacing.side, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: LabeledTextField(controller: _reply, compact: true, hintText: l.replyHint, maxLines: 3)),
                  const SizedBox(width: 8),
                  Material(
                    color: colors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: vm.isBusy
                          ? null
                          : () async {
                              final f = await vm.send(_reply.text);
                              if (f == null) _reply.clear();
                              if (context.mounted) reportResult(context, f);
                            },
                      child: Tooltip(
                        message: l.actionSend,
                        child: SizedBox.square(
                          dimension: 48,
                          child: vm.isBusy
                              ? Padding(padding: const EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary))
                              : Icon(LucideIcons.send, size: 20, color: colors.onPrimary),
                        ),
                      ),
                    ),
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final SupportMessageInfo message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final m = message;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 10, left: mine ? 48 : 0, right: mine ? 0 : 48),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: mine ? c.primary : c.surface,
          border: mine ? null : Border.all(color: c.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 6),
            bottomRight: Radius.circular(mine ? 6 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [mine ? l.you : m.senderName, if (m.createdAt != null) Fmt.shortDateTime(m.createdAt!)].join(' · '),
              style: AppText.caption.copyWith(color: mine ? c.onPrimary.withValues(alpha: 0.8) : c.textMuted),
            ),
            const SizedBox(height: 4),
            Text(m.text, style: AppText.body.copyWith(color: mine ? c.onPrimary : c.text)),
          ],
        ),
      ),
    );
  }
}
