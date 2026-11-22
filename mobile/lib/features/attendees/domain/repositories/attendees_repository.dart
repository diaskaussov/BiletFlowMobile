import '../../../../core/error/result.dart';
import '../entities/attendee.dart';

/// §4.8 «Search for attendees manually». Участник = заказ с его билетами.
abstract interface class AttendeesRepository {
  Future<Result<List<Attendee>>> search({required int eventId, required String query});

  Future<Result<Attendee>> getById({required int eventId, required String attendeeId});

  Future<Result<Attendee>> checkIn({
    required int eventId,
    required String attendeeId,
    required List<String> ticketIds,
    required String staffName,
  });

  Future<Result<Attendee>> undoCheckIn({
    required int eventId,
    required String attendeeId,
    required String ticketId,
    required String reason,
    required String staffName,
  });
}
