/// Вход по типу билета (A8 «По типам билетов»).
class TypeCheckIns {
  const TypeCheckIns({required this.name, required this.registered, required this.checkedIn});

  final String name;
  final int registered;
  final int checkedIn;

  double get ratio => registered == 0 ? 0 : checkedIn / registered;
}

/// Недавний вход (A8 «Последние входы»).
class RecentCheckIn {
  const RecentCheckIn({required this.attendeeName, this.ticketType, this.checkedInBy, this.at});

  final String attendeeName;
  final String? ticketType;
  final String? checkedInBy;
  final DateTime? at;
}

/// `GET /api/checkin/stats/{eventId}` (§4.8: зарегистрированные и прошедшие).
class EventStats {
  const EventStats({
    required this.registered,
    required this.checkedIn,
    required this.notCheckedIn,
    this.cancelled = 0,
    this.refunded = 0,
    this.reversed = 0,
    this.byTicketType = const [],
    this.recent = const [],
  });

  final int registered;
  final int checkedIn;
  final int notCheckedIn;
  final int cancelled;
  final int refunded;
  final int reversed;
  final List<TypeCheckIns> byTicketType;
  final List<RecentCheckIn> recent;

  double get ratio => registered == 0 ? 0 : checkedIn / registered;

  EventStats withCheckIn(int delta) => EventStats(
        registered: registered,
        checkedIn: (checkedIn + delta).clamp(0, registered),
        notCheckedIn: (notCheckedIn - delta).clamp(0, registered),
        cancelled: cancelled,
        refunded: refunded,
        reversed: delta < 0 ? reversed - delta : reversed,
        byTicketType: byTicketType,
        recent: recent,
      );
}
