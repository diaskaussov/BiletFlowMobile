import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
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
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../../checkout/domain/cart.dart';
import '../domain/catalog_domain.dart';
import 'calendar_sheet.dart';
import '../../../core/presentation/failure_text.dart';
import '../../../core/error/failure.dart';

class EventPageViewModel extends Loadable<EventPageData> {
  EventPageViewModel({
    required this.eventId,
    required GetEventPage getPage,
    required this._applyPromo,
    required this.calendarFile,
    this.initialPromo,
  })  : super(() => getPage(eventId));

  final int eventId;
  final ApplyPromo _applyPromo;
  final Future<Result<Uint8List>> Function() calendarFile;
  final String? initialPromo;

  Cart? _cart;
  Failure? promoError;
  bool promoChecking = false;

  Cart? get cart {
    final d = data;
    if (d == null) return null;
    return _cart ??= Cart(event: d.event, ticketTypes: d.ticketTypes);
  }

  @override
  Future<void> load() async {
    await super.load();
    _cart = null;
    final code = initialPromo;
    if (code != null && cart?.promo == null) await applyPromo(code);
  }

  void setQuantity(TicketTypeInfo t, int qty) {
    _cart = cart?.withQuantity(t, qty);
    notifyListeners();
  }

  Future<void> applyPromo(String code) async {
    promoChecking = true;
    promoError = null;
    notifyListeners();
    final r = await _applyPromo(code: code, eventId: eventId);
    promoChecking = false;
    switch (r) {
      case Ok(:final value):
        _cart = cart?.copyWith(promo: () => value);
      case Err(:final failure):
        promoError = failure;
    }
    notifyListeners();
  }

  void removePromo() {
    _cart = cart?.copyWith(promo: () => null);
    notifyListeners();
  }
}

/// W2 · Event page / W3 · Campaign landing — promo applied
class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final _promo = TextEditingController();

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final vm = context.watch<EventPageViewModel>();
    final cart = vm.cart;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: vm.data?.event.title ?? l.eventFallback,
              subtitle: vm.data?.event.category,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: LoadableView<EventPageData>(
                state: vm,
                builder: (context, d) => _content(context, vm, d, cart!),
              ),
            ),
            if (cart != null) _CheckoutBar(cart: cart),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, EventPageViewModel vm, EventPageData d, Cart cart) {
    final l = context.l10n;
    final c = context.colors;
    final e = d.event;
    final now = DateTime.now();
    final promo = cart.promo;
    final open = e.isRegistrationOpen(now);
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
      children: [
        if (promo != null) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Icon(LucideIcons.ticketPercent, size: 22, color: c.onPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.promoApplied(promo.code, _discount(l, promo)), style: AppText.bodyStrong.copyWith(color: c.onPrimary)),
                      Text(l.promoVerified, style: AppText.caption.copyWith(color: c.onPrimary.withValues(alpha: 0.85), fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l.actRemove,
                  onPressed: vm.removePromo,
                  icon: Icon(LucideIcons.x, size: 18, color: c.onPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        EventImage(url: e.imageUrl, label: e.category ?? e.title, height: 180, radius: AppRadius.panel),
        const SizedBox(height: 16),
        Wrap(spacing: 6, runSpacing: 6, children: [
          if (e.category != null) TagLabel(e.category!, tone: Tone.primary, dot: false),
          if (e.assignedSeating) TagLabel(l.seatedTag, tone: Tone.info, dot: false),
          if (e.visibility != EventVisibility.public) TagLabel(e.visibility.text(l), dot: false),
        ]),
        const SizedBox(height: 10),
        Text(e.title, style: AppText.screenTitle.copyWith(color: c.text)),
        const SizedBox(height: 14),
        AppCard(
          child: Column(children: [
            if (e.startsAt != null) _InfoLine(icon: LucideIcons.calendar, text: Fmt.range(e.startsAt!, e.endsAt)),
            if (e.fullAddress.isNotEmpty) _InfoLine(icon: LucideIcons.mapPin, text: e.fullAddress),
            if (e.organizerName != null) _InfoLine(icon: LucideIcons.building2, text: e.organizerName!),
            if (e.registrationClosesAt != null)
              _InfoLine(icon: LucideIcons.clock, text: '${l.regClosesLabel}: ${Fmt.dateTime(e.registrationClosesAt!)}'),
          ]),
        ),
        if (e.description != null && e.description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(e.description!, style: AppText.body.copyWith(color: c.text, height: 1.45)),
        ],
        const SizedBox(height: AppSpacing.section),
        SectionLabel(l.secTickets),
        const SizedBox(height: 10),
        if (!open) ...[
          InfoBanner(text: l.registrationClosed, tone: Tone.warning),
          const SizedBox(height: 10),
        ],
        if (d.ticketTypes.isEmpty) Text(l.noTicketsOnSale, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
        for (final t in d.ticketTypes) ...[
          _TicketTypeRow(type: t, cart: cart, open: open),
          const SizedBox(height: 10),
        ],
        if (promo == null) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: LabeledTextField(
                  label: l.promoCodeLabel,
                  controller: _promo,
                  compact: true,
                  hintText: l.enterCodeHint,
                  hasError: vm.promoError != null,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (v) => vm.applyPromo(v),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: SecondaryButton(
                  label: l.actApply,
                  compact: true,
                  onPressed: vm.promoChecking ? null : () => vm.applyPromo(_promo.text),
                ),
              ),
            ],
          ),
          if (vm.promoError != null) ...[
            const SizedBox(height: 8),
            Text(vm.promoError!.text(context), style: AppText.meta.copyWith(color: c.dangerText)),
          ],
        ],
        const SizedBox(height: AppSpacing.section),
        Row(children: [
          Expanded(
            child: SecondaryButton(
              label: l.addToCalendar,
              icon: LucideIcons.calendarPlus,
              compact: true,
              onPressed: () => showCalendarSheet(context, event: e, icsFile: vm.calendarFile),
            ),
          ),
        ]),
        GhostButton(
          label: l.contactSupportEvent,
          icon: LucideIcons.lifeBuoy,
          onPressed: () => context.push(
            '${Routes.newSupportCase(Routes.attendeeSupport)}?eventId=${e.id}&about=${Uri.encodeQueryComponent(e.title)}',
          ),
        ),
      ],
    );
  }
}

String _discount(AppLocalizations l, PromoValidation p) => p.discountType == DiscountType.percentage
    ? l.percentOff(p.discountValue.toStringAsFixed(p.discountValue % 1 == 0 ? 0 : 1))
    : l.amountOff(Fmt.money(p.discountValue, freeWord: false));

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: c.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppText.bodySecondary.copyWith(color: c.text))),
      ]),
    );
  }
}

class _TicketTypeRow extends StatelessWidget {
  const _TicketTypeRow({required this.type, required this.cart, required this.open});

  final TicketTypeInfo type;
  final Cart cart;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.read<EventPageViewModel>();
    final t = type;
    final onSale = open && t.isOnSale(DateTime.now());
    final promo = cart.promo;
    final discounted = promo == null ? null : t.price - promo.discountFor(t.price);
    final qty = cart.quantities[t.id] ?? 0;
    return AppCard(
      borderColor: qty > 0 ? c.primary : null,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name, style: AppText.listTitle.copyWith(color: c.text, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      Fmt.money(t.price),
                      style: AppText.bodyStrong.copyWith(
                        color: discounted != null && discounted < t.price ? c.textMuted : c.text,
                        decoration: discounted != null && discounted < t.price ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (discounted != null && discounted < t.price) ...[
                      const SizedBox(width: 8),
                      Text(Fmt.money(discounted, freeWord: false), style: AppText.bodyStrong.copyWith(color: c.primary)),
                    ],
                  ],
                ),
                if ((t.description ?? '').isNotEmpty || t.maxPerOrder != null)
                  Text(
                    [if ((t.description ?? '').isNotEmpty) t.description!, if (t.maxPerOrder != null) l.maxPerOrderN(t.maxPerOrder!)].join(' · '),
                    style: AppText.meta.copyWith(color: c.textMuted),
                  ),
                const SizedBox(height: 2),
                Text(
                  t.isSoldOut ? l.soldOut : (onSale ? l.leftN(Fmt.count(t.remaining)) : l.ttNotOnSale),
                  style: AppText.caption.copyWith(color: t.isSoldOut ? c.danger : c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          QuantityStepper(value: qty, max: t.orderLimit, enabled: onSale, onChanged: (v) => vm.setQuantity(t, v)),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final count = cart.ticketCount;
    return Container(
      decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.border))),
      padding: const EdgeInsets.fromLTRB(AppSpacing.side, 12, AppSpacing.side, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l.ticketsCount(count)}${cart.discount > 0 ? ' · −${Fmt.money(cart.discount, freeWord: false)}' : ''}',
                      style: AppText.bodySecondary.copyWith(color: c.textMuted),
                    ),
                  ),
                  Text(Fmt.money(cart.total), style: AppText.statNumeral.copyWith(fontSize: 22, color: c.text)),
                ],
              ),
            ),
          PrimaryButton(
            label: cart.needsSeats ? l.chooseSeats : l.continueCheckout,
            trailingIcon: LucideIcons.arrowRight,
            onPressed: count == 0
                ? null
                : () => context.push(cart.needsSeats ? Routes.seats(cart.event.id) : Routes.checkout, extra: cart),
          ),
          if (cart.needsSeats && count > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l.seatsHeldNote, style: AppText.finePrint.copyWith(color: c.textMuted)),
            ),
        ],
      ),
    );
  }
}
