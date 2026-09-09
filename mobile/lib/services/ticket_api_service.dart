import 'package:mobile/core/network/api_client.dart';

class TicketApiService {
  const TicketApiService(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>?> fetchByCode(String code) async {
    final json = await _api.get('/tickets/lookup', query: {'code': code});
    return json['ticket'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>> checkIn(String ticketId) async {
    final json = await _api.post('/tickets/$ticketId/check-in');
    return json['ticket'] as Map<String, dynamic>;
  }

  Future<bool> isCampaignCode(String code) async {
    final json = await _api.get('/codes/classify', query: {'code': code});
    return json['kind'] == 'campaign';
  }
}
