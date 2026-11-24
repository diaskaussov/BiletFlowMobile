import '../../l10n/app_localizations.dart';
import '../../shared/domain/entities/commerce.dart';
import '../../shared/domain/entities/event_info.dart';
import '../../shared/domain/entities/insights.dart';
import '../../shared/domain/entities/support.dart';
import '../theme/app_palette.dart';

/// Подписи и тона статусов домена. Домен хранит только значения,
/// слова на нужном языке подбираются здесь.
extension EventStatusText on EventStatus {
  String text(AppLocalizations l) => switch (this) {
        EventStatus.draft => l.evDraft,
        EventStatus.published => l.evPublished,
        EventStatus.cancelled => l.evCancelled,
        EventStatus.completed => l.evCompleted,
      };

  Tone get tone => switch (this) {
        EventStatus.draft => Tone.neutral,
        EventStatus.published => Tone.success,
        EventStatus.cancelled => Tone.danger,
        EventStatus.completed => Tone.info,
      };
}

extension EventVisibilityText on EventVisibility {
  String text(AppLocalizations l) => switch (this) {
        EventVisibility.public => l.visPublic,
        EventVisibility.unlisted => l.visUnlisted,
        EventVisibility.private => l.visPrivate,
      };
}

extension OrderStatusText on OrderStatus {
  String text(AppLocalizations l) => switch (this) {
        OrderStatus.pending => l.orderPending,
        OrderStatus.completed => l.orderPaid,
        OrderStatus.cancelled => l.orderCancelled,
        OrderStatus.refunded => l.orderRefunded,
      };

  Tone get tone => switch (this) {
        OrderStatus.pending => Tone.warning,
        OrderStatus.completed => Tone.success,
        OrderStatus.cancelled => Tone.danger,
        OrderStatus.refunded => Tone.primary,
      };
}

extension TicketStatusText on TicketStatus {
  String text(AppLocalizations l) => switch (this) {
        TicketStatus.valid => l.statusValid,
        TicketStatus.checkedIn => l.statusUsed,
        TicketStatus.cancelled => l.statusCancelled,
        TicketStatus.refunded => l.statusRefunded,
      };

  Tone get tone => switch (this) {
        TicketStatus.valid => Tone.success,
        TicketStatus.checkedIn => Tone.info,
        TicketStatus.cancelled => Tone.danger,
        TicketStatus.refunded => Tone.warning,
      };
}

extension CaseStatusText on CaseStatus {
  String text(AppLocalizations l) => switch (this) {
        CaseStatus.open => l.caseOpen,
        CaseStatus.inProgress => l.caseInProgress,
        CaseStatus.waitingForCustomer => l.caseWaiting,
        CaseStatus.resolved => l.caseResolved,
      };

  Tone get tone => switch (this) {
        CaseStatus.open => Tone.warning,
        CaseStatus.inProgress => Tone.info,
        CaseStatus.waitingForCustomer => Tone.primary,
        CaseStatus.resolved => Tone.success,
      };
}

extension CaseCategoryText on CaseCategory {
  String text(AppLocalizations l) => switch (this) {
        CaseCategory.ticketDelivery => l.catTicketDelivery,
        CaseCategory.payment => l.catPayment,
        CaseCategory.refund => l.catRefund,
        CaseCategory.seating => l.catSeating,
        CaseCategory.eventInfo => l.catEventInfo,
        CaseCategory.checkIn => l.catCheckIn,
        CaseCategory.account => l.catAccount,
        CaseCategory.activation => l.catActivation,
        CaseCategory.technical => l.catTechnical,
      };
}

extension AuditKindText on AuditKind {
  String text(AppLocalizations l) => switch (this) {
        AuditKind.eventChanges => l.auditEventChanges,
        AuditKind.refunds => l.auditRefunds,
        AuditKind.campaigns => l.auditCampaigns,
        AuditKind.checkIns => l.auditCheckIns,
        AuditKind.support => l.auditSupport,
      };
}

extension SeatText on SeatInfo {
  String text(AppLocalizations l) => l.seatLabel(section, row, number);
}
