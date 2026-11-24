import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../shared/domain/entities/commerce.dart';
import 'cart.dart';

class SeatHold {
  const SeatHold({required this.seats, this.heldUntil});

  final List<SeatInfo> seats;
  final DateTime? heldUntil;
}

class BuyerDetails {
  const BuyerDetails({required this.firstName, required this.lastName, required this.email});

  final String firstName;
  final String lastName;
  final String email;
}

abstract interface class CheckoutRepository {
  Future<Result<List<SeatInfo>>> seats(int eventId);

  Future<Result<SeatHold>> hold(int eventId, List<int> seatIds);

  Future<Result<void>> release(int eventId, List<int> seatIds);

  /// `POST /api/orders`. Бесплатный заказ сервер сразу завершает и выпускает
  /// билеты; платный остаётся PENDING до `pay`.
  Future<Result<OrderInfo>> createOrder(Cart cart, BuyerDetails buyer);

  /// Оплата в песочнице (§4.6) — деньги не двигаются.
  Future<Result<OrderInfo>> pay(int orderId);
}

/// W4: удержать выбранные места. Для каждого типа — ровно столько мест,
/// сколько билетов в корзине (§4.3.1).
class HoldSeats {
  const HoldSeats(this._repo);

  final CheckoutRepository _repo;

  Future<Result<Cart>> call(Cart cart, List<SeatInfo> selected) async {
    for (final (type, qty) in cart.lines) {
      final picked = selected.where((s) => s.ticketTypeId == type.id).length;
      if (picked != qty) {
        return Err(ValidationFailure(
          'Choose $qty ${qty == 1 ? 'seat' : 'seats'} for ${type.name}.',
          code: 'seatsForType',
          args: {'count': qty, 'type': type.name},
        ));
      }
    }
    final r = await _repo.hold(cart.event.id, [for (final s in selected) s.id]);
    return switch (r) {
      Ok(:final value) => Ok(cart.copyWith(
          seats: value.seats.isEmpty ? selected : value.seats,
          heldUntil: () => value.heldUntil,
        )),
      Err(:final failure) => Err(failure),
    };
  }
}

class ReleaseSeats {
  const ReleaseSeats(this._repo);

  final CheckoutRepository _repo;

  Future<Result<void>> call(Cart cart) async {
    if (cart.seats.isEmpty) return const Ok(null);
    return _repo.release(cart.event.id, [for (final s in cart.seats) s.id]);
  }
}

/// W5: создать заказ и, если он платный, оплатить в песочнице.
/// Билеты выдаются только после подтверждения оплаты (§4.6).
class PlaceOrder {
  PlaceOrder(this._repo, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final CheckoutRepository _repo;
  final DateTime Function() _clock;

  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  Future<Result<OrderInfo>> call(Cart cart, BuyerDetails buyer) async {
    if (cart.isEmpty) return const Err(ValidationFailure('Choose at least one ticket.', code: 'pickTicket'));
    if (buyer.firstName.trim().isEmpty || buyer.lastName.trim().isEmpty) {
      return const Err(ValidationFailure('Enter the attendee\'s first and last name.', code: 'buyerName'));
    }
    if (!_email.hasMatch(buyer.email.trim())) {
      return const Err(ValidationFailure('Enter the email tickets should be sent to.', code: 'buyerEmail'));
    }
    if (!cart.seatsComplete) return const Err(ValidationFailure('Choose seats first.', code: 'seatsFirst'));
    final held = cart.heldUntil;
    if (held != null && _clock().isAfter(held)) {
      return const Err(ValidationFailure('Your seat hold expired. Choose seats again.', code: 'holdExpired'));
    }

    final created = await _repo.createOrder(
      cart,
      BuyerDetails(
        firstName: buyer.firstName.trim(),
        lastName: buyer.lastName.trim(),
        email: buyer.email.trim().toLowerCase(),
      ),
    );
    if (created case Err(:final failure)) return Err(failure);
    final order = created.valueOrNull!;
    if (order.status != OrderStatus.pending) return Ok(order);
    return _repo.pay(order.id);
  }
}

class LoadSeatMap {
  const LoadSeatMap(this._repo);

  final CheckoutRepository _repo;

  Future<Result<List<SeatInfo>>> call(int eventId) => _repo.seats(eventId);
}
