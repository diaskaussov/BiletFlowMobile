import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/result.dart';
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
  String? error;

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
        error = failure.message;
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

/// W5 · Checkout (§4.6, UC3)
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
                title: 'Checkout',
                subtitle: cart.needsSeats ? '1 Seats › 2 Details & payment › 3 Tickets' : '1 Details & payment › 2 Tickets',
                onBack: () => context.pop(),
              ),
              if (left != null)
                Container(
                  width: double.infinity,
                  color: vm.holdExpired ? context.colors.text : context.colors.primaryTint,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideLight, vertical: 10),
                  child: Text(
                    vm.holdExpired ? 'SEAT HOLD EXPIRED — GO BACK AND CHOOSE AGAIN' : 'HOLD EXPIRES IN ${Fmt.countdown(left)}',
                    style: AppText.statusStrip.copyWith(color: vm.holdExpired ? context.colors.surface : context.colors.primary),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 20, AppSpacing.sideLight, 20),
                  children: [
                    const SectionLabel('Your details'),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: LabeledTextField(label: 'First name', controller: _first, textInputAction: TextInputAction.next)),
                      const SizedBox(width: 10),
                      Expanded(child: LabeledTextField(label: 'Last name', controller: _last, textInputAction: TextInputAction.next)),
                    ]),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: 'Email — tickets are sent here',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (!cart.isFree) ...[
                      const SizedBox(height: AppSpacing.section),
                      const SectionLabel('Payment'),
                      const SizedBox(height: 10),
                      ChoiceChips<PaymentMethod>(
                        options: PaymentMethod.values,
                        selected: vm.method,
                        label: (m) => m == PaymentMethod.card ? 'Card · sandbox' : 'Kaspi transfer · sandbox',
                        onSelected: vm.setMethod,
                      ),
                      const SizedBox(height: 12),
                      const DemoNotice(),
                    ],
                    const SizedBox(height: AppSpacing.section),
                    const SectionLabel('Order summary'),
                    const SizedBox(height: 8),
                    Text(cart.event.title, style: AppText.listTitle.copyWith(color: context.colors.text)),
                    if (cart.event.startsAt != null)
                      Text('${Fmt.dateTime(cart.event.startsAt!)} · ${cart.event.venueLine}',
                          style: AppText.meta.copyWith(color: context.colors.textMuted)),
                    const SizedBox(height: 12),
                    DetailGrid(rows: [
                      for (final (type, qty) in cart.lines) ...[
                        ('$qty × ${type.name}', Fmt.money(type.price * qty)),
                        for (final s in cart.seatsFor(type.id)) ('   ${s.label}', ''),
                      ],
                      if (cart.promo != null) ('Discount ${cart.promo!.code}', '− ${Fmt.money(cart.discount, freeWord: false)}'),
                    ]),
                    const Divider(height: 24),
                    Row(children: [
                      Text('TOTAL · KZT', style: AppText.sectionLabel.copyWith(color: context.colors.text)),
                      const Spacer(),
                      Text(Fmt.money(cart.total), style: AppText.statNumeral.copyWith(color: context.colors.text)),
                    ]),
                    if (cart.promo != null)
                      Text('The server recalculates the discount; the charged total may differ slightly.',
                          style: AppText.finePrint.copyWith(color: context.colors.textMuted)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
                child: Column(
                  children: [
                    if (vm.error != null) ...[
                      Text(vm.error!, style: AppText.bodySecondary.copyWith(color: context.colors.text)),
                      const SizedBox(height: 8),
                    ],
                    PrimaryButton(
                      label: cart.isFree ? 'Get free tickets' : 'Pay ${Fmt.money(cart.total)}',
                      isLoading: vm.isPaying,
                      onPressed: vm.holdExpired ? null : () => _pay(vm),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cart.isFree
                          ? 'Free orders are confirmed immediately and tickets are issued at once.'
                          : 'Tickets are issued only after the sandbox confirms payment.',
                      style: AppText.finePrint.copyWith(color: context.colors.textMuted),
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
