enum CaseStatus {
  open,
  inProgress,
  waitingForCustomer,
  resolved;

  static CaseStatus parse(String? raw) => switch (raw?.toUpperCase()) {
        'IN_PROGRESS' => CaseStatus.inProgress,
        'WAITING_FOR_CUSTOMER' => CaseStatus.waitingForCustomer,
        'RESOLVED' => CaseStatus.resolved,
        _ => CaseStatus.open,
      };

  String get wire => switch (this) {
        CaseStatus.open => 'OPEN',
        CaseStatus.inProgress => 'IN_PROGRESS',
        CaseStatus.waitingForCustomer => 'WAITING_FOR_CUSTOMER',
        CaseStatus.resolved => 'RESOLVED',
      };

  String get label => switch (this) {
        CaseStatus.open => 'Open',
        CaseStatus.inProgress => 'In progress',
        CaseStatus.waitingForCustomer => 'Waiting for customer',
        CaseStatus.resolved => 'Resolved',
      };
}

/// Категории обращения из §4.13.
enum CaseCategory {
  ticketDelivery('ticket_delivery', 'Ticket delivery'),
  payment('payment', 'Payment'),
  refund('refund', 'Refund'),
  seating('seating', 'Seating'),
  eventInfo('event_information', 'Event information'),
  checkIn('check_in', 'Check-in'),
  account('account', 'Account'),
  activation('activation', 'Paid sales activation'),
  technical('technical', 'Technical problem');

  const CaseCategory(this.wire, this.label);

  final String wire;
  final String label;

  static CaseCategory parse(String? raw) =>
      values.where((c) => c.wire == raw?.toLowerCase()).firstOrNull ?? CaseCategory.technical;
}

class SupportMessageInfo {
  const SupportMessageInfo({
    required this.id,
    required this.text,
    required this.senderName,
    this.senderId,
    this.senderRole,
    this.createdAt,
  });

  final int id;
  final String text;
  final String senderName;
  final int? senderId;
  final String? senderRole;
  final DateTime? createdAt;
}

/// Обращение в поддержку с контекстом (W9, §4.13).
class SupportCaseInfo {
  const SupportCaseInfo({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    this.requesterName,
    this.requesterId,
    this.eventId,
    this.eventTitle,
    this.orderId,
    this.assignedTo,
    this.messages = const [],
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String subject;
  final CaseCategory category;
  final CaseStatus status;
  final String? requesterName;
  final int? requesterId;
  final int? eventId;
  final String? eventTitle;
  final int? orderId;
  final String? assignedTo;
  final List<SupportMessageInfo> messages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get number => 'CS-${id.toString().padLeft(4, '0')}';
}

class NotificationInfo {
  const NotificationInfo({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    this.read = false,
    this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final String? type;
  final bool read;
  final DateTime? createdAt;
}
