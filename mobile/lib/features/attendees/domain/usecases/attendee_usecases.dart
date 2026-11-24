import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/attendee.dart';
import '../repositories/attendees_repository.dart';

/// C1: поиск по имени, email или ID билета в пределах события.
class SearchAttendees {
  const SearchAttendees(this._repo);

  final AttendeesRepository _repo;

  static const minQueryLength = 2;

  Future<Result<List<Attendee>>> call({required int eventId, required String query}) async {
    final q = query.trim();
    if (q.length < minQueryLength) return const Ok([]);
    return _repo.search(eventId: eventId, query: q);
  }
}

class GetAttendee {
  const GetAttendee(this._repo);

  final AttendeesRepository _repo;

  Future<Result<Attendee>> call({required int eventId, required String attendeeId}) =>
      _repo.getById(eventId: eventId, attendeeId: attendeeId);
}

/// C3: ручная отметка входа. Записывается так же, как скан, — одного
/// человека нельзя впустить дважды.
class CheckInAttendee {
  const CheckInAttendee(this._repo);

  final AttendeesRepository _repo;

  Future<Result<Attendee>> call({
    required int eventId,
    required Attendee attendee,
    required List<String> ticketIds,
    required String staffName,
  }) async {
    if (ticketIds.isEmpty) {
      return const Err(ValidationFailure('Choose at least one ticket.', code: 'pickTicket'));
    }
    for (final id in ticketIds) {
      final ticket = attendee.tickets.where((t) => t.id == id).firstOrNull;
      if (ticket == null) return const Err(ValidationFailure('Ticket is not in this order.', code: 'ticketNotInOrder'));
      final args = {'label': ticket.label};
      final problem = switch (ticket.status) {
        AttendeeTicketStatus.valid => null,
        AttendeeTicketStatus.checkedIn =>
          ValidationFailure('Ticket ${ticket.label} is already checked in.', code: 'ticketAlreadyIn', args: args),
        AttendeeTicketStatus.refunded => ValidationFailure(
            'Ticket ${ticket.label} was refunded and cannot admit anyone.', code: 'ticketRefundedNoEntry', args: args),
        AttendeeTicketStatus.cancelled => ValidationFailure(
            'Ticket ${ticket.label} was cancelled and cannot admit anyone.', code: 'ticketCancelledNoEntry', args: args),
      };
      if (problem != null) return Err(problem);
    }
    return _repo.checkIn(
      eventId: eventId,
      attendeeId: attendee.id,
      ticketIds: ticketIds,
      staffName: staffName,
    );
  }
}

class UndoAttendeeCheckIn {
  const UndoAttendeeCheckIn(this._repo);

  final AttendeesRepository _repo;

  Future<Result<Attendee>> call({
    required int eventId,
    required String attendeeId,
    required String ticketId,
    required String reason,
    required String staffName,
  }) async {
    if (reason.trim().isEmpty) {
      return const Err(ValidationFailure('Give a reason for the reversal.', code: 'reversalReason'));
    }
    return _repo.undoCheckIn(
      eventId: eventId,
      attendeeId: attendeeId,
      ticketId: ticketId,
      reason: reason.trim(),
      staffName: staffName,
    );
  }
}
