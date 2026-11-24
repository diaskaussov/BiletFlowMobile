import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/di/injection.dart';
import '../../../core/error/result.dart';
import '../../../core/presentation/failure_text.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/insights.dart';
import '../../../shared/domain/entities/people.dart';
import '../domain/organizer_events_domain.dart';
import 'event_shell.dart';
import 'managed_event_controller.dart';

// ─── M-B5 схема зала ──────────────────────────────────────────────────────

class SeatingData {
  const SeatingData({required this.seats, required this.types});

  final List<SeatInfo> seats;
  final List<TicketTypeInfo> types;
}

class SeatingViewModel extends Loadable<SeatingData> {
  SeatingViewModel({required this.eventId, required ManageSeatMap seats, required ManageTicketTypes types})
      : _seats = seats,
        super(() async {
          final s = await seats.load(eventId);
          if (s case Err(:final failure)) return Err(failure);
          final t = await types.list(eventId);
          if (t case Err(:final failure)) return Err(failure);
          return Ok(SeatingData(seats: s.valueOrNull!, types: t.valueOrNull!.where((x) => !x.hidden).toList()));
        });

  final int eventId;
  final ManageSeatMap _seats;

  /// Редактируемая схема; ключи держат состояние полей при удалении секций.
  final List<SectionDraft> sections = [];
  final List<int> keys = [];
  int _nextKey = 0;
  int? expanded;
  bool dirty = false;

  @override
  Future<void> load() async {
    await super.load();
    final d = data;
    if (d != null && !dirty) {
      sections
        ..clear()
        ..addAll(SectionDraft.fromSeats(d.seats));
      keys
        ..clear()
        ..addAll([for (final _ in sections) _nextKey++]);
      expanded = sections.isEmpty ? null : expanded;
      notifyListeners();
    }
  }

  List<TicketTypeInfo> get types => data?.types ?? const [];

  int get totalSeats => sections.fold(0, (s, x) => s + x.seats);

  int get soldSeats => (data?.seats ?? const []).where((s) => s.status == SeatStatus.sold).length;

  List<({String name, int seats, int quantity})> get overflow => seatOverflow(sections, types);

  int typeIndex(int id) => types.indexWhere((t) => t.id == id);

  void toggle(int i) {
    expanded = expanded == i ? null : i;
    notifyListeners();
  }

  void update(int i, SectionDraft s) {
    sections[i] = s;
    dirty = true;
    notifyListeners();
  }

  void add(String name) {
    if (types.isEmpty) return;
    sections.add(SectionDraft(name: name, ticketTypeId: types.first.id, rows: 5, seatsPerRow: 10));
    keys.add(_nextKey++);
    expanded = sections.length - 1;
    dirty = true;
    notifyListeners();
  }

  void remove(int i) {
    sections.removeAt(i);
    keys.removeAt(i);
    expanded = null;
    dirty = true;
    notifyListeners();
  }

  Future<Failure?> save() async {
    final f = await run(() => _seats.save(eventId, sections, types: types));
    if (f == null) {
      dirty = false;
      await load();
    }
    return f;
  }

  Future<Failure?> clear() async {
    final f = await run(() => _seats.clear(eventId));
    if (f == null) {
      dirty = false;
      await load();
    }
    return f;
  }
}

/// M-B5 · Схема зала (§4.3.1): превью, секции «быстро» или по рядам.
class SeatingPage extends StatelessWidget {
  const SeatingPage({super.key});

  Future<void> _delete(BuildContext context, SeatingViewModel vm) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.deleteMapTitle),
        content: Text(l.deleteMapBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.actionCancel)),
          TextButton(onPressed: () => Navigator.pop(d, true), child: Text(l.actionDelete, style: TextStyle(color: d.colors.danger))),
        ],
      ),
    );
    if (ok != true) return;
    final f = await vm.clear();
    if (context.mounted) showMessage(context, f?.text(context) ?? l.mapDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<SeatingViewModel>();
    final hasMap = (vm.data?.seats ?? const []).isNotEmpty;
    return EventShell(
      eventId: vm.eventId,
      section: EventSection.seating,
      body: LoadableView<SeatingData>(
        state: vm,
        refreshable: false,
        builder: (context, d) {
          final over = vm.overflow;
          return ListView(
            padding: sectionPadding,
            children: [
              if (over.isNotEmpty) ...[
                InfoBanner(
                  icon: LucideIcons.circleAlert,
                  tone: Tone.danger,
                  text: l.errSeatsOverTickets(over.first.name, over.first.seats, over.first.quantity),
                ),
                const SizedBox(height: 16),
              ],
              if (vm.sections.isNotEmpty) ...[
                AppCard(
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(child: Text(l.seatPreview(vm.totalSeats), style: AppText.cardTitle.copyWith(color: c.text))),
                        InkWell(
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) => Dialog.fullscreen(
                              backgroundColor: c.bg,
                              child: SafeArea(
                                child: Stack(children: [
                                  InteractiveViewer(
                                    maxScale: 6,
                                    child: Center(child: Padding(padding: const EdgeInsets.all(24), child: _Preview(vm: vm))),
                                  ),
                                  Positioned(right: 12, top: 8, child: CircleIconButton(icon: LucideIcons.x, onPressed: () => Navigator.of(context).pop())),
                                ]),
                              ),
                            ),
                          ),
                          child: Row(children: [
                            Icon(LucideIcons.maximize2, size: 14, color: c.primary),
                            const SizedBox(width: 4),
                            Text(l.fullScreen, style: AppText.meta.copyWith(color: c.primary, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      _Preview(vm: vm),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Text(d.types.isEmpty ? l.needTicketTypeFirst : l.noSeatMapYet, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
                const SizedBox(height: 16),
              ],
              if (vm.sections.isNotEmpty) ...[
                Text(l.sectionsTitle, style: AppText.headerTitle.copyWith(color: c.text, fontSize: 17)),
                const SizedBox(height: 12),
              ],
              for (final (i, s) in vm.sections.indexed) ...[
                _SectionCard(key: ValueKey(vm.keys[i]), index: i, section: s),
                const SizedBox(height: 12),
              ],
              if (d.types.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: TextButton.icon(
                    onPressed: () => vm.add(String.fromCharCode(65 + vm.sections.length % 26)),
                    style: TextButton.styleFrom(
                      foregroundColor: c.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: c.primary.withValues(alpha: 0.4))),
                    ),
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: Text(l.addSection, style: AppText.bodyStrong),
                  ),
                ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: l.saveMap,
                isLoading: vm.isBusy,
                onPressed: vm.sections.isEmpty || !vm.dirty || over.isNotEmpty
                    ? null
                    : () async {
                        final f = await vm.save();
                        if (context.mounted) showMessage(context, f?.text(context) ?? l.mapSaved);
                      },
              ),
              if (hasMap) ...[
                GhostButton(
                  label: l.deleteMap,
                  color: c.danger,
                  onPressed: vm.soldSeats > 0 || vm.isBusy ? null : () => _delete(context, vm),
                ),
                if (vm.soldSeats > 0)
                  Text(l.mapSoldLocked, textAlign: TextAlign.center, style: AppText.finePrint.copyWith(color: c.textMuted)),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Сцена и точки мест по секциям, цвет — тип билета.
class _Preview extends StatelessWidget {
  const _Preview({required this.vm});

  final SeatingViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return Column(
      children: [
        Container(
          width: 220,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppPalette.camera,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(30)),
          ),
          child: Text(l.stage, style: AppText.badge.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 14),
        for (final s in vm.sections) ...[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                for (final n in s.rowSeats.take(60))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var k = 0; k < n.clamp(0, 80); k++)
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(color: AppPalette.seriesAt(vm.typeIndex(s.ticketTypeId).clamp(0, 99)), shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Text(s.name, style: AppText.caption.copyWith(color: c.textMuted)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SectionCard extends StatefulWidget {
  const _SectionCard({super.key, required this.index, required this.section});

  final int index;
  final SectionDraft section;

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  late final _name = TextEditingController(text: widget.section.name);
  late final _rows = TextEditingController(text: '${widget.section.rows == 0 ? 5 : widget.section.rows}');
  late final _perRow = TextEditingController(text: '${widget.section.seatsPerRow == 0 ? 10 : widget.section.seatsPerRow}');
  late final List<(TextEditingController, TextEditingController)> _manual = [
    for (final r in widget.section.manualRows) (TextEditingController(text: r.label), TextEditingController(text: '${r.seats}')),
  ];
  late bool _isManual = widget.section.isManual;

  @override
  void dispose() {
    for (final c in [_name, _rows, _perRow, for (final (a, b) in _manual) ...[a, b]]) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() {
    final s = widget.section;
    final next = _isManual
        ? s.copyWith(
            name: _name.text,
            manualRows: [for (final (a, b) in _manual) RowDraft(label: a.text, seats: int.tryParse(b.text) ?? 0)],
          )
        : SectionDraft(
            name: _name.text,
            ticketTypeId: s.ticketTypeId,
            rows: int.tryParse(_rows.text) ?? 0,
            seatsPerRow: int.tryParse(_perRow.text) ?? 0,
          );
    context.read<SeatingViewModel>().update(widget.index, next);
  }

  void _setMode(bool manual) {
    if (manual == _isManual) return;
    setState(() {
      _isManual = manual;
      if (manual && _manual.isEmpty) {
        final rows = (int.tryParse(_rows.text) ?? 1).clamp(1, 60);
        final per = int.tryParse(_perRow.text) ?? 10;
        _manual.addAll([for (var i = 1; i <= rows; i++) (TextEditingController(text: '$i'), TextEditingController(text: '$per'))]);
      }
    });
    _emit();
  }

  Future<void> _pickType(SeatingViewModel vm) async {
    final l = context.l10n;
    final id = await showModalBottomSheet<int>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 8),
              child: Text(l.ticketTypeLabel, style: AppText.headerTitle.copyWith(color: sheet.colors.text)),
            ),
            for (final (i, t) in vm.types.indexed)
              ListTile(
                leading: Container(width: 12, height: 12, decoration: BoxDecoration(color: AppPalette.seriesAt(i), shape: BoxShape.circle)),
                title: Text('${t.name} · ${Fmt.money(t.price)}', style: AppText.body.copyWith(color: sheet.colors.text)),
                trailing: t.id == widget.section.ticketTypeId ? Icon(LucideIcons.check, color: sheet.colors.primary) : null,
                onTap: () => Navigator.of(sheet).pop(t.id),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (id != null && mounted) vm.update(widget.index, widget.section.copyWith(ticketTypeId: id));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<SeatingViewModel>();
    final s = widget.section;
    final ti = vm.typeIndex(s.ticketTypeId);
    final type = ti < 0 ? null : vm.types[ti];
    final color = AppPalette.seriesAt(ti.clamp(0, 99));
    final open = vm.expanded == widget.index;
    final meta = s.isManual
        ? '${type?.name ?? '—'} · ${l.rowsCount(s.rowCount)} · ${l.seatsCount(s.seats)}'
        : '${type?.name ?? '—'} · ${l.rowsCount(s.rows)} × ${l.seatsCount(s.seatsPerRow)}';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => vm.toggle(widget.index),
            child: Row(children: [
              Icon(LucideIcons.gripVertical, size: 18, color: c.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.sectionDefault(s.name), style: AppText.cardTitle.copyWith(color: c.text)),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Flexible(child: Text(meta, style: AppText.caption.copyWith(color: c.textMuted))),
                    ]),
                  ],
                ),
              ),
              Icon(open ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 18, color: c.textMuted),
            ]),
          ),
          if (open) ...[
            const SizedBox(height: 12),
            LabeledTextField(label: l.sectionName, controller: _name, compact: true, onChanged: (_) => _emit()),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _pickType(vm),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: c.border)),
                child: Row(children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(type == null ? l.ticketTypeLabel : '${type.name} · ${Fmt.money(type.price)}',
                        style: AppText.label.copyWith(color: c.text)),
                  ),
                  Icon(LucideIcons.chevronDown, size: 16, color: c.textMuted),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                for (final (manual, label) in [(false, l.modeQuick), (true, l.modeManual)])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _setMode(manual),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: manual == _isManual ? c.surface : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          style: AppText.meta.copyWith(
                            color: manual == _isManual ? c.text : c.textMuted,
                            fontWeight: manual == _isManual ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 12),
            if (!_isManual)
              Row(children: [
                Expanded(child: LabeledTextField(label: l.rowsLabel, controller: _rows, compact: true, keyboardType: TextInputType.number, onChanged: (_) => _emit())),
                const SizedBox(width: 10),
                Expanded(
                  child: LabeledTextField(label: l.seatsPerRowLabel, controller: _perRow, compact: true, keyboardType: TextInputType.number, onChanged: (_) => _emit()),
                ),
              ])
            else ...[
              for (final (i, (label, seats)) in _manual.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Expanded(child: LabeledTextField(controller: label, compact: true, hintText: l.rowLabel, onChanged: (_) => _emit())),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LabeledTextField(controller: seats, compact: true, hintText: l.seatsLabel, keyboardType: TextInputType.number, onChanged: (_) => _emit()),
                    ),
                    IconButton(
                      tooltip: l.actionDelete,
                      onPressed: _manual.length <= 1
                          ? null
                          : () {
                              final (a, b) = _manual.removeAt(i);
                              a.dispose();
                              b.dispose();
                              setState(() {});
                              _emit();
                            },
                      icon: Icon(LucideIcons.x, size: 18, color: c.textMuted),
                    ),
                  ]),
                ),
              GhostButton(
                label: l.addRow,
                icon: LucideIcons.plus,
                onPressed: () {
                  final last = _manual.isEmpty ? null : _manual.last;
                  setState(() => _manual.add((
                        TextEditingController(text: '${_manual.length + 1}'),
                        TextEditingController(text: last?.$2.text ?? '10'),
                      )));
                  _emit();
                },
              ),
            ],
            GhostButton(label: l.removeSection, color: c.danger, onPressed: () => vm.remove(widget.index)),
          ],
        ],
      ),
    );
  }
}

// ─── activation ────────────────────────────────────────────────────────────

class ActivationViewModel extends Loadable<ActivationChecklist> {
  ActivationViewModel({required this.eventId, required PaidSalesActivation activation})
      : _activation = activation,
        super(() => activation.checklist(eventId));

  final int eventId;
  final PaidSalesActivation _activation;
  bool termsAccepted = false;

  void setTerms(bool v) {
    termsAccepted = v;
    notifyListeners();
  }

  Future<Failure?> activate() => run(() => _activation.activate(eventId, termsAccepted: termsAccepted), reload: true);
}

/// M-B8 · Продажи: чек-лист активации платных продаж (§3.2, §4.5, UC2).
class ActivationPage extends StatelessWidget {
  const ActivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<ActivationViewModel>();
    return EventShell(
      eventId: vm.eventId,
      section: EventSection.sales,
      body: LoadableView<ActivationChecklist>(
        state: vm,
        builder: (context, k) {
          final fee = k.activationFeePaid || k.alreadyActivated;
          final checks = [k.hasPaidTicketType, k.identityVerified, k.payoutVerified, fee];
          final done = checks.where((x) => x).length;
          final canActivate = k.hasPaidTicketType && k.identityVerified && k.payoutVerified && vm.termsAccepted;
          Widget item(bool ok, String title, String okText, String missing, {VoidCallback? fix}) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  radius: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(color: ok ? c.successSoft : c.dangerSoft, shape: BoxShape.circle),
                        child: Icon(ok ? LucideIcons.check : LucideIcons.x, size: 16, color: ok ? c.success : c.danger),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppText.cardTitle.copyWith(color: c.text, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text(ok ? okText : missing, style: AppText.meta.copyWith(color: c.textMuted)),
                            if (!ok && fix != null) ...[
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: fix,
                                child: Text(l.fixLink, style: AppText.bodyStrong.copyWith(color: c.primary)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
          return RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: sectionPadding,
              children: [
                if (k.alreadyActivated)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: c.successSoft, borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      Icon(LucideIcons.circleCheckBig, size: 22, color: c.successText),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.activatedTitle, style: AppText.cardTitle.copyWith(color: c.successText)),
                            Text(l.activatedBody, style: AppText.meta.copyWith(color: c.successText)),
                          ],
                        ),
                      ),
                    ]),
                  )
                else
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.activationTitle, style: AppText.headerTitle.copyWith(color: c.text)),
                        const SizedBox(height: 8),
                        Text(l.activationProgress(done, checks.length), style: AppText.bodySecondary.copyWith(color: c.textMuted)),
                        const SizedBox(height: 12),
                        ProgressStrip(value: done / checks.length),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                item(k.hasPaidTicketType, l.chkPaidType, l.doneLabel, l.chkPaidTypeMissing,
                    fix: () => context.replace(Routes.ticketTypes(vm.eventId))),
                item(k.identityVerified, l.chkIdentity, l.doneLabel, l.chkIdentityMissing,
                    fix: () => context.push(Routes.organizerProfile).then((_) => vm.load())),
                item(k.payoutVerified, l.chkPayout, l.doneLabel, l.chkPayoutMissing,
                    fix: () => context.push(Routes.organizerProfile).then((_) => vm.load())),
                item(fee, l.chkFee, l.doneLabel, l.chkFeeMissing),
                if (!k.alreadyActivated) ...[
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: vm.termsAccepted,
                    onChanged: (v) => vm.setTerms(v ?? false),
                    title: Text(l.termsAccept, style: AppText.bodySecondary.copyWith(color: c.text)),
                  ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: l.activateButton,
                    icon: canActivate ? LucideIcons.zap : LucideIcons.lock,
                    isLoading: vm.isBusy,
                    onPressed: !canActivate
                        ? null
                        : () async {
                            final f = await vm.activate();
                            if (f == null) sl<ManagedEventController>().ensure(vm.eventId, force: true);
                            if (context.mounted) reportResult(context, f, success: l.activatedToast);
                          },
                  ),
                ],
                const SizedBox(height: 16),
                DemoNotice(text: l.demoActivation),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── профиль организатора ──────────────────────────────────────────────────

class OrganizerProfileViewModel extends Loadable<OrganizerProfile> {
  OrganizerProfileViewModel(this._manage) : super(_manage.load);

  final ManageOrganizerProfile _manage;

  Future<Failure?> save(OrganizerProfile p) => run(() => _manage.save(p), onOk: setData);
}

/// Профиль организатора и счёт для выплат (§4.1, шаги активации).
class OrganizerProfilePage extends StatefulWidget {
  const OrganizerProfilePage({super.key});

  @override
  State<OrganizerProfilePage> createState() => _OrganizerProfilePageState();
}

class _OrganizerProfilePageState extends State<OrganizerProfilePage> {
  final _c = <String, TextEditingController>{};

  TextEditingController _f(String k, String v) => _c.putIfAbsent(k, () => TextEditingController(text: v));

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final vm = context.watch<OrganizerProfileViewModel>();
    Widget gap() => const SizedBox(height: 14);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(subtitle: l.orgProfileSub, title: l.orgProfileTitle, onBack: () => context.pop()),
            Expanded(
              child: LoadableView<OrganizerProfile>(
                state: vm,
                refreshable: false,
                builder: (context, p) => ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
                  children: [
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      TagLabel(p.identityVerified ? l.identityOk : l.identityNo, tone: p.identityVerified ? Tone.success : Tone.warning),
                      TagLabel(p.payoutVerified ? l.payoutOk : l.payoutNo, tone: p.payoutVerified ? Tone.success : Tone.warning),
                    ]),
                    const SizedBox(height: AppSpacing.section),
                    SectionLabel(l.organization),
                    const SizedBox(height: 10),
                    LabeledTextField(label: l.orgName, controller: _f('org', p.organizationName)),
                    gap(),
                    LabeledTextField(label: l.descriptionLabel, controller: _f('desc', p.description), maxLines: 3),
                    gap(),
                    LabeledTextField(label: l.contactEmail, controller: _f('email', p.contactEmail), keyboardType: TextInputType.emailAddress),
                    gap(),
                    LabeledTextField(label: l.contactPhone, controller: _f('phone', p.contactPhone), keyboardType: TextInputType.phone),
                    gap(),
                    LabeledTextField(label: l.website, controller: _f('web', p.website), keyboardType: TextInputType.url),
                    const SizedBox(height: AppSpacing.section),
                    SectionLabel(l.payoutSection),
                    const SizedBox(height: 10),
                    LabeledTextField(label: l.bank, controller: _f('bank', p.payoutBankName), hintText: 'Kaspi Bank'),
                    gap(),
                    LabeledTextField(label: l.accountNumber, controller: _f('acc', p.payoutAccountNumber), hintText: 'KZ…'),
                    gap(),
                    LabeledTextField(label: l.accountHolder, controller: _f('holder', p.payoutAccountHolder)),
                    gap(),
                    DemoNotice(text: l.demoPayout),
                  ],
                ),
              ),
            ),
            if (vm.data != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 16),
                child: PrimaryButton(
                  label: l.saveProfile,
                  isLoading: vm.isBusy,
                  onPressed: () async {
                    final p = vm.data!;
                    final f = await vm.save(OrganizerProfile(
                      organizationName: _c['org']!.text,
                      description: _c['desc']!.text,
                      contactEmail: _c['email']!.text,
                      contactPhone: _c['phone']!.text,
                      website: _c['web']!.text,
                      payoutBankName: _c['bank']!.text,
                      payoutAccountNumber: _c['acc']!.text,
                      payoutAccountHolder: _c['holder']!.text,
                      identityVerified: p.identityVerified,
                      payoutVerified: p.payoutVerified,
                    ));
                    if (context.mounted) reportResult(context, f, success: l.profileSaved);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
