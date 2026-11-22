import '../../../../core/error/result.dart';
import '../entities/assigned_event.dart';
import '../entities/event_stats.dart';
import '../repositories/events_repository.dart';

/// A2/A3: только назначенные события; отменённые не показываем —
/// на них нечего сканировать.
class GetAssignedEvents {
  const GetAssignedEvents(this._repo);

  final EventsRepository _repo;

  Future<Result<EventSchedule>> call({DateTime? now}) async {
    final result = await _repo.getAssignedEvents();
    return switch (result) {
      Ok(:final value) => Ok(EventSchedule.group(
          value.where((e) => !e.isCancelled).toList(),
          now ?? DateTime.now(),
        )),
      Err(:final failure) => Err(failure),
    };
  }
}

class GetEventStats {
  const GetEventStats(this._repo);

  final EventsRepository _repo;

  Future<Result<EventStats>> call(int eventId) => _repo.getStats(eventId);
}
