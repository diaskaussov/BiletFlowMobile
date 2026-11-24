import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../events/domain/entities/assigned_event.dart';
import '../../../events/presentation/controllers/active_event_controller.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/usecases/checkin_usecases.dart';
import '../../../../core/presentation/safe_notifier.dart';

class VerdictViewModel extends ChangeNotifier with SafeNotifier {
  VerdictViewModel({
    required this.result,
    required this._undo,
    required this._active,
  });

  final ScanResult result;
  final UndoCheckIn _undo;
  final ActiveEventController _active;

  bool _isReversed = false;

  bool get isReversed => _isReversed;
  AssignedEvent? get event => _active.event;
  ActiveEventController get active => _active;

  bool get canUndo =>
      result.verdict == Verdict.valid && result.ticketId != null && !_isReversed;

  /// B9: событие билета — среди назначенных, можно переключиться.
  AssignedEvent? get switchTarget {
    final id = result.ticket?.eventId;
    if (id == null || id == event?.id) return null;
    return _active.findAssigned(id);
  }

  /// null — отменено.
  Future<Failure?> undo(String reason) async {
    final r = await _undo(ticketId: result.ticketId, reason: reason);
    if (r case Err(:final failure)) return failure;
    _isReversed = true;
    _active.adjustCheckedIn(-1);
    notifyListeners();
    return null;
  }

  void switchToTicketEvent() {
    final target = switchTarget;
    if (target != null) _active.select(target);
  }
}
