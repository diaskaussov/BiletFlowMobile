import '../../../../core/error/result.dart';
import '../../../../core/network/request_guard.dart';
import '../../domain/entities/scan_log.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/checkin_repositories.dart';
import '../datasources/checkin_data_sources.dart';

class CheckinRepositoryImpl implements CheckinRepository {
  const CheckinRepositoryImpl(this._remote);

  final CheckinRemoteDataSource _remote;

  @override
  Future<Result<ScanResult>> scan({
    required String code,
    required int eventId,
    required DateTime at,
  }) =>
      guard(() async {
        final response = await _remote.scan(code, eventId);
        return ScanResult(
          verdict: response.toVerdict(),
          code: code,
          eventId: eventId,
          scannedAt: at,
          ticket: response.ticket,
          serverMessage: response.message,
        );
      });

  @override
  Future<Result<void>> undo(String ticketId) => guard(() => _remote.undo(ticketId));
}

class ScanLogRepositoryImpl implements ScanLogRepository {
  ScanLogRepositoryImpl(this._store);

  final ScanLogMemoryDataSource _store;

  @override
  void add(ScanLogEntry entry) => _store.add(entry);

  @override
  List<ScanLogEntry> entries(int eventId) =>
      _store.all.where((e) => e.eventId == eventId).toList().reversed.toList();

  @override
  void markReversed(String ticketId, DateTime at) {
    final i = _store.indexWhere(
      (e) => e.ticketId == ticketId && e.verdict == Verdict.valid && !e.isReversed,
    );
    if (i >= 0) _store.replaceAt(i, _store.all[i].reversed(at));
  }

  @override
  ScanLogEntry? lastAdmission({required int eventId, required String code}) {
    final i = _store.indexWhere((e) => e.eventId == eventId && e.code == code);
    if (i < 0) return null;
    final e = _store.all[i];
    return e.verdict == Verdict.valid && !e.isReversed ? e : null;
  }

  @override
  void clear() => _store.clear();
}
