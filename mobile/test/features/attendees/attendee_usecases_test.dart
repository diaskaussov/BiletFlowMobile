import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/error/result.dart';
import 'package:mobile/features/attendees/domain/entities/attendee.dart';
import 'package:mobile/features/attendees/domain/usecases/attendee_usecases.dart';

import 'attendees_mock_repository.dart';

void main() {
  late AttendeesMockRepository repo;

  setUp(() => repo = AttendeesMockRepository());

  Future<Attendee> find(String name) async {
    final r = await SearchAttendees(repo)(eventId: 1, query: name);
    return (r as Ok<List<Attendee>>).value.single;
  }

  test('search needs at least two characters', () async {
    final r = await SearchAttendees(repo)(eventId: 1, query: 's');
    expect(r.valueOrNull, isEmpty);
  });

  test('search matches name, email and ticket id', () async {
    final byName = await SearchAttendees(repo)(eventId: 1, query: 'sagyn');
    expect(byName.valueOrNull, hasLength(3));
    expect((await find('TCK-5C10')).fullName, 'Aliya Serikova');
    expect((await find('sdu.edu')).fullName, 'Ruslan Sagyndykov');
  });

  test('manual check-in admits valid tickets once', () async {
    final a = await find('Nurgul');
    final checkIn = CheckInAttendee(repo);
    final r = await checkIn(eventId: 1, attendee: a, ticketIds: [a.tickets.first.id], staffName: 'A. N.');
    final updated = r.valueOrNull!;
    expect(updated.notArrivedCount, 1);

    final again = await checkIn(eventId: 1, attendee: updated, ticketIds: [a.tickets.first.id], staffName: 'A. N.');
    expect(again.failureOrNull, isA<ValidationFailure>());
  });

  test('refunded ticket cannot be checked in manually', () async {
    final a = await find('Aliya');
    final r = await CheckInAttendee(repo)(eventId: 1, attendee: a, ticketIds: [a.tickets.first.id], staffName: 'x');
    expect(r.failureOrNull?.message, contains('refunded'));
  });

  test('reversal requires a reason and makes the ticket valid again', () async {
    final a = await find('Dias');
    final undo = UndoAttendeeCheckIn(repo);
    final t = a.tickets.first;
    expect((await undo(eventId: 1, attendeeId: a.id, ticketId: t.id, reason: ' ', staffName: 'x')).failureOrNull,
        isA<ValidationFailure>());
    final r = await undo(eventId: 1, attendeeId: a.id, ticketId: t.id, reason: 'Wrong person', staffName: 'x');
    expect(r.valueOrNull!.tickets.first.status, AttendeeTicketStatus.valid);
  });
}
