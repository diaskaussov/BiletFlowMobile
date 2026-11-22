/// Событие, на которое организатор назначил администратора (UC4).
class AssignedEvent {
  const AssignedEvent({
    required this.id,
    required this.title,
    this.venueName,
    this.city,
    this.startsAt,
    this.endsAt,
    this.capacity,
    this.status,
  });

  final int id;
  final String title;
  final String? venueName;
  final String? city;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? capacity;
  final String? status;

  bool get isCancelled => status?.toUpperCase() == 'CANCELLED';

  String get venueLine =>
      [venueName, city].whereType<String>().where((s) => s.isNotEmpty).join(', ');

  bool isToday(DateTime now) {
    final s = startsAt;
    if (s == null) return false;
    final sameDay = s.year == now.year && s.month == now.month && s.day == now.day;
    final running = endsAt != null && s.isBefore(now) && endsAt!.isAfter(now);
    return sameDay || running;
  }

  @override
  bool operator ==(Object other) => other is AssignedEvent && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// События, разложенные для A3: сегодня, впереди, прошедшие.
class EventSchedule {
  const EventSchedule({required this.today, required this.upcoming, required this.past});

  factory EventSchedule.group(List<AssignedEvent> events, DateTime now) {
    final today = <AssignedEvent>[];
    final upcoming = <AssignedEvent>[];
    final past = <AssignedEvent>[];
    for (final e in events) {
      if (e.isToday(now)) {
        today.add(e);
      } else if (e.startsAt == null || e.startsAt!.isAfter(now)) {
        upcoming.add(e);
      } else {
        past.add(e);
      }
    }
    int byDate(AssignedEvent a, AssignedEvent b) =>
        (a.startsAt ?? DateTime(9999)).compareTo(b.startsAt ?? DateTime(9999));
    today.sort(byDate);
    upcoming.sort(byDate);
    past.sort((a, b) => byDate(b, a));
    return EventSchedule(today: today, upcoming: upcoming, past: past);
  }

  final List<AssignedEvent> today;
  final List<AssignedEvent> upcoming;
  final List<AssignedEvent> past;

  bool get isEmpty => today.isEmpty && upcoming.isEmpty && past.isEmpty;

  /// Событие для карточки сверху: сегодняшнее, иначе ближайшее.
  AssignedEvent? get featured =>
      today.firstOrNull ?? upcoming.firstOrNull ?? past.firstOrNull;
}
