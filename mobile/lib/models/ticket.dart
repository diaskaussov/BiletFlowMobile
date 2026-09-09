enum TicketStatus { active, used, refunded, cancelled }

class Ticket {
  const Ticket({
    required this.id,
    required this.eventId,
    required this.holderName,
    required this.type,
    required this.status,
    this.seat,
    this.usedAt,
  });

  final String id;          // TCK-8F42-19KD
  final String eventId;
  final String holderName;
  final String type;        // «VIP Balcony»
  final TicketStatus status;
  final String? seat;       // «Sec B · Row 12 · Seat 7»
  final DateTime? usedAt;

  bool get isSpent =>
      status == TicketStatus.refunded || status == TicketStatus.cancelled;
}