import 'dart:typed_data';

import '../../../core/error/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/request_guard.dart';
import '../../../core/utils/json_reader.dart';
import '../../../shared/data/models.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../domain/tickets_domain.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  const TicketsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<Result<List<OrderInfo>>> myOrders() =>
      guard(() async => jsonList(await _api.get('/api/orders/my')).map(Models.order).toList());

  @override
  Future<Result<List<TicketInfo>>> myTickets() =>
      guard(() async => jsonList(await _api.get('/api/tickets/my')).map(Models.ticket).toList());

  @override
  Future<Result<OrderInfo>> order(int id) =>
      guard(() async => Models.order(jsonObject(await _api.get('/api/orders/$id'))));

  @override
  Future<Result<List<TicketInfo>>> ticketsForOrder(int orderId) =>
      guard(() async => jsonList(await _api.get('/api/tickets/order/$orderId')).map(Models.ticket).toList());

  @override
  Future<Result<Uint8List>> qr(int ticketId) => guard(() => _api.getBytes('/api/tickets/$ticketId/qr'));

  @override
  Future<Result<Uint8List>> pdf(int ticketId) => guard(() => _api.getBytes('/api/tickets/$ticketId/pdf'));

  @override
  Future<Result<OrderInfo>> cancelOrder(int orderId) => guard(() async {
        await _api.post('/api/orders/$orderId/cancel');
        // Ответ отмены не описан в Swagger — берём актуальный заказ.
        return Models.order(jsonObject(await _api.get('/api/orders/$orderId')));
      });
}
