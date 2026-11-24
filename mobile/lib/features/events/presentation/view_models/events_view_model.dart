import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../connection/presentation/connection_controller.dart';
import '../../domain/entities/assigned_event.dart';
import '../../domain/entities/event_stats.dart';
import '../../domain/usecases/event_usecases.dart';
import '../controllers/active_event_controller.dart';
import '../../../../core/presentation/safe_notifier.dart';

class EventsViewModel extends ChangeNotifier with SafeNotifier {
  EventsViewModel({
    required this._getEvents,
    required this._getStats,
    required this._active,
    required this._connection,
  });

  final GetAssignedEvents _getEvents;
  final GetEventStats _getStats;
  final ActiveEventController _active;
  final ConnectionController _connection;

  bool _isLoading = true;
  Failure? _failure;
  EventSchedule? _schedule;
  final Map<int, EventStats> _stats = {};

  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  EventSchedule? get schedule => _schedule;
  EventStats? statsFor(int eventId) => _stats[eventId];

  Future<void> load() async {
    _isLoading = _schedule == null;
    _failure = null;
    notifyListeners();

    final result = await _getEvents();
    switch (result) {
      case Ok(:final value):
        _schedule = value;
        _active.setAssigned([...value.today, ...value.upcoming, ...value.past]);
        final featured = value.featured;
        if (_active.event == null && featured != null) _active.select(featured);
        if (featured != null) await _loadStats(featured.id);
      case Err(:final failure):
        _failure = failure;
        if (failure is NetworkFailure) _connection.reportServerUnreachable();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadStats(int eventId) async {
    final r = await _getStats(eventId);
    if (r case Ok(:final value)) {
      _stats[eventId] = value;
      _active.updateStats(eventId, value);
    }
  }

  void open(AssignedEvent event) => _active.select(event);
}
