import 'package:flutter/foundation.dart';

import '../../domain/entities/assigned_event.dart';
import '../../domain/entities/event_stats.dart';

/// Какое событие сейчас сканируем и его счётчики. Общий для сканера,
/// экранов результата, поиска и сводки.
class ActiveEventController extends ChangeNotifier {
  List<AssignedEvent> _assigned = const [];
  AssignedEvent? _event;
  EventStats? _stats;

  List<AssignedEvent> get assigned => _assigned;
  AssignedEvent? get event => _event;
  EventStats? get stats => _stats;

  void setAssigned(List<AssignedEvent> events) {
    _assigned = events;
    if (_event != null && !events.contains(_event)) {
      _event = null;
      _stats = null;
    }
    notifyListeners();
  }

  void select(AssignedEvent event) {
    if (_event == event) return;
    _event = event;
    _stats = null;
    notifyListeners();
  }

  AssignedEvent? findAssigned(int? id) =>
      id == null ? null : _assigned.where((e) => e.id == id).firstOrNull;

  void updateStats(int eventId, EventStats stats) {
    if (_event?.id != eventId) return;
    _stats = stats;
    notifyListeners();
  }

  /// Локально сдвигает счётчик после проходки или отмены, не дожидаясь
  /// повторного запроса статистики.
  void adjustCheckedIn(int delta) {
    final s = _stats;
    if (s == null) return;
    _stats = s.withCheckIn(delta);
    notifyListeners();
  }

  void clear() {
    _assigned = const [];
    _event = null;
    _stats = null;
    notifyListeners();
  }
}
