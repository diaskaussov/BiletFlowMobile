import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/platform/document_actions.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/form_widgets.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/people.dart';
import '../domain/organizer_operations_domain.dart';

/// Публичный адрес веб-приложения — в Campaign QR кладётся полная ссылка.
const webBase = 'https://biletflow.kz';

String campaignUrl(int eventId, String code) => '$webBase/events/$eventId?promo=${Uri.encodeQueryComponent(code)}';

// ─── O8 campaigns ──────────────────────────────────────────────────────────

class CampaignsViewModel extends Loadable<List<CampaignInfo>> {
  CampaignsViewModel({required this.eventId, required ManageCampaigns manage})
      : _manage = manage,
        super(() => manage.list(eventId));

  final int eventId;
  final ManageCampaigns _manage;

  Future<(CreatedCampaign?, Failure?)> create(CampaignDraft d) async {
    CreatedCampaign? created;
    final f = await run(() => _manage.create(eventId, d), onOk: (CreatedCampaign c) => created = c, reload: true);
    return (created, f);
  }

  Future<Failure?> deactivate(CampaignInfo c) => run(() => _manage.deactivate(c), reload: true);
}

/// O8 · Campaigns & Campaign QR (§4.14)
class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  Future<void> _create(BuildContext context, CampaignsViewModel vm) async {
    final draft = await showModalBottomSheet<CampaignDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bg,
      builder: (_) => const _CampaignSheet(),
    );
    if (draft == null) return;
    final (created, failure) = await vm.create(draft);
    if (!context.mounted) return;
    if (failure != null) {
      showMessage(context, failure.message);
    } else if (created != null) {
      _showQr(context, vm.eventId, created.code, draft.name);
    }
  }

  static void _showQr(BuildContext context, int eventId, String code, String name) {
    final url = campaignUrl(eventId, code);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bg,
      builder: (c) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sheetInset, 20, AppSpacing.sheetInset, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel('Campaign QR — not a ticket', color: context.colors.primary),
              const SizedBox(height: 6),
              Text(name, style: AppText.listTitle.copyWith(color: context.colors.text)),
              const SizedBox(height: 14),
              Center(
                child: BlueprintFrame(
                  background: context.colors.surface,
                  child: QrImageView(data: url, size: 220, backgroundColor: context.colors.surface),
                ),
              ),
              const SizedBox(height: 14),
              DetailGrid(rows: [('Code', code), ('Link', url)]),
              const SizedBox(height: 10),
              Text(
                'Opens the event page with $code pre-applied. The link carries the code, never a price — the server '
                'validates it. The scanner app refuses it at the gate.',
                style: AppText.finePrint.copyWith(color: context.colors.textMuted),
              ),
              const SizedBox(height: 14),
              PrimaryButton(label: 'Share link', onPressed: () => const DocumentActions().shareText(url, subject: name)),
              const SizedBox(height: AppSpacing.actionGap),
              SecondaryButton(
                label: 'Copy code',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  showMessage(c, 'Code copied.');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CampaignsViewModel>();
    final now = DateTime.now();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Campaigns', subtitle: 'Promo codes & Campaign QR', onBack: () => context.pop()),
            Expanded(
              child: LoadableView<List<CampaignInfo>>(
                state: vm,
                isEmpty: (l) => l.isEmpty,
                empty: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sideList),
                  child: MessageView(
                    icon: Icons.percent,
                    title: 'No campaigns yet',
                    message: 'A campaign gives a discount through a promo code and a trackable Campaign QR.',
                  ),
                ),
                builder: (context, list) => ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 16, AppSpacing.sideList, 24),
                  children: [
                    for (final c in list)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: context.colors.surface, border: Border.all(color: context.colors.border)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(child: Text(c.name, style: AppText.listTitle.copyWith(color: context.colors.text))),
                              TagLabel(c.isLive(now) ? 'Live' : (c.active ? 'Not live' : 'Disabled'), filled: c.isLive(now)),
                            ]),
                            const SizedBox(height: 8),
                            DetailGrid(rows: [
                              ('Code', c.code ?? 'Not returned by the server'),
                              ('Discount', c.discountType == DiscountType.percentage
                                  ? '${c.discountValue.round()}% off'
                                  : '${Fmt.money(c.discountValue, freeWord: false)} off'),
                              ('Used', '${c.redemptions}${c.maxRedemptions == null ? '' : ' / ${c.maxRedemptions}'}'),
                              if (c.validFrom != null || c.validTo != null)
                                ('Valid', '${c.validFrom == null ? 'now' : Fmt.date(c.validFrom!)} — ${c.validTo == null ? 'open' : Fmt.date(c.validTo!)}'),
                            ]),
                            if (c.maxRedemptions != null) ...[
                              const SizedBox(height: 8),
                              ProgressStrip(value: c.redemptions / c.maxRedemptions!),
                            ],
                            const SizedBox(height: 10),
                            Row(children: [
                              if (c.code != null)
                                Expanded(
                                  child: SecondaryButton(
                                    label: 'QR & link',
                                    onPressed: () => _showQr(context, vm.eventId, c.code!, c.name),
                                  ),
                                ),
                              if (c.code != null && c.active) const SizedBox(width: 10),
                              if (c.active)
                                Expanded(
                                  child: SecondaryButton(
                                    label: 'Disable',
                                    onPressed: () async {
                                      final f = await vm.deactivate(c);
                                      if (context.mounted) reportResult(context, f, success: 'Campaign disabled.');
                                    },
                                  ),
                                ),
                            ]),
                          ],
                        ),
                      ),
                    Text(
                      'Redemption limits are enforced on the server, one order at a time. Codes of campaigns '
                      'created on other devices are not returned by the API.',
                      style: AppText.finePrint.copyWith(color: context.colors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
              child: PrimaryButton(label: 'Create campaign', isLoading: vm.isBusy, onPressed: () => _create(context, vm)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignSheet extends StatefulWidget {
  const _CampaignSheet();

  @override
  State<_CampaignSheet> createState() => _CampaignSheetState();
}

class _CampaignSheetState extends State<_CampaignSheet> {
  final _name = TextEditingController();
  final _value = TextEditingController();
  final _max = TextEditingController();
  DiscountType _type = DiscountType.percentage;
  DateTime? _from = DateTime.now();
  DateTime? _to;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _value, _max]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sheetInset, 20, AppSpacing.sheetInset, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel('New campaign', color: context.colors.primary),
              const SizedBox(height: 14),
              LabeledTextField(label: 'Name', controller: _name, hintText: 'Student discount'),
              const SizedBox(height: 12),
              ChoiceChips<DiscountType>(
                options: DiscountType.values,
                selected: _type,
                label: (t) => t == DiscountType.percentage ? 'Percentage' : 'Fixed ₸',
                onSelected: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: LabeledTextField(
                    label: _type == DiscountType.percentage ? 'Discount, %' : 'Discount, ₸',
                    controller: _value,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: LabeledTextField(label: 'Max redemptions', controller: _max, keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              DateTimeField(label: 'Valid from', value: _from, onChanged: (t) => setState(() => _from = t)),
              const SizedBox(height: 12),
              DateTimeField(label: 'Valid to', value: _to, onChanged: (t) => setState(() => _to = t)),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: AppText.bodySecondary.copyWith(color: context.colors.text)),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Create and get QR',
                onPressed: () {
                  final d = CampaignDraft(
                    name: _name.text,
                    discountType: _type,
                    discountValue: double.tryParse(_value.text) ?? 0,
                    maxRedemptions: int.tryParse(_max.text),
                    validFrom: _from,
                    validTo: _to,
                  );
                  final problem = d.validate();
                  if (problem != null) {
                    setState(() => _error = problem);
                  } else {
                    Navigator.of(context).pop(d);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── O10 staff ─────────────────────────────────────────────────────────────

class StaffData {
  const StaffData({required this.staff, this.overview});

  final List<StaffAssignment> staff;
  final CheckInOverview? overview;
}

class StaffViewModel extends Loadable<StaffData> {
  StaffViewModel({required this.eventId, required ManageStaff manage, required GetCheckInOverview overview})
      : _manage = manage,
        super(() async {
          final r = await manage.list(eventId);
          if (r case Err(:final failure)) return Err(failure);
          return Ok(StaffData(staff: r.valueOrNull!, overview: (await overview(eventId)).valueOrNull));
        });

  final int eventId;
  final ManageStaff _manage;

  Future<Failure?> assign(String userId) =>
      run(() => _manage.assign(eventId, userId, data?.staff ?? const []), reload: true);

  Future<Failure?> remove(StaffAssignment s) => run(() => _manage.remove(s), reload: true);
}

/// O10 · Check-in staff (§4.8)
class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final _userId = TextEditingController();

  @override
  void dispose() {
    _userId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StaffViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Check-in staff', onBack: () => context.pop()),
            Expanded(
              child: LoadableView<StaffData>(
                state: vm,
                builder: (context, d) => ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 16, AppSpacing.sideList, 24),
                  children: [
                    Text(
                      'People you add can sign into the scanner app and see this event only. They never see '
                      'revenue, orders or your other events.',
                      style: AppText.bodySecondary.copyWith(color: context.colors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    if (d.staff.isEmpty)
                      Text('Nobody is assigned yet.', style: AppText.bodySecondary.copyWith(color: context.colors.textMuted)),
                    for (final s in d.staff)
                      ListRow(
                        title: s.user.fullName,
                        subtitle: '${s.user.email} · user #${s.user.id}',
                        trailing: TextButton(
                          onPressed: vm.isBusy
                              ? null
                              : () async {
                                  final f = await vm.remove(s);
                                  if (context.mounted) reportResult(context, f, success: 'Removed from this event.');
                                },
                          child: Text('REMOVE', style: AppText.buttonGhost.copyWith(color: context.colors.primary)),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.section),
                    const SectionLabel('Add an event admin'),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: LabeledTextField(
                            label: 'User ID',
                            controller: _userId,
                            keyboardType: TextInputType.number,
                            hintText: 'e.g. 4',
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 96,
                          child: SecondaryButton(
                            label: 'Add',
                            onPressed: vm.isBusy
                                ? null
                                : () async {
                                    final f = await vm.assign(_userId.text);
                                    if (f == null) _userId.clear();
                                    if (context.mounted) reportResult(context, f, success: 'Added. They can sign into the scanner now.');
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The API assigns staff by user ID only — adding by email is not available yet. The person '
                      'needs an EVENT_ADMIN account.',
                      style: AppText.finePrint.copyWith(color: context.colors.textMuted),
                    ),
                    if (d.overview != null) ...[
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('Live gate activity'),
                      const SizedBox(height: 6),
                      DetailGrid(rows: [
                        ('Checked in', '${d.overview!.checkedIn} of ${d.overview!.registered}'),
                        ('Reversals', '${d.overview!.reversed}'),
                      ]),
                      const SizedBox(height: 8),
                      if (d.overview!.recent.isEmpty)
                        Text('No check-ins yet.', style: AppText.meta.copyWith(color: context.colors.textMuted)),
                      for (final r in d.overview!.recent)
                        ValueRow(
                          label: '${r.who} checked in',
                          value: [if (r.at != null) Fmt.time(r.at!), ?r.by].join(' · '),
                        ),
                    ],
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
