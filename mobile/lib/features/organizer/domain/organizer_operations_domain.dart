import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/insights.dart';
import '../../../shared/domain/entities/people.dart';

// ─── entities ──────────────────────────────────────────────────────────────

/// Живая статистика входа `/api/checkin/stats/{id}` в полном виде.
class CheckInOverview {
  const CheckInOverview({
    this.registered = 0,
    this.checkedIn = 0,
    this.notCheckedIn = 0,
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
  final List<({String name, int registered, int checkedIn})> byTicketType;
  final List<({String who, DateTime? at, String? by})> recent;
}

class CampaignDraft {
  const CampaignDraft({
    required this.name,
    required this.discountType,
    required this.discountValue,
    this.maxRedemptions,
    this.validFrom,
    this.validTo,
  });

  final String name;
  final DiscountType discountType;
  final double discountValue;
  final int? maxRedemptions;
  final DateTime? validFrom;
  final DateTime? validTo;

  String? validate() {
    if (name.trim().isEmpty) return 'Name the campaign.';
    if (discountValue <= 0) return 'The discount must be above zero.';
    if (discountType == DiscountType.percentage && discountValue > 100) {
      return 'A percentage discount cannot exceed 100%.';
    }
    if (maxRedemptions != null && maxRedemptions! < 1) return 'Allow at least one redemption.';
    if (validFrom != null && validTo != null && !validTo!.isAfter(validFrom!)) {
      return 'The campaign must end after it starts.';
    }
    return null;
  }
}

/// Ответ создания кампании: код и ссылка для Campaign QR (§4.14).
class CreatedCampaign {
  const CreatedCampaign({required this.id, required this.code, required this.link});

  final int id;
  final String code;

  /// Относительная ссылка сервера `/events/{id}?promo=CODE`.
  final String link;
}

/// Строка O5 — один билет с владельцем.
class AttendeeRow {
  const AttendeeRow({required this.ticket, this.order});

  final TicketInfo ticket;
  final OrderInfo? order;

  bool get campaign => order?.promoCode != null;
}

enum AttendeeFilter { all, checkedIn, notArrived, refunded, campaign }

// ─── repository ────────────────────────────────────────────────────────────

abstract interface class OrganizerOperationsRepository {
  Future<Result<List<OrderInfo>>> orders(int eventId);

  Future<Result<List<TicketInfo>>> tickets(int eventId);

  Future<Result<void>> refund(int orderId, String reason);

  Future<Result<List<AuditEntry>>> timeline(int eventId);

  Future<Result<CheckInOverview>> checkInOverview(int eventId);

  Future<Result<List<CampaignInfo>>> campaigns(int eventId);

  Future<Result<CreatedCampaign>> createCampaign(int eventId, CampaignDraft draft);

  Future<Result<void>> deactivateCampaign(int id);

  Future<Result<List<StaffAssignment>>> staff(int eventId);

  Future<Result<StaffAssignment>> assignStaff(int eventId, int userId);

  Future<Result<void>> removeStaff(int assignmentId);
}

// ─── use cases ─────────────────────────────────────────────────────────────

/// O5: все билеты события с заказами, фильтры и поиск.
class GetEventAttendees {
  const GetEventAttendees(this._repo);

  final OrganizerOperationsRepository _repo;

  Future<Result<List<AttendeeRow>>> call(int eventId) async {
    final results = await Future.wait([_repo.tickets(eventId), _repo.orders(eventId)]);
    final t = results[0] as Result<List<TicketInfo>>;
    final o = results[1] as Result<List<OrderInfo>>;
    if (t case Err(:final failure)) return Err(failure);
    final orders = {for (final x in o.valueOrNull ?? const <OrderInfo>[]) x.id: x};
    return Ok([for (final ticket in t.valueOrNull!) AttendeeRow(ticket: ticket, order: orders[ticket.orderId])]);
  }
}

List<AttendeeRow> filterAttendees(List<AttendeeRow> rows, AttendeeFilter f, String query) {
  final q = query.trim().toLowerCase();
  return rows.where((r) {
    final s = r.ticket.status;
    final keep = switch (f) {
      AttendeeFilter.all => true,
      AttendeeFilter.checkedIn => s == TicketStatus.checkedIn,
      AttendeeFilter.notArrived => s == TicketStatus.valid,
      AttendeeFilter.refunded => s == TicketStatus.refunded || s == TicketStatus.cancelled,
      AttendeeFilter.campaign => r.campaign,
    };
    if (!keep) return false;
    if (q.isEmpty) return true;
    return [r.ticket.attendeeName, r.ticket.attendeeEmail, r.ticket.code, r.ticket.displayId]
        .whereType<String>()
        .any((v) => v.toLowerCase().contains(q));
  }).toList();
}

/// O5 «EXPORT CSV» — без платёжных данных.
String attendeesCsv(List<AttendeeRow> rows) {
  String cell(Object? v) {
    final s = '${v ?? ''}';
    return s.contains(RegExp(r'[",\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
  }

  final lines = [
    'Attendee,Email,Ticket type,Seat,Ticket ID,Order,Status,Promo code',
    for (final r in rows)
      [
        r.ticket.attendeeName,
        r.ticket.attendeeEmail,
        r.ticket.ticketTypeName,
        r.ticket.seat,
        r.ticket.displayId,
        r.order?.number,
        r.ticket.status.label,
        r.order?.promoCode,
      ].map(cell).join(','),
  ];
  return '${lines.join('\n')}\n';
}

/// O6 / UC5: полный возврат заказа. Причина обязательна — она уходит
/// в журнал (§4.9).
class RefundOrder {
  const RefundOrder(this._repo);

  final OrganizerOperationsRepository _repo;

  Future<Result<void>> call(OrderInfo order, String reason) async {
    if (order.status == OrderStatus.refunded) return const Err(ValidationFailure('This order is already refunded.'));
    if (order.status == OrderStatus.cancelled) return const Err(ValidationFailure('This order was cancelled.'));
    if (reason.trim().length < 3) return const Err(ValidationFailure('Record a reason for the refund.'));
    return _repo.refund(order.id, reason.trim());
  }
}

class GetTimeline {
  const GetTimeline(this._repo);

  final OrganizerOperationsRepository _repo;

  Future<Result<List<AuditEntry>>> call(int eventId) async {
    final r = await _repo.timeline(eventId);
    return switch (r) {
      Ok(:final value) => Ok([...value]..sort((a, b) => (b.at ?? DateTime(0)).compareTo(a.at ?? DateTime(0)))),
      Err(:final failure) => Err(failure),
    };
  }
}

class GetCheckInOverview {
  const GetCheckInOverview(this._repo);

  final OrganizerOperationsRepository _repo;

  Future<Result<CheckInOverview>> call(int eventId) => _repo.checkInOverview(eventId);
}

/// Продажи по дням из времени заказов — график O7 «Sales over time».
List<({DateTime day, int tickets})> salesByDay(List<OrderInfo> orders) {
  final map = <DateTime, int>{};
  for (final o in orders) {
    final at = o.createdAt;
    if (at == null || o.status == OrderStatus.cancelled || o.status == OrderStatus.pending) continue;
    final day = DateTime(at.year, at.month, at.day);
    map[day] = (map[day] ?? 0) + o.ticketCount;
  }
  final days = map.keys.toList()..sort();
  return [for (final d in days) (day: d, tickets: map[d]!)];
}

class GetSalesOverTime {
  const GetSalesOverTime(this._repo);

  final OrganizerOperationsRepository _repo;

  Future<Result<List<({DateTime day, int tickets})>>> call(int eventId) async {
    final r = await _repo.orders(eventId);
    return switch (r) {
      Ok(:final value) => Ok(salesByDay(value)),
      Err(:final failure) => Err(failure),
    };
  }
}

class ManageCampaigns {
  const ManageCampaigns(this._repo);

  final OrganizerOperationsRepository _repo;

  Future<Result<List<CampaignInfo>>> list(int eventId) => _repo.campaigns(eventId);

  Future<Result<CreatedCampaign>> create(int eventId, CampaignDraft d) async {
    final problem = d.validate();
    if (problem != null) return Err(ValidationFailure(problem));
    return _repo.createCampaign(eventId, d);
  }

  Future<Result<void>> deactivate(CampaignInfo c) async {
    if (!c.active) return const Err(ValidationFailure('This campaign is already disabled.'));
    return _repo.deactivateCampaign(c.id);
  }
}

/// O10: персонал на входе. Назначение пока только по ID пользователя —
/// поиска по email в API нет.
class ManageStaff {
  const ManageStaff(this._repo);

  final OrganizerOperationsRepository _repo;

  Future<Result<List<StaffAssignment>>> list(int eventId) => _repo.staff(eventId);

  Future<Result<StaffAssignment>> assign(int eventId, String rawUserId, List<StaffAssignment> current) async {
    final id = int.tryParse(rawUserId.trim());
    if (id == null || id < 1) return const Err(ValidationFailure('Enter the user\'s numeric ID.'));
    if (current.any((s) => s.user.id == id)) {
      return const Err(ValidationFailure('This person is already on the team.'));
    }
    return _repo.assignStaff(eventId, id);
  }

  Future<Result<void>> remove(StaffAssignment s) => _repo.removeStaff(s.id);
}
