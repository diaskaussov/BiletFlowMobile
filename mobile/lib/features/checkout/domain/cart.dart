import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../../catalog/domain/catalog_domain.dart';

/// Корзина между W2 → W4 → W5: выбранные типы, промокод, удержанные места.
class Cart {
  const Cart({
    required this.event,
    required this.ticketTypes,
    this.quantities = const {},
    this.promo,
    this.seats = const [],
    this.heldUntil,
  });

  final EventInfo event;
  final List<TicketTypeInfo> ticketTypes;

  /// id типа → количество.
  final Map<int, int> quantities;
  final PromoValidation? promo;
  final List<SeatInfo> seats;
  final DateTime? heldUntil;

  int get ticketCount => quantities.values.fold(0, (a, b) => a + b);
  bool get isEmpty => ticketCount == 0;
  bool get needsSeats => event.assignedSeating;

  TicketTypeInfo? typeById(int id) => ticketTypes.where((t) => t.id == id).firstOrNull;

  List<(TicketTypeInfo, int)> get lines => [
        for (final MapEntry(:key, :value) in quantities.entries)
          if (value > 0 && typeById(key) != null) (typeById(key)!, value),
      ];

  double get subtotal => lines.fold(0, (sum, l) => sum + l.$1.price * l.$2);

  /// Оценка скидки на телефоне; итог всегда пересчитывает сервер.
  double get discount =>
      promo == null ? 0 : lines.fold(0, (sum, l) => sum + promo!.discountFor(l.$1.price) * l.$2);

  double get total => (subtotal - discount).clamp(0, double.infinity);

  bool get isFree => total == 0;

  /// Места, выбранные для конкретного типа.
  List<SeatInfo> seatsFor(int typeId) => seats.where((s) => s.ticketTypeId == typeId).toList();

  /// Для каждого типа выбрано ровно столько мест, сколько билетов.
  bool get seatsComplete =>
      !needsSeats || lines.every((l) => seatsFor(l.$1.id).length == l.$2);

  Cart copyWith({
    Map<int, int>? quantities,
    PromoValidation? Function()? promo,
    List<SeatInfo>? seats,
    DateTime? Function()? heldUntil,
  }) =>
      Cart(
        event: event,
        ticketTypes: ticketTypes,
        quantities: quantities ?? this.quantities,
        promo: promo == null ? this.promo : promo(),
        seats: seats ?? this.seats,
        heldUntil: heldUntil == null ? this.heldUntil : heldUntil(),
      );

  /// Изменить количество с учётом остатка и лимита на заказ.
  Cart withQuantity(TicketTypeInfo type, int qty) {
    final clamped = qty.clamp(0, type.orderLimit);
    return copyWith(quantities: {...quantities, type.id: clamped});
  }
}
