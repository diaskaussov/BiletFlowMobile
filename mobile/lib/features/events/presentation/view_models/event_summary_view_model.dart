import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../checkin/domain/entities/scan_log.dart';
import '../../../checkin/domain/usecases/checkin_usecases.dart';
import '../../domain/entities/assigned_event.dart';
import '../../domain/entities/event_stats.dart';
import '../../domain/usecases/event_usecases.dart';
import '../controllers/active_event_controller.dart';

class EventSummaryViewModel extends ChangeNotifier {
  EventSummaryViewModel({
    required this.eventId,
    required this._getStats,
    required this._getLog,
    required this._active,
  });

  final int eventId;
  final GetEventStats _getStats;
  final GetScanLog _getLog;
  final ActiveEventController _active;

  bool _isLoading = true;
  Failure? _failure;
  EventStats? _stats;
  ScanLogSummary? _log;

  AssignedEvent? get event => _active.findAssigned(eventId);
  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  EventStats? get stats => _stats;
  ScanLogSummary get log => _log ?? ScanLogSummary.of(const []);

  Future<void> load() async {
    _failure = null;
    _log = _getLog(eventId);
    notifyListeners();

    final result = await _getStats(eventId);
    switch (result) {
      case Ok(:final value):
        _stats = value;
        _active.updateStats(eventId, value);
      case Err(:final failure):
        _failure = failure;
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectForScanning() {
    final e = event;
    if (e != null) _active.select(e);
  }
}
