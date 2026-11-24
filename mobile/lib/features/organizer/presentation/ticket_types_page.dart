import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/di/injection.dart';
import '../../../core/error/failure.dart';
import '../../../core/presentation/failure_text.dart';
import '../../../core/error/result.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/form_widgets.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../domain/organizer_events_domain.dart';
import '../domain/organizer_operations_domain.dart';
import 'event_shell.dart';
import 'managed_event_controller.dart';

class TicketTypesData {
  const TicketTypesData({required this.types, this.overview});

  final List<TicketTypeInfo> types;
  final CheckInOverview? overview;
}

class TicketTypesViewModel extends Loadable<TicketTypesData> {
  TicketTypesViewModel({required this.eventId, required ManageTicketTypes manage, required GetCheckInOverview overview})
      : _manage = manage,
        super(() async {
          final r = await manage.list(eventId);
          if (r case Err(:final failure)) return Err(failure);
          return Ok(TicketTypesData(types: r.valueOrNull!, overview: (await overview(eventId)).valueOrNull));
        });

  final int eventId;
  final ManageTicketTypes _manage;

  Future<Failure?> save(TicketTypeDraft d, {TicketTypeInfo? existing}) =>
      run(() => _manage.save(eventId, d, existing: existing), reload: true);

  Future<Failure?> hide(TicketTypeInfo t) => run(() => _manage.hide(t), reload: true);
}

/// Билеты события: типы, остатки, вход по типу (§4.3).
class TicketTypesPage extends StatelessWidget {
  const TicketTypesPage({super.key});

  Future<void> _edit(BuildContext context, TicketTypesViewModel vm, [TicketTypeInfo? t]) async {
    final l = context.l10n;
    final draft = await showModalBottomSheet<TicketTypeDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TicketTypeSheet(initial: t == null ? const TicketTypeDraft() : TicketTypeDraft.from(t), alreadySold: t?.sold ?? 0),
    );
    if (draft == null) return;
    final f = await vm.save(draft, existing: t);
    if (f == null) sl<ManagedEventController>().ensure(vm.eventId, force: true);
    if (context.mounted) reportResult(context, f, success: t == null ? l.ttAdded : l.savedToast);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<TicketTypesViewModel>();
    return EventShell(
      eventId: vm.eventId,
      section: EventSection.tickets,
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 8),
        child: PrimaryButton(label: l.addTicketType, icon: LucideIcons.plus, isLoading: vm.isBusy, onPressed: () => _edit(context, vm)),
      ),
      body: LoadableView<TicketTypesData>(
        state: vm,
        builder: (context, d) {
          final now = DateTime.now();
          final issued = d.types.fold<int>(0, (s, t) => s + t.sold);
          final available = d.types.where((t) => !t.hidden).fold<int>(0, (s, t) => s + t.remaining);
          final o = d.overview;
          return ListView(
            padding: sectionPadding,
            children: [
              StatQuad(cells: [
                (Fmt.count(issued), l.issued),
                (Fmt.count(available), l.available),
                (o == null ? '—' : Fmt.count(o.checkedIn), l.attCheckedIn),
                (o == null ? '—' : Fmt.count(o.refunded + o.cancelled), l.refundedVoid),
              ]),
              const SizedBox(height: 16),
              if (d.types.isEmpty)
                MessageView(icon: LucideIcons.ticketPlus, title: l.noTicketTypes, message: l.noTicketTypesHint),
              for (final (i, t) in d.types.indexed) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: AppPalette.seriesAt(i), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(t.name, style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700))),
                        Text(Fmt.money(t.price), style: AppText.bodyStrong.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                      ]),
                      if (t.description != null && t.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(t.description!, style: AppText.meta.copyWith(color: c.textMuted)),
                      ],
                      const SizedBox(height: 8),
                      TagLabel(
                        t.hidden
                            ? l.ttHidden
                            : t.isSoldOut
                                ? l.ttSoldOut
                                : t.isOnSale(now)
                                    ? l.ttOnSale
                                    : l.ttNotOnSale,
                        tone: t.hidden
                            ? Tone.neutral
                            : t.isSoldOut
                                ? Tone.danger
                                : t.isOnSale(now)
                                    ? Tone.success
                                    : Tone.warning,
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Text(l.soldOf(Fmt.count(t.sold), Fmt.count(t.quantity)), style: AppText.meta.copyWith(color: c.textMuted, fontWeight: FontWeight.w500))),
                        if (o != null)
                          for (final x in o.byTicketType.where((x) => x.name == t.name))
                            Text('${l.attCheckedIn} ${x.checkedIn} / ${x.registered}', style: AppText.meta.copyWith(color: c.textMuted)),
                      ]),
                      const SizedBox(height: 6),
                      ProgressStrip(value: t.quantity == 0 ? 0 : t.sold / t.quantity, color: AppPalette.seriesAt(i)),
                      const SizedBox(height: 10),
                      DetailGrid(rows: [
                        if (t.maxPerOrder != null) (l.maxPerOrder, '${t.maxPerOrder}'),
                        if (t.salesStart != null || t.salesEnd != null)
                          (l.salesWindow, '${t.salesStart == null ? l.salesNow : Fmt.shortDateTime(t.salesStart!)} — '
                              '${t.salesEnd == null ? l.salesUntilEvent : Fmt.shortDateTime(t.salesEnd!)}'),
                      ]),
                      Row(children: [
                        Expanded(child: SecondaryButton(label: l.actEdit, icon: LucideIcons.pencil, compact: true, onPressed: () => _edit(context, vm, t))),
                        if (!t.hidden) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: SecondaryButton(
                              label: l.actHide,
                              icon: LucideIcons.eyeOff,
                              compact: true,
                              onPressed: () async {
                                final f = await vm.hide(t);
                                if (context.mounted) reportResult(context, f, success: l.hiddenToast);
                              },
                            ),
                          ),
                        ],
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TicketTypeSheet extends StatefulWidget {
  const _TicketTypeSheet({required this.initial, required this.alreadySold});

  final TicketTypeDraft initial;
  final int alreadySold;

  @override
  State<_TicketTypeSheet> createState() => _TicketTypeSheetState();
}

class _TicketTypeSheetState extends State<_TicketTypeSheet> {
  late final _name = TextEditingController(text: widget.initial.name);
  late final _description = TextEditingController(text: widget.initial.description);
  late final _price = TextEditingController(text: widget.initial.price == 0 ? '' : widget.initial.price.round().toString());
  late final _quantity = TextEditingController(text: widget.initial.quantity == 0 ? '' : '${widget.initial.quantity}');
  late final _max = TextEditingController(text: widget.initial.maxPerOrder?.toString() ?? '');
  late DateTime? _start = widget.initial.salesStart;
  late DateTime? _end = widget.initial.salesEnd;
  late bool _free = widget.initial.name.isNotEmpty && widget.initial.price == 0;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _description, _price, _quantity, _max]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final d = TicketTypeDraft(
      name: _name.text,
      description: _description.text,
      price: _free ? 0 : double.tryParse(_price.text.replaceAll(RegExp(r'\s'), '')) ?? -1,
      quantity: int.tryParse(_quantity.text) ?? 0,
      maxPerOrder: int.tryParse(_max.text),
      salesStart: _start,
      salesEnd: _end,
    );
    final problem = d.validate(alreadySold: widget.alreadySold);
    if (problem != null) {
      setState(() => _error = problem.toFailure().text(context));
      return;
    }
    Navigator.of(context).pop(d);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.initial.name.isEmpty ? l.newTicketType : l.editTicketType, style: AppText.headerTitle.copyWith(color: c.text, fontSize: 20)),
              const SizedBox(height: 16),
              LabeledTextField(label: l.nameLabel, controller: _name, hintText: 'General Admission'),
              const SizedBox(height: 12),
              LabeledTextField(label: l.descriptionLabel, controller: _description),
              const SizedBox(height: 4),
              LabeledSwitch(label: l.freeTicket, value: _free, onChanged: (v) => setState(() => _free = v)),
              if (!_free) LabeledTextField(label: l.priceKzt, controller: _price, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: LabeledTextField(label: l.quantityLabel, controller: _quantity, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: LabeledTextField(label: l.maxPerOrder, controller: _max, keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              DateTimeField(label: l.salesStartOpt, value: _start, onChanged: (t) => setState(() => _start = t)),
              const SizedBox(height: 12),
              DateTimeField(label: l.salesEndOpt, value: _end, onChanged: (t) => setState(() => _end = t)),
              if (!_free) ...[
                const SizedBox(height: 8),
                Text(l.paidNeedsActivation, style: AppText.finePrint.copyWith(color: c.textMuted)),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                InfoBanner(text: _error!, tone: Tone.danger),
              ],
              const SizedBox(height: 16),
              PrimaryButton(label: l.actionSave, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
