import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/assigned_event.dart';
import '../../domain/entities/event_stats.dart';

abstract final class AssignedEventModel {
  /// Элемент `GET /api/staff/my-events`. Формат в API_GUIDE не описан,
  /// поэтому принимаем и само событие, и назначение `{ id, event: {...} }`,
  /// и плоское `{ eventId, eventTitle }`.
  static AssignedEvent? fromJson(Map<String, dynamic> json) {
    final e = json.obj('event') ?? json;
    final id = json.obj('event') != null
        ? e.integer(['id'])
        : json.integer(['eventId', 'id']);
    if (id == null) return null;
    return AssignedEvent(
      id: id,
      title: e.str(['title', 'name', 'eventTitle']) ??
          json.str(['eventTitle']) ??
          'Event #$id',
      venueName: e.str(['venueName', 'venue']),
      city: e.str(['city']),
      startsAt: e.date(['eventDate', 'startDate', 'startsAt']),
      endsAt: e.date(['eventEndDate', 'endDate', 'endsAt']),
      capacity: e.integer(['capacity']),
      status: e.str(['status']),
    );
  }
}

abstract final class EventStatsModel {
  /// `{ totalRegistered, checkedIn, notCheckedIn, cancelled, refunded, reversed,
  ///    byTicketType: [{name, registered, checkedIn}], recentCheckIns: [...] }`
  static EventStats fromJson(Map<String, dynamic> json) {
    final registered = json.integer(['totalRegistered', 'registered', 'total']) ?? 0;
    final checkedIn = json.integer(['checkedIn']) ?? 0;
    return EventStats(
      registered: registered,
      checkedIn: checkedIn,
      notCheckedIn: json.integer(['notCheckedIn']) ?? (registered - checkedIn),
      cancelled: json.integer(['cancelled']) ?? 0,
      refunded: json.integer(['refunded']) ?? 0,
      reversed: json.integer(['reversed']) ?? 0,
      byTicketType: [
        for (final t in jsonList(json['byTicketType']))
          TypeCheckIns(
            name: t.str(['name']) ?? '—',
            registered: t.integer(['registered']) ?? 0,
            checkedIn: t.integer(['checkedIn']) ?? 0,
          ),
      ],
      recent: [
        for (final r in jsonList(json['recentCheckIns']))
          RecentCheckIn(
            attendeeName: r.str(['attendeeName', 'name']) ?? '—',
            ticketType: r.str(['ticketType', 'ticketTypeName']),
            checkedInBy: r.str(['checkedInBy', 'scannedBy']),
            at: r.date(['checkedInAt', 'timestamp'], naiveIsUtc: true),
          ),
      ],
    );
  }
}
