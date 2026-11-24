import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/failure.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
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

/// W4 · Seat map (§4.3.1, UC8). Цвет никогда не единственный признак:
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
    final vm = context.watch<SeatMapViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Choose your seats', subtitle: vm.cart.event.title, onBack: () => context.pop()),
            Expanded(
              child: LoadableView<List<SeatInfo>>(
                state: vm,
                isEmpty: (s) => s.isEmpty,
                empty: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sideLight),
                  child: MessageView(
                    icon: Icons.event_seat_outlined,
                    title: 'No seat map yet',
                    message: 'The organizer has not published a seating layout for this event.',
                  ),
                ),
                builder: (context, seats) => ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 16, AppSpacing.sideLight, 16),
                  children: [
                    const _Legend(),
                    const SizedBox(height: 16),
                    Container(
                      height: 28,
                      color: context.colors.neutralSoft,
                      alignment: Alignment.center,
                      child: Text('STAGE', style: AppText.sectionLabel.copyWith(color: context.colors.textMuted)),
                    ),
                    const SizedBox(height: 16),
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
          SectionLabel('Sec $name${price == null ? '' : ' · ${Fmt.money(price)}'}'
              '${seats.first.ticketTypeName == null ? '' : ' · ${seats.first.ticketTypeName}'}'),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final MapEntry(key: row, value: list) in rows.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        SizedBox(width: 24, child: Text(row, style: AppText.meta.copyWith(color: context.colors.textMuted))),
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

class _SeatBox extends StatelessWidget {
  const _SeatBox({required this.seat});

  final SeatInfo seat;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SeatMapViewModel>();
    final selected = vm.selected.contains(seat.id);
    final (Color bg, Color fg, String mark) = selected
        ? (context.colors.primary, context.colors.surface, '✓')
        : switch (seat.status) {
            SeatStatus.available => (context.colors.surface, context.colors.text, ''),
            SeatStatus.held => (context.colors.border, context.colors.textMuted, seat.heldByMe ? '✓' : 'H'),
            SeatStatus.sold => (context.colors.textMuted, context.colors.surface, '✕'),
            SeatStatus.unavailable => (context.colors.neutralSoft, context.colors.textMuted, '−'),
          };
    return Semantics(
      button: true,
      selected: selected,
      label: '${seat.label}, ${selected ? 'selected' : seat.status.name}',
      child: GestureDetector(
        onTap: () => vm.toggle(seat),
        child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(color: bg, border: Border.all(color: context.colors.border)),
          alignment: Alignment.center,
          child: Text(mark.isEmpty ? seat.number : mark, style: AppText.tag.copyWith(color: fg, fontSize: 10)),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget item(Color c, String mark, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(color: c, border: Border.all(color: context.colors.border)),
              alignment: Alignment.center,
              child: Text(mark, style: AppText.tag.copyWith(fontSize: 9, color: c == context.colors.surface ? context.colors.text : context.colors.surface)),
            ),
            const SizedBox(width: 6),
            Text(label, style: AppText.meta.copyWith(color: context.colors.textMuted)),
          ],
        );
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        item(context.colors.surface, '', 'Available'),
        item(context.colors.primary, '✓', 'Selected'),
        item(context.colors.border, 'H', 'Held'),
        item(context.colors.textMuted, '✕', 'Sold'),
        item(context.colors.neutralSoft, '−', 'Unavailable'),
      ],
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SeatMapViewModel>();
    final needed = vm.cart.ticketCount;
    final picked = vm.selected.length;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bg,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 12, AppSpacing.sideLight, AppSpacing.bottomClearance),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in vm.selectedSeats)
            Text('${s.label} · ${Fmt.money(s.price ?? 0)}', style: AppText.bodySecondary.copyWith(color: context.colors.text)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('$picked of $needed seats', style: AppText.bodySecondary.copyWith(color: context.colors.textMuted)),
              const Spacer(),
              Text(Fmt.money(vm.total), style: AppText.statNumeral.copyWith(fontSize: 22, color: context.colors.text)),
            ],
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Continue to checkout',
            isLoading: vm.isBusy,
            onPressed: vm.complete ? onContinue : null,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Seats are held for you for 10 minutes once you continue.',
                style: AppText.finePrint.copyWith(color: context.colors.textMuted)),
          ),
        ],
      ),
    );
  }
}
