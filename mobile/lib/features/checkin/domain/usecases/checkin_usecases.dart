import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/scan_log.dart';
import '../repositories/checkin_repositories.dart';

/// C4: отмена прохода. Причина обязательна — отмена попадает в журнал
/// организатора (§4.16) и не удаляется.
class UndoCheckIn {
  UndoCheckIn({
    required this._checkin,
    required this._log,
    DateTime Function()? clock,
  })  : _clock = clock ?? DateTime.now;

  final CheckinRepository _checkin;
  final ScanLogRepository _log;
  final DateTime Function() _clock;

  Future<Result<void>> call({required String? ticketId, required String reason}) async {
    if (ticketId == null || ticketId.isEmpty) {
      return const Err(ValidationFailure(
        'The server did not return a ticket ID for this scan, so the '
        'check-in cannot be reversed from here.',
      ));
    }
    if (reason.trim().isEmpty) {
      return const Err(ValidationFailure('Give a reason for the reversal.'));
    }
    final result = await _checkin.undo(ticketId, reason: reason.trim());
    if (result is Ok) _log.markReversed(ticketId, _clock());
    return result;
  }
}

class GetScanLog {
  const GetScanLog(this._log);

  final ScanLogRepository _log;

  ScanLogSummary call(int eventId) => ScanLogSummary.of(_log.entries(eventId));
}

/// Сброс журнала смены при выходе из аккаунта.
class ClearScanLog {
  const ClearScanLog(this._log);

  final ScanLogRepository _log;

  void call() => _log.clear();
}
