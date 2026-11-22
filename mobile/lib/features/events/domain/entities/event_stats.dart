/// `GET /api/checkin/stats/{eventId}` (§4.8: зарегистрированные и прошедшие).
class EventStats {
  const EventStats({
    required this.registered,
    required this.checkedIn,
    required this.notCheckedIn,
  });

  final int registered;
  final int checkedIn;
  final int notCheckedIn;

  double get ratio => registered == 0 ? 0 : checkedIn / registered;

  EventStats withCheckIn(int delta) => EventStats(
        registered: registered,
        checkedIn: (checkedIn + delta).clamp(0, registered),
        notCheckedIn: (notCheckedIn - delta).clamp(0, registered),
      );
}
