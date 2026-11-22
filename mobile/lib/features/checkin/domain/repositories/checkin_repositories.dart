import '../../../../core/error/result.dart';
import '../entities/scan_log.dart';
import '../entities/scan_result.dart';

abstract interface class CheckinRepository {
  /// Проверяет код билета на сервере и, если билет действителен,
  /// записывает вход (UC4). Отказ — это тоже [Ok] с вердиктом отказа;
  /// [Err] — только когда ответа нет или он непонятен.
  Future<Result<ScanResult>> scan({
    required String code,
    required int eventId,
    required DateTime at,
  });

  /// Отменяет вход — билет снова действителен (§4.8, C4).
  /// Причина уходит на сервер и попадает в журнал организатора.
  Future<Result<void>> undo(String ticketId, {required String reason});
}

abstract interface class ScanLogRepository {
  void add(ScanLogEntry entry);

  /// Новые сверху.
  List<ScanLogEntry> entries(int eventId);

  void markReversed(String ticketId, DateTime at);

  /// Последний засчитанный (и не отменённый) вход по этому коду.
  ScanLogEntry? lastAdmission({required int eventId, required String code});

  void clear();
}
