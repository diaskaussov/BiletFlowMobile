import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/assigned_event.dart';
import '../../domain/entities/event_stats.dart';
import '../models/event_models.dart';

class EventsRemoteDataSource {
  const EventsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<AssignedEvent>> myEvents() async {
    final data = await _api.get('/api/staff/my-events');
    return jsonList(data)
        .map(AssignedEventModel.fromJson)
        .whereType<AssignedEvent>()
        .toSet() // одно событие могли назначить дважды
        .toList();
  }

  Future<EventStats> stats(int eventId) async {
    final data = await _api.get('/api/checkin/stats/$eventId');
    if (data is! Map) throw const FormatException('Stats is not an object');
    return EventStatsModel.fromJson(data.cast<String, dynamic>());
  }
}
