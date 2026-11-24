import 'dart:typed_data';

import '../../../core/error/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/request_guard.dart';
import '../../../core/utils/json_reader.dart';
import '../../../shared/data/models.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../domain/catalog_domain.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<Result<List<EventInfo>>> publicEvents() =>
      guard(() async => jsonList(await _api.get('/api/events/public')).map(Models.event).toList());

  @override
  Future<Result<EventInfo>> event(int id) =>
      guard(() async => Models.event(jsonObject(await _api.get('/api/events/$id'))));

  @override
  Future<Result<List<TicketTypeInfo>>> ticketTypes(int eventId) => guard(() async =>
      jsonList(await _api.get('/api/events/$eventId/ticket-types')).map(Models.ticketType).toList());

  @override
  Future<Result<Uint8List>> calendarFile(int eventId) =>
      guard(() => _api.getBytes('/api/events/$eventId/calendar'));

  /// `{ valid, discountType, discountValue, eventId }`; 400 `{error}` — код
  /// не действует (истёк, исчерпан, отключён).
  @override
  Future<Result<PromoValidation>> validatePromo(String code) => guard(() async {
        final j = jsonObject(await _api.get('/api/promo/validate/${Uri.encodeComponent(code)}'));
        if (j.boolean(['valid']) == false) {
          final message = j.str(['message', 'error']);
          throw ApiException(message ?? 'This code is not valid.', statusCode: 400, code: message == null ? 'promoInvalid' : null);
        }
        return PromoValidation(
          code: j.str(['code']) ?? code,
          discountType: DiscountType.parse(j.str(['discountType'])),
          discountValue: double.tryParse(j.str(['discountValue']) ?? '') ?? 0,
          eventId: j.integer(['eventId']),
          campaignName: j.str(['campaignName', 'name']),
        );
      });
}
