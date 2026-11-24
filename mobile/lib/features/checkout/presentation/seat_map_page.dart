import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/status_text.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../domain/cart.dart';
import '../domain/checkout_domain.dart';
import '../../../core/presentation/failure_text.dart';

class SeatMapViewModel extends Loadable<List<SeatInfo>> {
  SeatMapViewModel({required this.cart, required LoadSeatMap load, required this._hold})
      : super(() => load(cart.event.id));

  final Cart cart;
  final HoldSeats _hold;
  final Set<int> selected = {};

  List<SeatInfo> get selectedSeats => [for (final s in data ?? const <SeatInfo>[]) if (selected.contains(s.id)) s];

  int neededFor(int typeId) => cart.quantities[typeId] ?? 0;

  int pickedFor(int typeId) => selectedSeats.where((s) => s.ticketTypeId == typeId).length;

  /// Место можно выбрать, если его тип есть в корзине и лимит не выбран.
  bool canToggle(SeatInfo s) {
    if (selected.contains(s.id)) return true;
    if (!s.selectable) return false;
    final type = s.ticketTypeId;
    if (type == null) return false;
    return pickedFor(type) < neededFor(type);
  }

  void toggle(SeatInfo s) {
    if (!canToggle(s)) return;
    selected.contains(s.id) ? selected.remove(s.id) : selected.add(s.id);
    notifyListeners();
  }

  bool get complete => cart.lines.every((l) => pickedFor(l.$1.id) == l.$2);

  double get total => selectedSeats.fold(0, (sum, s) => sum + (s.price ?? cart.typeById(s.ticketTypeId ?? -1)?.price ?? 0));

  Future<(Cart?, Failure?)> holdSelection() async {
    Cart? held;
    final f = await run(() => _hold(cart, selectedSeats), onOk: (Cart c) => held = c);
    return (held, f);
  }
}

/// W4 · Схема мест (§4.3.1, UC8). Цвет никогда не единственный признак:
/// у каждого состояния есть символ.
class SeatMapPage extends StatelessWidget {
  const SeatMapPage({super.key});

  Future<void> _continue(BuildContext context, SeatMapViewModel vm) async {
    final (held, failure) = await vm.holdSelection();
    if (!context.mounted) return;
    if (failure != null) {
      showMessage(context, failure.text(context));
      await vm.load();
      vm.selected.clear();
      return;
    }
    context.push(Routes.checkout, extra: held);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final vm = context.watch<SeatMapViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(subtitle: vm.cart.event.title, title: l.chooseYourSeats, onBack: () => context.pop()),
            Expanded(
              child: LoadableView<List<SeatInfo>>(
                state: vm,
                isEmpty: (s) => s.isEmpty,
                empty: Padding(
                  padding: const EdgeInsets.all(AppSpacing.side),
                  child: MessageView(icon: LucideIcons.armchair, title: l.noSeatMapBuyer, message: l.noSeatMapBuyerHint),
                ),
                builder: (context, seats) => ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 16),
                  children: [
                    const _Legend(),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 240,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppPalette.camera,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(30)),
                        ),
                        child: Text(l.stage, style: AppText.badge.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final section in _sections(seats)) _SectionMap(name: section.$1, seats: section.$2),
                  ],
                ),
              ),
            ),
            _SelectionBar(onContinue: () => _continue(context, vm)),
          ],
        ),
      ),
    );
  }

  static List<(String, List<SeatInfo>)> _sections(List<SeatInfo> seats) {
    final map = <String, List<SeatInfo>>{};
    for (final s in seats) {
      map.putIfAbsent(s.section, () => []).add(s);
    }
    return [for (final e in map.entries) (e.key, e.value)];
  }
}

class _SectionMap extends StatelessWidget {
  const _SectionMap({required this.name, required this.seats});

  final String name;
  final List<SeatInfo> seats;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final rows = <String, List<SeatInfo>>{};
    for (final s in seats) {
      rows.putIfAbsent(s.row, () => []).add(s);
    }
    final price = seats.first.price;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(l.sectionDefault(name), style: AppText.cardTitle.copyWith(color: c.text)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                [?seats.first.ticketTypeName, if (price != null) Fmt.money(price)].join(' · '),
                style: AppText.meta.copyWith(color: c.textMuted),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final MapEntry(key: row, value: list) in rows.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(width: 26, child: Text(row, style: AppText.caption.copyWith(color: c.textMuted))),
                        for (final s in list..sort((a, b) => (int.tryParse(a.number) ?? 0).compareTo(int.tryParse(b.number) ?? 0)))
                          _SeatBox(seat: s),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Вид места: заливка, цвет текста, символ (цвет — не единственный признак).
(Color, Color, Color?, String) _seatLook(AppPalette c, SeatStatus status, {bool selected = false, bool mine = false}) => selected
    ? (c.primary, c.onPrimary, null, '✓')
    : switch (status) {
        SeatStatus.available => (c.surface, c.text, c.primary.withValues(alpha: 0.5), ''),
        SeatStatus.held => (c.warningSoft, c.warningText, null, mine ? '✓' : '·'),
        SeatStatus.sold => (c.neutralSoft, c.textMuted, null, '✕'),
        SeatStatus.unavailable => (c.bg, c.textMuted, c.border, '−'),
      };

class _SeatBox extends StatelessWidget {
  const _SeatBox({required this.seat});

  final SeatInfo seat;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<SeatMapViewModel>();
    final selected = vm.selected.contains(seat.id);
    final (bg, fg, border, mark) = _seatLook(c, seat.status, selected: selected, mine: seat.heldByMe);
    final state = selected
        ? l.seatSelected
        : switch (seat.status) {
            SeatStatus.available => l.seatAvailable,
            SeatStatus.held => l.seatHeld,
            SeatStatus.sold => l.seatSold,
            SeatStatus.unavailable => l.seatUnavailable,
          };
    return Semantics(
      button: true,
      selected: selected,
      label: '${seat.text(l)}, $state',
      child: GestureDetector(
        onTap: () => vm.toggle(seat),
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: border == null ? null : Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Text(mark.isEmpty ? seat.number : mark, style: AppText.badge.copyWith(color: fg, fontSize: 11)),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    Widget item(SeatStatus s, String label, {bool selected = false}) {
      final (bg, fg, border, mark) = _seatLook(c, s, selected: selected);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6), border: border == null ? null : Border.all(color: border)),
            child: Text(mark, style: AppText.badge.copyWith(fontSize: 10, color: fg)),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppText.caption.copyWith(color: c.textMuted)),
        ],
      );
    }

    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        item(SeatStatus.available, l.seatAvailable),
        item(SeatStatus.available, l.seatSelected, selected: true),
        item(SeatStatus.held, l.seatHeld),
        item(SeatStatus.sold, l.seatSold),
        item(SeatStatus.unavailable, l.seatUnavailable),
      ],
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<SeatMapViewModel>();
    final needed = vm.cart.ticketCount;
    final picked = vm.selected.length;
    return Container(
      decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.border))),
      padding: const EdgeInsets.fromLTRB(AppSpacing.side, 12, AppSpacing.side, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vm.selectedSeats.isNotEmpty)
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final s in vm.selectedSeats) TagLabel('${s.section}-${s.row}-${s.number}', tone: Tone.primary, dot: false),
            ]),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(l.pickedOf(picked, needed), style: AppText.bodySecondary.copyWith(color: c.textMuted)),
              const Spacer(),
              Text(Fmt.money(vm.total), style: AppText.statNumeral.copyWith(fontSize: 22, color: c.text)),
            ],
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: l.continueCheckout,
            trailingIcon: LucideIcons.arrowRight,
            isLoading: vm.isBusy,
            onPressed: vm.complete ? onContinue : null,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l.seatsHeldContinue, style: AppText.finePrint.copyWith(color: c.textMuted)),
          ),
        ],
      ),
    );
  }
}
