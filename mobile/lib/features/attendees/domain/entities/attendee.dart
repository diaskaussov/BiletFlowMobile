enum AttendeeTicketStatus { valid, checkedIn, refunded, cancelled }

class AttendeeTicket {
  const AttendeeTicket({
    required this.id,
    required this.type,
    required this.status,
    this.seat,
    this.checkedInAt,
    this.checkedInBy,
  });

  final String id;
  final String type;
  final AttendeeTicketStatus status;
  final String? seat;
  final DateTime? checkedInAt;
  final String? checkedInBy;

  bool get canCheckIn => status == AttendeeTicketStatus.valid;

  AttendeeTicket copyWith({
    AttendeeTicketStatus? status,
    DateTime? checkedInAt,
    String? checkedInBy,
    bool clearCheckIn = false,
  }) =>
      AttendeeTicket(
        id: id,
        type: type,
        seat: seat,
        status: status ?? this.status,
        checkedInAt: clearCheckIn ? null : (checkedInAt ?? this.checkedInAt),
        checkedInBy: clearCheckIn ? null : (checkedInBy ?? this.checkedInBy),
      );
}

class AttendeeHistoryEntry {
  const AttendeeHistoryEntry({required this.at, required this.text});

  final DateTime at;
  final String text;
}

/// Владелец заказа на событии с билетами этого заказа (C1, C3).
class Attendee {
  const Attendee({
    required this.id,
    required this.fullName,
    required this.tickets,
    this.email,
    this.orderNumber,
    this.history = const [],
  });

  final String id;
  final String fullName;
  final String? email;
  final String? orderNumber;
  final List<AttendeeTicket> tickets;
  final List<AttendeeHistoryEntry> history;

  int get notArrivedCount => tickets.where((t) => t.canCheckIn).length;

  bool get hasArrived => tickets.any((t) => t.status == AttendeeTicketStatus.checkedIn);

  /// Последний вход — для метки «IN 19:43».
  DateTime? get lastCheckInAt => tickets
      .map((t) => t.checkedInAt)
      .whereType<DateTime>()
      .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

  Attendee copyWith({List<AttendeeTicket>? tickets, List<AttendeeHistoryEntry>? history}) =>
      Attendee(
        id: id,
        fullName: fullName,
        email: email,
        orderNumber: orderNumber,
        tickets: tickets ?? this.tickets,
        history: history ?? this.history,
      );
}
