import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/insights.dart';
import '../../../shared/domain/entities/people.dart';
import '../domain/organizer_events_domain.dart';

// ─── seating ───────────────────────────────────────────────────────────────

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
  final List<SectionDraft> sections = [];

  void addSection(SectionDraft s) {
    sections.add(s);
    notifyListeners();
  }

  void removeSection(int i) {
    sections.removeAt(i);
    notifyListeners();
  }

  Future<Failure?> save() async {
    final f = await run(() => _seats.save(eventId, sections), reload: true);
    if (f == null) sections.clear();
    return f;
  }

  Future<Failure?> clear() => run(() => _seats.clear(eventId), reload: true);
}

/// Схема зала (§4.3.1): секции из рядов, привязанные к типам билетов.
class SeatingPage extends StatefulWidget {
  const SeatingPage({super.key});

  @override
  State<SeatingPage> createState() => _SeatingPageState();
}

class _SeatingPageState extends State<SeatingPage> {
  final _name = TextEditingController();
  final _rows = TextEditingController(text: '5');
  final _perRow = TextEditingController(text: '10');
  int? _typeId;

  @override
  void dispose() {
    for (final c in [_name, _rows, _perRow]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SeatingViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Seating', subtitle: 'Predefined layout', onBack: () => context.pop()),
            Expanded(
              child: LoadableView<SeatingData>(
                state: vm,
                builder: (context, d) {
                  final bySection = <String, int>{};
                  for (final s in d.seats) {
                    bySection[s.section] = (bySection[s.section] ?? 0) + 1;
                  }
                  final sold = d.seats.where((s) => s.status == SeatStatus.sold).length;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 18, AppSpacing.sideLight, 24),
                    children: [
                      const SectionLabel('Current map'),
                      const SizedBox(height: 6),
                      if (d.seats.isEmpty)
                        Text('No seat map yet. Attendees cannot pick seats until you add one.',
                            style: AppText.bodySecondary.copyWith(color: AppColors.neutral700))
                      else ...[
                        DetailGrid(rows: [
                          for (final e in bySection.entries) ('Section ${e.key}', '${e.value} seats'),
                          ('Sold', '$sold of ${d.seats.length}'),
                        ]),
                        const SizedBox(height: 10),
                        SecondaryButton(
                          label: 'Remove seat map',
                          onPressed: sold > 0 || vm.isBusy
                              ? null
                              : () async {
                                  final f = await vm.clear();
                                  if (context.mounted) reportResult(context, f, success: 'Seat map removed.');
                                },
                        ),
                        if (sold > 0)
                          Text('Seats are already sold, so the map cannot be removed.',
                              style: AppText.finePrint.copyWith(color: AppColors.neutral600)),
                      ],
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('New layout'),
                      const SizedBox(height: 6),
                      Text('Saving replaces the current map. Each section uses one ticket type and its price.',
                          style: AppText.meta.copyWith(color: AppColors.neutral600)),
                      for (final (i, s) in vm.sections.indexed)
                        ListRow(
                          title: 'Section ${s.name}',
                          subtitle: '${s.rows} rows × ${s.seatsPerRow} seats · '
                              '${d.types.where((t) => t.id == s.ticketTypeId).firstOrNull?.name ?? 'ticket'}',
                          trailing: IconButton(onPressed: () => vm.removeSection(i), icon: const Icon(Icons.close, size: 18)),
                        ),
                      const SizedBox(height: 12),
                      if (d.types.isEmpty)
                        Text('Add a ticket type first — sections are priced by ticket type.',
                            style: AppText.bodySecondary.copyWith(color: AppColors.ink))
                      else ...[
                        LabeledTextField(label: 'Section name', controller: _name, hintText: 'A'),
                        const SizedBox(height: 10),
                        Text('Ticket type', style: AppText.meta.copyWith(color: AppColors.neutral600)),
                        const SizedBox(height: 6),
                        ChoiceChips<int?>(
                          options: [for (final t in d.types) t.id],
                          selected: _typeId ?? d.types.first.id,
                          label: (id) => d.types.firstWhere((t) => t.id == id).name,
                          onSelected: (id) => setState(() => _typeId = id),
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: LabeledTextField(label: 'Rows', controller: _rows, keyboardType: TextInputType.number)),
                          const SizedBox(width: 10),
                          Expanded(child: LabeledTextField(label: 'Seats per row', controller: _perRow, keyboardType: TextInputType.number)),
                        ]),
                        const SizedBox(height: 10),
                        SecondaryButton(
                          label: 'Add section',
                          onPressed: () {
                            vm.addSection(SectionDraft(
                              name: _name.text.trim().isEmpty ? String.fromCharCode(65 + vm.sections.length) : _name.text.trim(),
                              ticketTypeId: _typeId ?? d.types.first.id,
                              rows: int.tryParse(_rows.text) ?? 0,
                              seatsPerRow: int.tryParse(_perRow.text) ?? 0,
                            ));
                            _name.clear();
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
              child: PrimaryButton(
                label: 'Save layout · ${vm.sections.fold<int>(0, (s, x) => s + x.seats)} seats',
                isLoading: vm.isBusy,
                onPressed: vm.sections.isEmpty
                    ? null
                    : () async {
                        final f = await vm.save();
                        if (context.mounted) reportResult(context, f, success: 'Seat map saved.');
                      },
              ),
            ),
          ],
        ),
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

/// O4 · Paid sales activation (§3.2, §4.5, UC2)
class ActivationPage extends StatelessWidget {
  const ActivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivationViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Activate paid sales', subtitle: 'This event only', onBack: () => context.pop()),
            Expanded(
              child: LoadableView<ActivationChecklist>(
                state: vm,
                builder: (context, c) {
                  Widget step(int n, bool done, String title, String text, {Widget? action}) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: done ? AppColors.accent : null,
                                border: Border.all(color: done ? AppColors.accent : AppColors.divider),
                              ),
                              child: done
                                  ? const Icon(Icons.check, size: 16, color: AppColors.paper)
                                  : Text('$n', style: AppText.tag.copyWith(color: AppColors.ink)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: AppText.listTitle.copyWith(color: AppColors.ink, fontSize: 16)),
                                  Text(text, style: AppText.meta.copyWith(color: AppColors.neutral600)),
                                  if (action != null) ...[const SizedBox(height: 8), action],
                                ],
                              ),
                            ),
                            Text(done ? 'DONE' : '', style: AppText.fieldLabel.copyWith(color: AppColors.accent700)),
                          ],
                        ),
                      );
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 18, AppSpacing.sideLight, 24),
                    children: [
                      if (c.alreadyActivated)
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: AppColors.accent100,
                          child: Text('PAID SALES ARE ACTIVE FOR THIS EVENT', style: AppText.sectionLabel.copyWith(color: AppColors.accent800)),
                        )
                      else
                        Text(
                          'Free registration works now. Selling paid tickets needs these steps and a one-time '
                          'activation fee for this event only.',
                          style: AppText.body.copyWith(color: AppColors.neutral700),
                        ),
                      const SizedBox(height: 10),
                      step(1, c.hasPaidTicketType, 'A paid ticket type exists', 'Add one under Ticket types.'),
                      step(2, c.identityVerified, 'Identity verification', 'Sandbox check of the organizer record.'),
                      step(3, c.payoutVerified, 'Connect a payout account', 'Where demonstration proceeds would settle.',
                          action: c.payoutVerified
                              ? null
                              : SecondaryButton(label: 'Connect payout account', onPressed: () => context.push(Routes.organizerProfile))),
                      step(4, c.activationFeePaid || c.alreadyActivated, 'Pay the activation fee', 'One-time, this event only · simulated.'),
                      step(5, vm.termsAccepted || c.alreadyActivated, 'Accept the paid-event terms',
                          'Refund obligations, chargeback handling, payout timing.',
                          action: c.alreadyActivated
                              ? null
                              : CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  value: vm.termsAccepted,
                                  onChanged: (v) => vm.setTerms(v ?? false),
                                  title: Text('I accept the paid-event terms', style: AppText.bodySecondary.copyWith(color: AppColors.ink)),
                                )),
                      const SizedBox(height: 16),
                      const DemoNotice(
                        text: 'Identity checks, the fee, ticket payments and payouts run in a sandbox. No money moves.',
                      ),
                    ],
                  );
                },
              ),
            ),
            if (vm.data != null && !vm.data!.alreadyActivated)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
                child: PrimaryButton(
                  label: 'Pay fee and activate',
                  isLoading: vm.isBusy,
                  onPressed: () async {
                    final f = await vm.activate();
                    if (context.mounted) reportResult(context, f, success: 'Paid sales activated (simulated).');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── organizer profile ─────────────────────────────────────────────────────

class OrganizerProfileViewModel extends Loadable<OrganizerProfile> {
  OrganizerProfileViewModel(this._manage) : super(_manage.load);

  final ManageOrganizerProfile _manage;

  Future<Failure?> save(OrganizerProfile p) => run(() => _manage.save(p), onOk: setData);
}

/// Профиль организатора и счёт для выплат (§4.1, O4 шаг 3).
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
    final vm = context.watch<OrganizerProfileViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Organizer profile', subtitle: 'Contact & payout', onBack: () => context.pop()),
            Expanded(
              child: LoadableView<OrganizerProfile>(
                state: vm,
                refreshable: false,
                builder: (context, p) => ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 18, AppSpacing.sideLight, 24),
                  children: [
                    Wrap(spacing: 6, children: [
                      TagLabel(p.identityVerified ? 'Identity verified' : 'Identity not verified', filled: p.identityVerified),
                      TagLabel(p.payoutVerified ? 'Payout verified' : 'Payout not verified', filled: p.payoutVerified),
                    ]),
                    const SizedBox(height: 16),
                    const SectionLabel('Organization'),
                    const SizedBox(height: 8),
                    LabeledTextField(label: 'Organization name', controller: _f('org', p.organizationName)),
                    const SizedBox(height: 12),
                    LabeledTextField(label: 'Description', controller: _f('desc', p.description), maxLines: 3),
                    const SizedBox(height: 12),
                    LabeledTextField(label: 'Contact email', controller: _f('email', p.contactEmail), keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    LabeledTextField(label: 'Contact phone', controller: _f('phone', p.contactPhone), keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    LabeledTextField(label: 'Website', controller: _f('web', p.website), keyboardType: TextInputType.url),
                    const SizedBox(height: AppSpacing.section),
                    const SectionLabel('Payout account · sandbox'),
                    const SizedBox(height: 8),
                    LabeledTextField(label: 'Bank', controller: _f('bank', p.payoutBankName), hintText: 'Kaspi Bank'),
                    const SizedBox(height: 12),
                    LabeledTextField(label: 'Account number', controller: _f('acc', p.payoutAccountNumber), hintText: 'KZ…'),
                    const SizedBox(height: 12),
                    LabeledTextField(label: 'Account holder', controller: _f('holder', p.payoutAccountHolder)),
                    const SizedBox(height: 12),
                    const DemoNotice(text: 'Payout details are used for a simulated payout only. No real transfers.'),
                  ],
                ),
              ),
            ),
            if (vm.data != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
                child: PrimaryButton(
                  label: 'Save profile',
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
                    if (context.mounted) reportResult(context, f, success: 'Profile saved.');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
