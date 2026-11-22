import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/events/data/models/event_models.dart';
import 'package:mobile/features/events/domain/entities/assigned_event.dart';

void main() {
  final now = DateTime(2026, 11, 22, 17);

  AssignedEvent event(int id, DateTime? at) => AssignedEvent(id: id, title: 'E$id', startsAt: at);

  group('EventSchedule', () {
    test('splits today, upcoming and past', () {
      final s = EventSchedule.group([
        event(1, DateTime(2026, 11, 22, 19)),
        event(2, DateTime(2026, 12, 1, 18)),
        event(3, DateTime(2026, 11, 25, 20)),
        event(4, DateTime(2026, 10, 1, 18)),
      ], now);
      expect(s.today.map((e) => e.id), [1]);
      expect(s.upcoming.map((e) => e.id), [3, 2]);
      expect(s.past.map((e) => e.id), [4]);
      expect(s.featured?.id, 1);
    });

    test('featured falls back to the nearest upcoming', () {
      final s = EventSchedule.group([event(2, DateTime(2026, 12, 1)), event(3, DateTime(2026, 11, 30))], now);
      expect(s.featured?.id, 3);
    });

    test('event running across midnight counts as today', () {
      final e = AssignedEvent(
        id: 9, title: 'Night', startsAt: DateTime(2026, 11, 21, 22), endsAt: DateTime(2026, 11, 23, 2),
      );
      expect(e.isToday(now), isTrue);
    });
  });

  group('AssignedEventModel', () {
    test('plain event object', () {
      final e = AssignedEventModel.fromJson({
        'id': 1, 'title': 'Free concert', 'venueName': 'Almaty Arena', 'city': 'Almaty',
        'eventDate': '2026-12-01T18:00:00', 'capacity': 1000, 'status': 'PUBLISHED',
      })!;
      expect(e.id, 1);
      expect(e.venueLine, 'Almaty Arena, Almaty');
      expect(e.startsAt, DateTime(2026, 12, 1, 18));
    });

    test('assignment wrapping an event uses the event id, not the assignment id', () {
      final e = AssignedEventModel.fromJson({
        'id': 77, 'event': {'id': 2, 'title': 'Tech conference'},
      })!;
      expect(e.id, 2);
      expect(e.title, 'Tech conference');
    });

    test('flat assignment', () {
      final e = AssignedEventModel.fromJson({'id': 77, 'eventId': 2, 'eventTitle': 'Tech'})!;
      expect(e.id, 2);
      expect(e.title, 'Tech');
    });

    test('stats', () {
      final s = EventStatsModel.fromJson({'totalRegistered': 150, 'checkedIn': 87, 'notCheckedIn': 63});
      expect(s.registered, 150);
      expect(s.checkedIn, 87);
      expect(s.notCheckedIn, 63);
      expect(s.withCheckIn(1).checkedIn, 88);
      expect(s.withCheckIn(1).notCheckedIn, 62);
    });
  });
}
