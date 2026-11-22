import '../../../core/error/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/request_guard.dart';
import '../../../core/utils/json_reader.dart';
import '../../../shared/data/models.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../domain/cart.dart';
import '../domain/checkout_domain.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  const CheckoutRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<Result<List<SeatInfo>>> seats(int eventId) =>
      guard(() async => jsonList(await _api.get('/api/events/$eventId/seats')).map(Models.seat).toList());

  @override
  Future<Result<SeatHold>> hold(int eventId, List<int> seatIds) => guard(() async {
        final j = jsonObject(await _api.post('/api/events/$eventId/seats/hold', body: {'seatIds': seatIds}));
        return SeatHold(
          seats: jsonList(j['seats']).map(Models.seat).toList(),
          heldUntil: j.date(['heldUntil'], naiveIsUtc: true),
        );
      });

  @override
  Future<Result<void>> release(int eventId, List<int> seatIds) =>
      guard(() => _api.post('/api/events/$eventId/seats/release', body: {'seatIds': seatIds}));

  @override
  Future<Result<OrderInfo>> createOrder(Cart cart, BuyerDetails buyer) => guard(() async {
        final body = {
          'eventId': cart.event.id,
          'attendeeFirstName': buyer.firstName,
          'attendeeLastName': buyer.lastName,
          'attendeeEmail': buyer.email,
          if (cart.promo != null) 'promoCode': cart.promo!.code,
          'items': [
            for (final (type, qty) in cart.lines)
              {
                'ticketTypeId': type.id,
                'quantity': qty,
                if (cart.needsSeats) 'seatIds': [for (final s in cart.seatsFor(type.id)) s.id],
              },
          ],
        };
        return Models.order(jsonObject(await _api.post('/api/orders', body: body)));
      });

  @override
  Future<Result<OrderInfo>> pay(int orderId) =>
      guard(() async => Models.order(jsonObject(await _api.post('/api/orders/$orderId/pay'))));
}
