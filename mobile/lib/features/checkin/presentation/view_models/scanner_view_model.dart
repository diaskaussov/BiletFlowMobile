import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../connection/presentation/connection_controller.dart';
import '../../../events/domain/entities/assigned_event.dart';
import '../../../events/domain/entities/event_stats.dart';
import '../../../events/domain/usecases/event_usecases.dart';
import '../../../events/presentation/controllers/active_event_controller.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/usecases/verify_ticket.dart';

/// B1–B3: один скан за раз. Пока идёт проверка, новые коды игнорируются.
class ScannerViewModel extends ChangeNotifier {
  ScannerViewModel({
    required this._verify,
    required this._getStats,
    required this._active,
    required this._connection,
  }) {
    _active.addListener(notifyListeners);
  }

  final VerifyTicket _verify;
  final GetEventStats _getStats;
  final ActiveEventController _active;
  final ConnectionController _connection;

  bool _isChecking = false;

  AssignedEvent? get event => _active.event;
  EventStats? get stats => _active.stats;
  bool get isChecking => _isChecking;

  Future<void> refreshStats() async {
    final e = event;
    if (e == null) return;
    final r = await _getStats(e.id);
    if (r case Ok(:final value)) _active.updateStats(e.id, value);
  }

  /// null — скан проигнорирован (уже идёт проверка или нет события).
  Future<Result<ScanResult>?> handle(String rawCode) async {
    final e = event;
    if (_isChecking || e == null) return null;
    _isChecking = true;
    notifyListeners();

    final result = await _verify(rawCode: rawCode, eventId: e.id);

    _isChecking = false;
    switch (result) {
      case Ok(:final value):
        if (value.verdict == Verdict.valid) {
          _active.adjustCheckedIn(1);
          refreshStats();
        }
      case Err(failure: NetworkFailure()):
        _connection.reportServerUnreachable();
      case Err():
        break;
    }
    notifyListeners();
    return result;
  }

  @override
  void dispose() {
    _active.removeListener(notifyListeners);
    super.dispose();
  }
}
