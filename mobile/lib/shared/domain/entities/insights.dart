/// `GET /api/analytics/events/{id}` (O7, §4.15).
class EventAnalytics {
  const EventAnalytics({
    this.totalCapacity = 0,
    this.ticketsSold = 0,
    this.ticketsRemaining = 0,
    this.percentageSold = 0,
    this.grossRevenue = 0,
    this.totalDiscounts = 0,
    this.totalRefunds = 0,
    this.netRevenue = 0,
    this.totalOrders = 0,
    this.totalAttendees = 0,
    this.checkedIn = 0,
    this.checkInPercentage = 0,
    this.byTicketType = const [],
    this.campaigns = const [],
  });

  final int totalCapacity;
  final int ticketsSold;
  final int ticketsRemaining;
  final double percentageSold;
  final double grossRevenue;
  final double totalDiscounts;
  final double totalRefunds;
  final double netRevenue;
  final int totalOrders;
  final int totalAttendees;
  final int checkedIn;
  final double checkInPercentage;
  final List<TicketTypeSales> byTicketType;
  final List<CampaignStats> campaigns;

  int get absent => (totalAttendees - checkedIn).clamp(0, totalAttendees);
}

class TicketTypeSales {
  const TicketTypeSales({
    required this.name,
    this.quantity = 0,
    this.sold = 0,
    this.revenue = 0,
  });

  final String name;
  final int quantity;
  final int sold;
  final double revenue;
}

class CampaignStats {
  const CampaignStats({required this.name, this.redemptions = 0, this.maxRedemptions});

  final String name;
  final int redemptions;
  final int? maxRedemptions;
}

/// Запись журнала события (O9, §4.16).
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.actionType,
    required this.description,
    this.entityType,
    this.entityId,
    this.userId,
    this.at,
  });

  final int id;
  final String actionType;
  final String description;
  final String? entityType;
  final int? entityId;
  final int? userId;
  final DateTime? at;

  /// Группа для фильтра O9.
  AuditKind get kind {
    final a = actionType.toUpperCase();
    if (a.contains('CHECK')) return AuditKind.checkIns;
    if (a.contains('REFUND')) return AuditKind.refunds;
    if (a.contains('PROMO') || a.contains('CAMPAIGN')) return AuditKind.campaigns;
    if (a.contains('SUPPORT') || a.contains('CASE')) return AuditKind.support;
    return AuditKind.eventChanges;
  }
}

enum AuditKind {
  eventChanges('Event changes'),
  refunds('Refunds'),
  campaigns('Campaigns'),
  checkIns('Check-ins'),
  support('Support');

  const AuditKind(this.label);

  final String label;
}

/// Чек-лист активации платных продаж (O4, §3.2).
class ActivationChecklist {
  const ActivationChecklist({
    this.hasPaidTicketType = false,
    this.identityVerified = false,
    this.payoutVerified = false,
    this.activationFeePaid = false,
    this.allRequirementsMet = false,
    this.alreadyActivated = false,
  });

  final bool hasPaidTicketType;
  final bool identityVerified;
  final bool payoutVerified;
  final bool activationFeePaid;
  final bool allRequirementsMet;
  final bool alreadyActivated;
}
