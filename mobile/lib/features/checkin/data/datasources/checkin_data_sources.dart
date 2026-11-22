import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/scan_log.dart';
import '../models/scan_response_model.dart';

class CheckinRemoteDataSource {
  const CheckinRemoteDataSource(this._api);

  final ApiClient _api;

  Future<ScanResponseModel> scan(String code, int eventId) async {
    try {
      // eventId в контракте нет; передаём, чтобы сервер мог отличить
      // «чужое событие» (B9). Spring игнорирует неизвестные поля.
      final data = await _api.post(
        '/api/checkin/scan',
        body: {'ticketCode': code, 'eventId': eventId},
      );
      if (data is! Map) throw const FormatException('Scan response is not an object');
      return ScanResponseModel.fromJson(data.cast<String, dynamic>());
    } on ApiException catch (e) {
      // Бизнес-отказ сервер может прислать как 400/404/409 с {error}.
      if (const {400, 404, 409, 410, 422}.contains(e.statusCode)) {
        return ScanResponseModel.rejected(e.message);
      }
      rethrow;
    }
  }

  Future<void> undo(String ticketId) async {
    await _api.post('/api/checkin/undo/${Uri.encodeComponent(ticketId)}');
  }
}

/// Журнал смены в памяти процесса.
class ScanLogMemoryDataSource {
  final List<ScanLogEntry> _entries = [];

  List<ScanLogEntry> get all => List.unmodifiable(_entries);

  void add(ScanLogEntry e) => _entries.add(e);

  void replaceAt(int index, ScanLogEntry e) => _entries[index] = e;

  int indexWhere(bool Function(ScanLogEntry) test) => _entries.lastIndexWhere(test);

  void clear() => _entries.clear();
}
