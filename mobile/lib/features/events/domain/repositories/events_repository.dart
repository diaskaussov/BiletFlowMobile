import '../../../../core/error/result.dart';
import '../entities/assigned_event.dart';
import '../entities/event_stats.dart';

abstract interface class EventsRepository {
  Future<Result<List<AssignedEvent>>> getAssignedEvents();

  Future<Result<EventStats>> getStats(int eventId);
}
