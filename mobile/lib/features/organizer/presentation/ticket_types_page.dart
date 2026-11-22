import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/form_widgets.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../domain/organizer_events_domain.dart';
import '../domain/organizer_operations_domain.dart';

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

/// O3 · Ticket types & inventory (§4.3)
class TicketTypesPage extends StatelessWidget {
  const TicketTypesPage({super.key});

  Future<void> _edit(BuildContext context, TicketTypesViewModel vm, [TicketTypeInfo? t]) async {
    final draft = await showModalBottomSheet<TicketTypeDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      builder: (_) => _TicketTypeSheet(initial: t == null ? const TicketTypeDraft() : TicketTypeDraft.from(t)),
    );
    if (draft == null) return;
    final f = await vm.save(draft, existing: t);
    if (context.mounted) reportResult(context, f, success: t == null ? 'Ticket type added.' : 'Saved.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketTypesViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Ticket types', subtitle: 'Inventory', onBack: () => context.pop()),
            Expanded(
              child: LoadableView<TicketTypesData>(
                state: vm,
                builder: (context, d) {
                  final now = DateTime.now();
                  final issued = d.types.fold<int>(0, (s, t) => s + t.sold);
                  final available = d.types.where((t) => !t.hidden).fold<int>(0, (s, t) => s + t.remaining);
                  final o = d.overview;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 18, AppSpacing.sideLight, 24),
                    children: [
                      StatQuad(cells: [
                        (Fmt.count(issued), 'Issued'),
                        (Fmt.count(available), 'Available'),
                        (o == null ? '—' : Fmt.count(o.checkedIn), 'Checked in'),
                        (o == null ? '—' : Fmt.count(o.refunded + o.cancelled), 'Refunded / void'),
                      ]),
                      const SizedBox(height: AppSpacing.block),
                      if (d.types.isEmpty)
                        const MessageView(
                          icon: Icons.confirmation_number_outlined,
                          title: 'No ticket types yet',
                          message: 'Add at least one free or paid ticket type before publishing.',
                        ),
                      for (final t in d.types)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.paper, border: Border.all(color: AppColors.divider)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(child: Text(t.name, style: AppText.listTitle.copyWith(color: AppColors.ink))),
                                TagLabel(
                                  t.hidden
                                      ? 'Hidden'
                                      : t.isSoldOut
                                          ? 'Sold out'
                                          : t.isOnSale(now)
                                              ? 'On sale'
                                              : 'Not on sale',
                                  filled: t.isOnSale(now),
                                ),
                              ]),
                              if (t.description != null && t.description!.isNotEmpty)
                                Text(t.description!, style: AppText.meta.copyWith(color: AppColors.neutral600)),
                              const SizedBox(height: 10),
                              DetailGrid(rows: [
                                ('Price', Fmt.money(t.price)),
                                ('Sold', '${Fmt.count(t.sold)} / ${Fmt.count(t.quantity)}'),
                                if (t.maxPerOrder != null) ('Max per order', '${t.maxPerOrder}'),
                                if (t.salesStart != null || t.salesEnd != null)
                                  ('Sales', '${t.salesStart == null ? 'now' : Fmt.shortDateTime(t.salesStart!)} — '
                                      '${t.salesEnd == null ? 'event' : Fmt.shortDateTime(t.salesEnd!)}'),
                                if (o != null)
                                  for (final x in o.byTicketType.where((x) => x.name == t.name))
                                    ('Checked in', '${x.checkedIn} / ${x.registered}'),
                              ]),
                              const SizedBox(height: 10),
                              ProgressStrip(value: t.quantity == 0 ? 0 : t.sold / t.quantity),
                              const SizedBox(height: 10),
                              Row(children: [
                                Expanded(child: SecondaryButton(label: 'Edit', onPressed: () => _edit(context, vm, t))),
                                if (!t.hidden) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: SecondaryButton(
                                      label: 'Hide',
                                      onPressed: () async {
                                        final f = await vm.hide(t);
                                        if (context.mounted) reportResult(context, f, success: 'Hidden from sale. Sold tickets stay valid.');
                                      },
                                    ),
                                  ),
                                ],
                              ]),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
              child: PrimaryButton(label: 'Add a ticket type', isLoading: vm.isBusy, onPressed: () => _edit(context, vm)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketTypeSheet extends StatefulWidget {
  const _TicketTypeSheet({required this.initial});

  final TicketTypeDraft initial;

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
  late bool _free = widget.initial.price == 0;
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
      price: _free ? 0 : double.tryParse(_price.text.replaceAll(' ', '')) ?? -1,
      quantity: int.tryParse(_quantity.text) ?? 0,
      maxPerOrder: int.tryParse(_max.text),
      salesStart: _start,
      salesEnd: _end,
    );
    final problem = d.validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    Navigator.of(context).pop(d);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sheetInset, 20, AppSpacing.sheetInset, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(widget.initial.name.isEmpty ? 'New ticket type' : 'Edit ticket type', color: AppColors.accent700),
              const SizedBox(height: 14),
              LabeledTextField(label: 'Name', controller: _name, hintText: 'General Admission'),
              const SizedBox(height: 12),
              LabeledTextField(label: 'Description', controller: _description, hintText: 'Standing, floor level'),
              LabeledSwitch(label: 'Free ticket', value: _free, onChanged: (v) => setState(() => _free = v)),
              if (!_free)
                LabeledTextField(label: 'Price, ₸', controller: _price, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: LabeledTextField(label: 'Quantity', controller: _quantity, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: LabeledTextField(label: 'Max per order', controller: _max, keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              DateTimeField(label: 'Sales start (optional)', value: _start, onChanged: (t) => setState(() => _start = t)),
              const SizedBox(height: 12),
              DateTimeField(label: 'Sales end (optional)', value: _end, onChanged: (t) => setState(() => _end = t)),
              if (!_free)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Paid tickets can be sold only after paid sales are activated for this event.',
                      style: AppText.finePrint.copyWith(color: AppColors.neutral600)),
                ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: AppText.bodySecondary.copyWith(color: AppColors.ink)),
              ],
              const SizedBox(height: 16),
              PrimaryButton(label: 'Save', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
