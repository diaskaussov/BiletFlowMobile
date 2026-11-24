import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/role_tab_bar.dart';
import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_colors.dart';
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

/// Список обращений (W8 «Support cases» для участника, входящие организатора).
class SupportListPage extends StatelessWidget {
  const SupportListPage({super.key, required this.base});

  final String base;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SupportListViewModel>();
    final role = context.watch<SessionController>().session?.role ?? UserRole.unknown;
    final all = vm.data ?? const <SupportCaseInfo>[];
    final open = all.where((c) => c.status != CaseStatus.resolved).length;
    return RoleScaffold(
      tabs: RoleTabs.of(role),
      current: base,
      title: role == UserRole.organizer ? 'Support inbox' : 'Support',
      action: IconButton(
        tooltip: 'New case',
        onPressed: () async {
          await context.push(Routes.newSupportCase(base));
          vm.load();
        },
        icon: const Icon(Icons.add, color: AppColors.ink),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: UnderlineTabs(
              labels: ['Open · $open', 'Resolved · ${all.length - open}'],
              current: vm.tab,
              onSelect: vm.setTab,
            ),
          ),
          Expanded(
            child: LoadableView<List<SupportCaseInfo>>(
              state: vm,
              builder: (context, _) {
                final list = vm.visible;
                if (list.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.sideList),
                    children: [
                      MessageView(
                        icon: Icons.support_agent,
                        title: vm.tab == 0 ? 'No open cases' : 'Nothing resolved yet',
                        message: role == UserRole.organizer
                            ? 'Questions from attendees of your events and your own requests to the platform appear here.'
                            : 'Open a case from an event, an order or with the + button. Replies arrive here and by email.',
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideList),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final c = list[i];
                    return ListRow(
                      overline: '${c.number} · ${c.category.label.toUpperCase()}',
                      title: c.subject,
                      subtitle: [
                        if (role == UserRole.organizer && c.requesterName != null) c.requesterName!,
                        ?c.eventTitle,
                        if (c.updatedAt != null) Fmt.ago(c.updatedAt!),
                      ].join(' · '),
                      trailing: TagLabel(c.status.label, filled: c.status != CaseStatus.resolved),
                      onTap: () async {
                        await context.push(Routes.supportCase(base, c.id), extra: c);
                        vm.load();
                      },
                    );
                  },
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
  String? error;

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
        error = failure.message;
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
    final vm = context.watch<NewCaseViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'New support case', subtitle: vm.about, onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 20, AppSpacing.sideLight, 20),
                children: [
                  if (vm.needsPicker) ...[
                    const SectionLabel('Event'),
                    const SizedBox(height: 8),
                    if (vm.choices == null)
                      const LinearProgressIndicator(minHeight: 2)
                    else if (vm.choices!.isEmpty)
                      Text(
                        'Support cases go to the organizer of an event. Register for or buy a ticket first, '
                        'then open the case from that event or order.',
                        style: AppText.bodySecondary.copyWith(color: AppColors.ink),
                      )
                    else
                      ChoiceChips<CaseContext?>(
                        options: vm.choices!,
                        selected: vm.selected,
                        label: (c) => c?.eventTitle ?? '',
                        onSelected: (c) => vm.select(c!),
                      ),
                    const SizedBox(height: 18),
                  ],
                  const SectionLabel('Category'),
                  const SizedBox(height: 8),
                  ChoiceChips<CaseCategory>(
                    options: widget.categories,
                    selected: vm.category,
                    label: (c) => c.label,
                    onSelected: vm.setCategory,
                  ),
                  const SizedBox(height: 18),
                  LabeledTextField(label: 'Subject', controller: _subject, hintText: 'Second ticket did not arrive'),
                  const SizedBox(height: 14),
                  LabeledTextField(label: 'Message', controller: _message, maxLines: 6),
                  const SizedBox(height: 14),
                  if (vm.eventId != null || vm.orderId != null)
                    Text(
                      'The ${vm.orderId != null ? 'order' : 'event'} is attached automatically, so support sees the context.',
                      style: AppText.finePrint.copyWith(color: AppColors.neutral600),
                    ),
                  if (vm.error != null) ...[
                    const SizedBox(height: 10),
                    Text(vm.error!, style: AppText.bodySecondary.copyWith(color: AppColors.ink)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
              child: PrimaryButton(
                label: 'Send',
                isLoading: vm.busy,
                onPressed: () async {
                  final created = await vm.submit(_subject.text, _message.text);
                  if (created != null && context.mounted) {
                    showMessage(context, 'Case ${created.number} opened.');
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

/// W9 · Support case thread
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
    final vm = context.watch<SupportThreadViewModel>();
    final session = context.watch<SessionController>().session;
    final c = vm.info;
    final isOrganizer = session?.role == UserRole.organizer;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: c?.subject ?? 'Case',
              subtitle: c == null ? null : '${c.number} · ${c.status.label}',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: LoadableView<List<SupportMessageInfo>>(
                state: vm,
                builder: (context, messages) => ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 16, AppSpacing.sideLight, 16),
                  children: [
                    if (c != null) ...[
                      DetailGrid(rows: [
                        ('Category', c.category.label),
                        if (c.eventTitle != null) ('Event', c.eventTitle!),
                        if (c.orderId != null) ('Order', 'ORD-${c.orderId.toString().padLeft(4, '0')}'),
                        if (c.requesterName != null) ('Opened by', c.requesterName!),
                        if (c.assignedTo != null) ('Assigned', c.assignedTo!),
                        if (c.createdAt != null) ('Opened', Fmt.shortDateTime(c.createdAt!)),
                      ]),
                      const SizedBox(height: 14),
                      if (isOrganizer)
                        ChoiceChips<CaseStatus>(
                          options: CaseStatus.values,
                          selected: c.status,
                          label: (s) => s.label,
                          onSelected: (s) async {
                            final f = await vm.setStatus(s);
                            if (context.mounted) reportResult(context, f);
                          },
                        ),
                      const Divider(height: 28),
                    ],
                    if (messages.isEmpty)
                      Text('No messages yet.', style: AppText.bodySecondary.copyWith(color: AppColors.neutral600)),
                    for (final m in messages) _Bubble(message: m, mine: m.senderId == session?.userId),
                    const SizedBox(height: 8),
                    Text(
                      'Replies arrive by email and in your account. Messages are asynchronous — nobody has to be online.',
                      style: AppText.finePrint.copyWith(color: AppColors.neutral600),
                    ),
                    if (!isOrganizer && c != null && c.status != CaseStatus.resolved)
                      GhostButton(
                        label: 'Mark as resolved',
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
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 10, AppSpacing.sideLight, AppSpacing.bottomClearance),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: LabeledTextField(controller: _reply, hintText: 'Write a reply…', maxLines: 3)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 84,
                    child: PrimaryButton(
                      label: 'Send',
                      isLoading: vm.isBusy,
                      onPressed: () async {
                        final f = await vm.send(_reply.text);
                        if (f == null) _reply.clear();
                        if (context.mounted) reportResult(context, f);
                      },
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
    final m = message;
    return Container(
      margin: EdgeInsets.only(bottom: 12, left: mine ? 40 : 0, right: mine ? 0 : 40),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mine ? AppColors.accent100 : AppColors.paper,
        border: Border.all(color: mine ? AppColors.accent300 : AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${mine ? 'YOU' : m.senderName.toUpperCase()}'
            '${m.createdAt == null ? '' : ' · ${Fmt.shortDateTime(m.createdAt!).toUpperCase()}'}',
            style: AppText.fieldLabel.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: 4),
          Text(m.text, style: AppText.body.copyWith(color: AppColors.ink)),
        ],
      ),
    );
  }
}
