import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/request_guard.dart';
import '../domain/entities/attendee.dart';
import '../domain/repositories/attendees_repository.dart';
import 'attendees_remote_data_source.dart';

class AttendeesRepositoryImpl implements AttendeesRepository {
  const AttendeesRepositoryImpl(this._remote);

  final AttendeesRemoteDataSource _remote;

  @override
  Future<Result<List<Attendee>>> search({required int eventId, required String query}) =>
      guard(() async => groupByOrder(await _remote.list(eventId, query: query)));

  @override
  Future<Result<Attendee>> getById({required int eventId, required String attendeeId}) =>
      guard(() => _fetch(eventId, attendeeId));

  @override
  Future<Result<Attendee>> checkIn({
    required int eventId,
    required String attendeeId,
    required List<String> ticketIds,
    required String staffName,
  }) async {
    // Отмечаем по одному билету; первый отказ сервера останавливает цикл.
    final r = await guard(() async {
      for (final id in ticketIds) {
        final response = await _remote.checkIn(id);
        if (!response.valid) return response.message ?? 'Check-in was refused.';
      }
      return null;
    });
    return switch (r) {
      Err(:final failure) => Err(failure),
      Ok(value: final String refusal) => Err(ValidationFailure(refusal)),
      Ok() => getById(eventId: eventId, attendeeId: attendeeId),
    };
  }

  @override
  Future<Result<Attendee>> undoCheckIn({
    required int eventId,
    required String attendeeId,
    required String ticketId,
    required String reason,
    required String staffName,
  }) =>
      guard(() async {
        await _remote.undo(ticketId, reason);
        return _fetch(eventId, attendeeId);
      });

  /// Отдельного эндпоинта «участник по ID» нет — берём список события
  /// и находим заказ.
  Future<Attendee> _fetch(int eventId, String attendeeId) async {
    final all = groupByOrder(await _remote.list(eventId));
    final found = all.where((a) => a.id == attendeeId).firstOrNull;
    if (found == null) throw const ApiException('Attendee not found.', statusCode: 404);
    return found;
  }
}
