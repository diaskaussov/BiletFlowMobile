import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/error/result.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/features/checkin/data/datasources/checkin_data_sources.dart';
import 'package:mobile/features/checkin/data/repositories/checkin_repositories_impl.dart';
import 'package:mobile/features/checkin/domain/entities/scan_result.dart';
import 'package:mobile/features/checkin/domain/repositories/checkin_repositories.dart';

class FakeNetwork implements NetworkInfo {
  bool online = true;

  @override
  Future<bool> get isOnline async => online;

  @override
  Stream<bool> get onStatusChange => const Stream.empty();
}

/// Сервер-заглушка: отвечает вердиктом по коду из [verdicts].
class FakeCheckinRepository implements CheckinRepository {
  final Map<String, Verdict> verdicts = {};
  final List<String> scanned = [];
  final List<String> undone = [];
  Failure? failNext;

  @override
  Future<Result<ScanResult>> scan({
    required String code,
    required int eventId,
    required DateTime at,
  }) async {
    scanned.add(code);
    if (failNext case final f?) {
      failNext = null;
      return Err(f);
    }
    return Ok(ScanResult(
      verdict: verdicts[code] ?? Verdict.unknownCode,
      code: code,
      eventId: eventId,
      scannedAt: at,
      ticket: ScannedTicket(ticketId: 'T-$code', attendeeName: 'Dias Sagynbek', ticketType: 'VIP'),
    ));
  }

  @override
  Future<Result<void>> undo(String ticketId) async {
    undone.add(ticketId);
    return const Ok(null);
  }
}

ScanLogRepository memoryLog() => ScanLogRepositoryImpl(ScanLogMemoryDataSource());

/// Управляемые часы.
class Clock {
  DateTime now = DateTime(2026, 11, 22, 19, 43, 2);

  DateTime call() => now;

  void advance(Duration d) => now = now.add(d);
}
