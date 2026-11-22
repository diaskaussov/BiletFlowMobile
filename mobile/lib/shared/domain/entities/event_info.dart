enum EventStatus {
  draft,
  published,
  cancelled,
  completed;

  static EventStatus parse(String? raw) => switch (raw?.toUpperCase()) {
        'PUBLISHED' => EventStatus.published,
        'CANCELLED' => EventStatus.cancelled,
        'COMPLETED' => EventStatus.completed,
        _ => EventStatus.draft,
      };

  String get label => switch (this) {
        EventStatus.draft => 'Draft',
        EventStatus.published => 'Published',
        EventStatus.cancelled => 'Cancelled',
        EventStatus.completed => 'Completed',
      };
}

enum EventVisibility {
  public,
  unlisted,
  private;

  static EventVisibility parse(String? raw) => switch (raw?.toUpperCase()) {
        'UNLISTED' => EventVisibility.unlisted,
        'PRIVATE' => EventVisibility.private,
        _ => EventVisibility.public,
      };

  String get wire => name.toUpperCase();

  String get label => switch (this) {
        EventVisibility.public => 'Public',
        EventVisibility.unlisted => 'Unlisted',
        EventVisibility.private => 'Private',
      };
}

/// Событие целиком — для афиши (W1–W2), организатора (O1–O2) и админа (P2).
class EventInfo {
  const EventInfo({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.imageUrl,
    this.venueName,
    this.venueAddress,
    this.city,
    this.startsAt,
    this.endsAt,
    this.registrationOpensAt,
    this.registrationClosesAt,
    this.capacity,
    this.status = EventStatus.draft,
    this.visibility = EventVisibility.public,
    this.paidSalesActivated = false,
    this.assignedSeating = false,
    this.organizerId,
    this.organizerName,
  });

  final int id;
  final String title;
  final String? description;
  final String? category;
  final String? imageUrl;
  final String? venueName;
  final String? venueAddress;
  final String? city;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? registrationOpensAt;
  final DateTime? registrationClosesAt;
  final int? capacity;
  final EventStatus status;
  final EventVisibility visibility;
  final bool paidSalesActivated;
  final bool assignedSeating;
  final int? organizerId;
  final String? organizerName;

  String get venueLine =>
      [venueName, city].whereType<String>().where((s) => s.isNotEmpty).join(', ');

  String get fullAddress =>
      [venueName, venueAddress, city].whereType<String>().where((s) => s.isNotEmpty).join(' · ');

  bool isUpcoming(DateTime now) => startsAt == null || startsAt!.isAfter(now);

  /// «Активно» — идёт прямо сейчас (O1 «ACTIVE NOW»).
  bool isRunning(DateTime now) =>
      startsAt != null &&
      startsAt!.isBefore(now) &&
      (endsAt ?? startsAt!.add(const Duration(hours: 6))).isAfter(now);

  bool isRegistrationOpen(DateTime now) {
    if (registrationOpensAt != null && now.isBefore(registrationOpensAt!)) return false;
    if (registrationClosesAt != null && now.isAfter(registrationClosesAt!)) return false;
    return status == EventStatus.published;
  }
}
