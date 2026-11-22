import '../../../../core/error/result.dart';
import '../../../../core/network/request_guard.dart';
import '../../domain/entities/assigned_event.dart';
import '../../domain/entities/event_stats.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_remote_data_source.dart';

class EventsRepositoryImpl implements EventsRepository {
  const EventsRepositoryImpl(this._remote);

  final EventsRemoteDataSource _remote;

  @override
  Future<Result<List<AssignedEvent>>> getAssignedEvents() => guard(_remote.myEvents);

  @override
  Future<Result<EventStats>> getStats(int eventId) => guard(() => _remote.stats(eventId));
}
