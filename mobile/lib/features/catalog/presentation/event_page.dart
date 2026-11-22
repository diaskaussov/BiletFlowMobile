import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
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
import '../../../shared/domain/entities/commerce.dart';
import '../../checkout/domain/cart.dart';
import '../domain/catalog_domain.dart';
import 'calendar_sheet.dart';

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
  String? promoError;
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
        promoError = failure.message;
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
    final vm = context.watch<EventPageViewModel>();
    final cart = vm.cart;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: vm.data?.event.title ?? 'Event',
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
    final e = d.event;
    final now = DateTime.now();
    final promo = cart.promo;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (promo != null)
          Container(
            color: AppColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideLight, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${promo.code} APPLIED — ${promo.label.toUpperCase()}',
                          style: AppText.sectionLabel.copyWith(color: AppColors.paper)),
                      Text('Verified on the server. You will see the final total before paying.',
                          style: AppText.meta.copyWith(color: AppColors.paper.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: vm.removePromo,
                  child: Text('REMOVE', style: AppText.buttonGhost.copyWith(color: AppColors.paper)),
                ),
              ],
            ),
          ),
        EventImage(url: e.imageUrl, label: e.category, height: 150),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 18, AppSpacing.sideLight, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (e.category != null) TagLabel(e.category!),
                if (e.assignedSeating) const TagLabel('Assigned seating'),
                TagLabel(e.visibility.label),
              ]),
              const SizedBox(height: 12),
              Text(e.title, style: AppText.screenTitle.copyWith(color: AppColors.ink)),
              const SizedBox(height: 14),
              DetailGrid(rows: [
                if (e.startsAt != null) ('Date', Fmt.range(e.startsAt!, e.endsAt)),
                if (e.fullAddress.isNotEmpty) ('Venue', e.fullAddress),
                if (e.organizerName != null) ('Organizer', e.organizerName!),
                if (e.registrationClosesAt != null) ('Registration closes', Fmt.dateTime(e.registrationClosesAt!)),
              ]),
              if (e.description != null && e.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(e.description!, style: AppText.body.copyWith(color: AppColors.ink)),
              ],
              const SizedBox(height: AppSpacing.section),
              const SectionLabel('Tickets'),
              const SizedBox(height: 4),
              if (!e.isRegistrationOpen(now))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Registration is closed for this event.',
                      style: AppText.bodySecondary.copyWith(color: AppColors.neutral700)),
                ),
              if (d.ticketTypes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('No tickets are on sale yet.',
                      style: AppText.bodySecondary.copyWith(color: AppColors.neutral700)),
                ),
              for (final t in d.ticketTypes) _TicketTypeRow(type: t, cart: cart, open: e.isRegistrationOpen(now)),
              const SizedBox(height: AppSpacing.block),
              if (promo == null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: LabeledTextField(
                        label: 'Promo code',
                        controller: _promo,
                        hintText: 'Enter a code',
                        textInputAction: TextInputAction.done,
                        onSubmitted: (v) => vm.applyPromo(v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 96,
                      child: SecondaryButton(
                        label: vm.promoChecking ? '…' : 'Apply',
                        onPressed: vm.promoChecking ? null : () => vm.applyPromo(_promo.text),
                      ),
                    ),
                  ],
                ),
                if (vm.promoError != null) ...[
                  const SizedBox(height: 6),
                  Text(vm.promoError!, style: AppText.meta.copyWith(color: AppColors.ink)),
                ],
              ],
              const SizedBox(height: AppSpacing.section),
              GhostButton(
                label: 'Add to calendar · .ics',
                onPressed: () => showCalendarSheet(context, event: e, icsFile: vm.calendarFile),
              ),
              GhostButton(
                label: 'Contact support about this event',
                onPressed: () => context.push(
                  '${Routes.newSupportCase(Routes.attendeeSupport)}?eventId=${e.id}&about=${Uri.encodeQueryComponent(e.title)}',
                ),
              ),
            ],
          ),
        ),
      ],
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
    final vm = context.read<EventPageViewModel>();
    final t = type;
    final onSale = open && t.isOnSale(DateTime.now());
    final promo = cart.promo;
    final discounted = promo == null ? null : t.price - promo.discountFor(t.price);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name, style: AppText.listTitle.copyWith(color: AppColors.ink)),
                Row(
                  children: [
                    Text(
                      Fmt.money(t.price),
                      style: AppText.bodySecondary.copyWith(
                        color: AppColors.ink,
                        decoration: discounted != null && discounted < t.price ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (discounted != null && discounted < t.price) ...[
                      const SizedBox(width: 8),
                      Text(Fmt.money(discounted, freeWord: false),
                          style: AppText.bodySecondary.copyWith(color: AppColors.accent700)),
                    ],
                  ],
                ),
                Text(
                  [
                    if (t.description != null && t.description!.isNotEmpty) t.description!,
                    if (t.maxPerOrder != null) 'max ${t.maxPerOrder} per order',
                  ].join(' · '),
                  style: AppText.meta.copyWith(color: AppColors.neutral600),
                ),
                Text(
                  t.isSoldOut ? 'Sold out' : (onSale ? '${Fmt.count(t.remaining)} left' : 'Not on sale'),
                  style: AppText.meta.copyWith(color: t.isSoldOut ? AppColors.ink : AppColors.neutral500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          QuantityStepper(
            value: cart.quantities[t.id] ?? 0,
            max: t.orderLimit,
            enabled: onSale,
            onChanged: (v) => vm.setQuantity(t, v),
          ),
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
    final count = cart.ticketCount;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 12, AppSpacing.sideLight, AppSpacing.bottomClearance),
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
                      '$count ${count == 1 ? 'ticket' : 'tickets'}'
                      '${cart.discount > 0 ? ' · −${Fmt.money(cart.discount, freeWord: false)}' : ''}',
                      style: AppText.bodySecondary.copyWith(color: AppColors.neutral700),
                    ),
                  ),
                  Text(Fmt.money(cart.total), style: AppText.statNumeral.copyWith(fontSize: 22, color: AppColors.ink)),
                ],
              ),
            ),
          PrimaryButton(
            label: cart.needsSeats ? 'Choose seats' : 'Continue to checkout',
            onPressed: count == 0
                ? null
                : () => context.push(
                      cart.needsSeats ? Routes.seats(cart.event.id) : Routes.checkout,
                      extra: cart,
                    ),
          ),
          if (cart.needsSeats && count > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Seats are held for 10 minutes at checkout.',
                  style: AppText.finePrint.copyWith(color: AppColors.neutral600)),
            ),
        ],
      ),
    );
  }
}
