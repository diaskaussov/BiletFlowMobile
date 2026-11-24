import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/result.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/status_text.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/screen_header.dart';
import '../../auth/presentation/controllers/session_controller.dart';
import '../domain/cart.dart';
import '../domain/checkout_domain.dart';
import '../../../core/presentation/safe_notifier.dart';
import '../../../core/presentation/failure_text.dart';
import '../../../core/error/failure.dart';

enum PaymentMethod { card, kaspi }

class CheckoutViewModel extends ChangeNotifier with SafeNotifier {
  CheckoutViewModel({required this.cart, required PlaceOrder placeOrder, required this._release})
      : _place = placeOrder {
    if (cart.heldUntil != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
    }
  }

  final Cart cart;
  final PlaceOrder _place;
  final ReleaseSeats _release;
  Timer? _timer;

  PaymentMethod method = PaymentMethod.card;
  bool isPaying = false;
  Failure? error;

  Duration? get holdLeft => cart.heldUntil?.difference(DateTime.now());
  bool get holdExpired => holdLeft != null && holdLeft!.isNegative;

  void setMethod(PaymentMethod m) {
    method = m;
    notifyListeners();
  }

  /// id заказа при успехе.
  Future<int?> pay(BuyerDetails buyer) async {
    isPaying = true;
    error = null;
    notifyListeners();
    final r = await _place(cart, buyer);
    isPaying = false;
    switch (r) {
      case Ok(:final value):
        _timer?.cancel();
        notifyListeners();
        return value.id;
      case Err(:final failure):
        error = failure;
        notifyListeners();
        return null;
    }
  }

  Future<void> releaseSeats() => _release(cart);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// W5 · Оформление заказа (§4.6, UC3).
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final s = context.read<SessionController>().session;
    _first = TextEditingController(text: s?.firstName ?? '');
    _last = TextEditingController(text: s?.lastName ?? '');
    _email = TextEditingController(text: s?.email ?? '');
  }

  @override
  void dispose() {
    for (final c in [_first, _last, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pay(CheckoutViewModel vm) async {
    FocusScope.of(context).unfocus();
    final id = await vm.pay(BuyerDetails(firstName: _first.text, lastName: _last.text, email: _email.text));
    if (id != null && mounted) context.go(Routes.order(id));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<CheckoutViewModel>();
    final cart = vm.cart;
    final left = vm.holdLeft;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && cart.seats.isNotEmpty) vm.releaseSeats();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                subtitle: cart.needsSeats ? l.stepsSeats : l.stepsNoSeats,
                title: l.checkoutTitle,
                onBack: () => context.pop(),
              ),
              if (left != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 8),
                  child: InfoBanner(
                    icon: vm.holdExpired ? LucideIcons.timerOff : LucideIcons.timer,
                    tone: vm.holdExpired ? Tone.danger : Tone.primary,
                    text: vm.holdExpired ? l.holdExpired : l.holdExpiresIn(Fmt.countdown(left)),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 20),
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        EventImage(url: cart.event.imageUrl, label: cart.event.title, height: 56, width: 56, radius: 12),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cart.event.title, style: AppText.cardTitle.copyWith(color: c.text)),
                              if (cart.event.startsAt != null)
                                Text('${Fmt.dateTime(cart.event.startsAt!)} · ${cart.event.venueLine}',
                                    style: AppText.meta.copyWith(color: c.textMuted)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    SectionLabel(l.yourDetails),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: LabeledTextField(label: l.firstName, controller: _first, textInputAction: TextInputAction.next)),
                      const SizedBox(width: 10),
                      Expanded(child: LabeledTextField(label: l.lastName, controller: _last, textInputAction: TextInputAction.next)),
                    ]),
                    const SizedBox(height: 14),
                    LabeledTextField(label: l.emailTickets, controller: _email, keyboardType: TextInputType.emailAddress),
                    if (!cart.isFree) ...[
                      const SizedBox(height: AppSpacing.section),
                      SectionLabel(l.paymentSection),
                      const SizedBox(height: 10),
                      ChoiceChips<PaymentMethod>(
                        options: PaymentMethod.values,
                        selected: vm.method,
                        label: (m) => m == PaymentMethod.card ? l.payCard : l.payKaspi,
                        onSelected: vm.setMethod,
                      ),
                      const SizedBox(height: 12),
                      const DemoNotice(),
                    ],
                    const SizedBox(height: AppSpacing.section),
                    SectionLabel(l.orderSummary),
                    const SizedBox(height: 10),
                    AppCard(
                      child: Column(
                        children: [
                          DetailGrid(rows: [
                            for (final (type, qty) in cart.lines) ...[
                              ('$qty × ${type.name}', Fmt.money(type.price * qty)),
                              for (final s in cart.seatsFor(type.id)) ('   ${s.text(l)}', ''),
                            ],
                            if (cart.promo != null) (l.discountCode(cart.promo!.code), '− ${Fmt.money(cart.discount, freeWord: false)}'),
                          ]),
                          Divider(height: 24, color: c.border),
                          Row(children: [
                            Text(l.totalKzt, style: AppText.sectionLabel.copyWith(color: c.text)),
                            const Spacer(),
                            Text(Fmt.money(cart.total), style: AppText.statNumeral.copyWith(color: c.text)),
                          ]),
                        ],
                      ),
                    ),
                    if (cart.promo != null) ...[
                      const SizedBox(height: 8),
                      Text(l.serverRecalcs, style: AppText.finePrint.copyWith(color: c.textMuted)),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 16),
                child: Column(
                  children: [
                    if (vm.error != null) ...[
                      InfoBanner(text: vm.error!.text(context), tone: Tone.danger),
                      const SizedBox(height: 10),
                    ],
                    PrimaryButton(
                      label: cart.isFree ? l.getFreeTickets : l.payAmount(Fmt.money(cart.total)),
                      icon: cart.isFree ? LucideIcons.ticket : LucideIcons.creditCard,
                      large: true,
                      isLoading: vm.isPaying,
                      onPressed: vm.holdExpired ? null : () => _pay(vm),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cart.isFree ? l.freeConfirmedNote : l.paidConfirmedNote,
                      textAlign: TextAlign.center,
                      style: AppText.finePrint.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
