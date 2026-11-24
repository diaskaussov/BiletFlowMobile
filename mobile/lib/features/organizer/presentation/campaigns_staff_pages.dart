import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/presentation/failure_text.dart';
import '../../../core/error/result.dart';
import '../../../core/platform/document_actions.dart';
import '../../../core/presentation/l10n.dart';
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
import 'event_shell.dart';
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

/// Промо события: кампании, промокоды и Campaign QR (§4.14).
class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  Future<void> _create(BuildContext context, CampaignsViewModel vm) async {
    final draft = await showModalBottomSheet<CampaignDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CampaignSheet(),
    );
    if (draft == null) return;
    final (created, failure) = await vm.create(draft);
    if (!context.mounted) return;
    if (failure != null) {
      showMessage(context, failure.text(context));
    } else if (created != null) {
      _showQr(context, vm.eventId, created.code, draft.name);
    }
  }

  static void _showQr(BuildContext context, int eventId, String code, String name) {
    final l = context.l10n;
    final url = campaignUrl(eventId, code);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) {
        final c = sheet.colors;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TagLabel(l.campaignQrTitle, tone: Tone.info),
                const SizedBox(height: 8),
                Text(name, style: AppText.headerTitle.copyWith(color: c.text, fontSize: 20)),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.panel)),
                    child: QrImageView(data: url, size: 220, backgroundColor: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(color: c.bg, child: DetailGrid(rows: [(l.codeLabel, code), (l.linkLabel, url)])),
                const SizedBox(height: 10),
                Text(l.campaignQrNote(code), style: AppText.finePrint.copyWith(color: c.textMuted)),
                const SizedBox(height: 16),
                PrimaryButton(label: l.shareLink, icon: LucideIcons.share, onPressed: () => const DocumentActions().shareText(url, subject: name)),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: l.copyCode,
                  icon: LucideIcons.copy,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    showMessage(sheet, l.codeCopied);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<CampaignsViewModel>();
    final now = DateTime.now();
    return EventShell(
      eventId: vm.eventId,
      section: EventSection.promo,
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 8),
        child: PrimaryButton(label: l.createCampaign, icon: LucideIcons.plus, isLoading: vm.isBusy, onPressed: () => _create(context, vm)),
      ),
      body: LoadableView<List<CampaignInfo>>(
        state: vm,
        isEmpty: (x) => x.isEmpty,
        empty: Padding(
          padding: const EdgeInsets.all(AppSpacing.side),
          child: MessageView(icon: LucideIcons.ticketPercent, title: l.noCampaigns, message: l.noCampaignsHint),
        ),
        builder: (context, list) => ListView(
          padding: sectionPadding,
          children: [
            for (final p in list) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(p.name, style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700))),
                      TagLabel(
                        p.isLive(now) ? l.campLive : (p.active ? l.campNotLive : l.campDisabled),
                        tone: p.isLive(now) ? Tone.success : (p.active ? Tone.warning : Tone.neutral),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      if (p.code != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: c.primaryTint, borderRadius: BorderRadius.circular(6)),
                          child: Text(p.code!, style: AppText.mono.copyWith(color: c.primary, fontSize: 13)),
                        )
                      else
                        Text(l.codeHidden, style: AppText.meta.copyWith(color: c.textMuted)),
                      const Spacer(),
                      Text(
                        p.discountType == DiscountType.percentage
                            ? l.percentOff('${p.discountValue.round()}')
                            : l.amountOff(Fmt.money(p.discountValue, freeWord: false)),
                        style: AppText.bodyStrong.copyWith(color: c.text, fontWeight: FontWeight.w700),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: Text(
                          '${l.usedLabel}: ${p.redemptions}${p.maxRedemptions == null ? '' : ' / ${p.maxRedemptions}'}',
                          style: AppText.meta.copyWith(color: c.textMuted, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (p.validFrom != null || p.validTo != null)
                        Text(
                          '${p.validFrom == null ? l.salesNow : Fmt.date(p.validFrom!)} — ${p.validTo == null ? l.validOpen : Fmt.date(p.validTo!)}',
                          style: AppText.meta.copyWith(color: c.textMuted),
                        ),
                    ]),
                    if (p.maxRedemptions != null && p.maxRedemptions! > 0) ...[
                      const SizedBox(height: 6),
                      ProgressStrip(value: p.redemptions / p.maxRedemptions!),
                    ],
                    const SizedBox(height: 12),
                    Row(children: [
                      if (p.code != null)
                        Expanded(
                          child: SecondaryButton(
                            label: l.qrAndLink,
                            icon: LucideIcons.qrCode,
                            compact: true,
                            onPressed: () => _showQr(context, vm.eventId, p.code!, p.name),
                          ),
                        ),
                      if (p.code != null && p.active) const SizedBox(width: 10),
                      if (p.active)
                        Expanded(
                          child: SecondaryButton(
                            label: l.actDisable,
                            icon: LucideIcons.ban,
                            compact: true,
                            onPressed: () async {
                              final f = await vm.deactivate(p);
                              if (context.mounted) reportResult(context, f, success: l.campaignDisabled);
                            },
                          ),
                        ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(l.campaignsNote, style: AppText.finePrint.copyWith(color: c.textMuted)),
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
    final l = context.l10n;
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.newCampaign, style: AppText.headerTitle.copyWith(color: c.text, fontSize: 20)),
              const SizedBox(height: 14),
              LabeledTextField(label: l.nameLabel, controller: _name),
              const SizedBox(height: 12),
              ChoiceChips<DiscountType>(
                options: DiscountType.values,
                selected: _type,
                label: (t) => t == DiscountType.percentage ? l.discPercent : l.discFixed,
                onSelected: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: LabeledTextField(
                    label: _type == DiscountType.percentage ? l.discountPct : l.discountKzt,
                    controller: _value,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: LabeledTextField(label: l.maxRedemptions, controller: _max, keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              DateTimeField(label: l.validFrom, value: _from, onChanged: (t) => setState(() => _from = t)),
              const SizedBox(height: 12),
              DateTimeField(label: l.validTo, value: _to, onChanged: (t) => setState(() => _to = t)),
              if (_error != null) ...[
                const SizedBox(height: 10),
                InfoBanner(text: _error!, tone: Tone.danger),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                label: l.createAndQr,
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
                    setState(() => _error = problem.toFailure().text(context));
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

/// Персонал события: контролёры на входе (§4.8).
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
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<StaffViewModel>();
    return EventShell(
      eventId: vm.eventId,
      section: EventSection.staff,
      body: LoadableView<StaffData>(
        state: vm,
        builder: (context, d) => ListView(
          padding: sectionPadding,
          children: [
            InfoBanner(text: l.staffIntro, tone: Tone.info, icon: LucideIcons.shieldCheck),
            const SizedBox(height: 16),
            if (d.staff.isEmpty)
              Text(l.nobodyAssigned, style: AppText.bodySecondary.copyWith(color: c.textMuted))
            else
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(children: [
                  for (final (i, s) in d.staff.indexed)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(border: i == d.staff.length - 1 ? null : Border(bottom: BorderSide(color: c.border))),
                      child: Row(children: [
                        InitialAvatar(s.user.fullName, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.user.fullName, style: AppText.cardTitle.copyWith(color: c.text, fontWeight: FontWeight.w600)),
                              Text('${s.user.email} · ${l.userNo('${s.user.id}')}', style: AppText.finePrint.copyWith(color: c.textMuted)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: vm.isBusy
                              ? null
                              : () async {
                                  final f = await vm.remove(s);
                                  if (context.mounted) reportResult(context, f, success: l.staffRemoved);
                                },
                          style: TextButton.styleFrom(foregroundColor: c.danger),
                          child: Text(l.actRemove, style: AppText.bodyStrong),
                        ),
                      ]),
                    ),
                ]),
              ),
            const SizedBox(height: AppSpacing.section),
            SectionLabel(l.addEventAdmin),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: LabeledTextField(
                    label: l.userId,
                    controller: _userId,
                    compact: true,
                    keyboardType: TextInputType.number,
                    hintText: '4',
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: PrimaryButton(
                    label: l.actAdd,
                    onPressed: vm.isBusy
                        ? null
                        : () async {
                            final f = await vm.assign(_userId.text);
                            if (f == null) _userId.clear();
                            if (context.mounted) reportResult(context, f, success: l.staffAdded);
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l.staffIdNote, style: AppText.finePrint.copyWith(color: c.textMuted)),
          ],
        ),
      ),
    );
  }
}
