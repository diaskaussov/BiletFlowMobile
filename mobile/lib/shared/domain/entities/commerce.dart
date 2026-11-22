/// Тип билета (W2, O3).
class TicketTypeInfo {
  const TicketTypeInfo({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.eventId,
    this.description,
    this.sold = 0,
    this.free = false,
    this.hidden = false,
    this.salesStart,
    this.salesEnd,
    this.maxPerOrder,
  });

  final int id;
  final int? eventId;
  final String name;
  final String? description;
  final double price;
  final int quantity;
  final int sold;
  final bool free;
  final bool hidden;
  final DateTime? salesStart;
  final DateTime? salesEnd;
  final int? maxPerOrder;

  int get remaining => (quantity - sold).clamp(0, quantity);
  bool get isSoldOut => remaining == 0;
  bool get isFree => free || price == 0;

  bool isOnSale(DateTime now) {
    if (hidden || isSoldOut) return false;
    if (salesStart != null && now.isBefore(salesStart!)) return false;
    if (salesEnd != null && now.isAfter(salesEnd!)) return false;
    return true;
  }

  /// Сколько можно взять в один заказ.
  int get orderLimit => [remaining, maxPerOrder ?? 10].reduce((a, b) => a < b ? a : b);
}

enum OrderStatus {
  pending,
  completed,
  cancelled,
  refunded;

  static OrderStatus parse(String? raw) => switch (raw?.toUpperCase()) {
        'COMPLETED' || 'PAID' => OrderStatus.completed,
        'CANCELLED' => OrderStatus.cancelled,
        'REFUNDED' => OrderStatus.refunded,
        _ => OrderStatus.pending,
      };

  String get label => switch (this) {
        OrderStatus.pending => 'Awaiting payment',
        OrderStatus.completed => 'Paid',
        OrderStatus.cancelled => 'Cancelled',
        OrderStatus.refunded => 'Refunded',
      };
}

class OrderItemInfo {
  const OrderItemInfo({
    required this.ticketTypeName,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
    this.seats = const [],
  });

  final String ticketTypeName;
  final int quantity;
  final double unitPrice;
  final double discount;
  final List<String> seats;

  double get subtotal => unitPrice * quantity;
}

class OrderInfo {
  const OrderInfo({
    required this.id,
    required this.status,
    required this.total,
    this.eventId,
    this.eventTitle,
    this.attendeeName,
    this.attendeeEmail,
    this.discount = 0,
    this.promoCode,
    this.items = const [],
    this.createdAt,
  });

  final int id;
  final int? eventId;
  final String? eventTitle;
  final String? attendeeName;
  final String? attendeeEmail;
  final double total;
  final double discount;
  final OrderStatus status;
  final String? promoCode;
  final List<OrderItemInfo> items;
  final DateTime? createdAt;

  int get ticketCount => items.fold(0, (sum, i) => sum + i.quantity);
  String get number => 'ORD-${id.toString().padLeft(4, '0')}';
}

enum TicketStatus {
  valid,
  checkedIn,
  cancelled,
  refunded;

  static TicketStatus parse(String? raw) => switch (raw?.toUpperCase()) {
        'CHECKED_IN' || 'USED' => TicketStatus.checkedIn,
        'CANCELLED' => TicketStatus.cancelled,
        'REFUNDED' => TicketStatus.refunded,
        _ => TicketStatus.valid,
      };

  String get label => switch (this) {
        TicketStatus.valid => 'Valid',
        TicketStatus.checkedIn => 'Checked in',
        TicketStatus.cancelled => 'Cancelled',
        TicketStatus.refunded => 'Refunded',
      };
}

/// Выпущенный билет (W6–W8, O5).
class TicketInfo {
  const TicketInfo({
    required this.id,
    required this.code,
    required this.status,
    this.ticketTypeName,
    this.attendeeName,
    this.attendeeEmail,
    this.seat,
    this.orderId,
    this.eventId,
    this.eventTitle,
    this.eventStartsAt,
    this.eventVenue,
    this.createdAt,
    this.price,
  });

  final int id;
  final String code;
  final TicketStatus status;
  final String? ticketTypeName;
  final String? attendeeName;
  final String? attendeeEmail;
  final String? seat;
  final int? orderId;
  final int? eventId;
  final String? eventTitle;
  final DateTime? eventStartsAt;
  final String? eventVenue;
  final DateTime? createdAt;
  final double? price;

  /// «TCK-C67B8E0D» — короткий ID для глаз; в QR лежит полный код.
  String get displayId {
    final c = code.replaceAll('-', '').toUpperCase();
    return 'TCK-${c.length > 8 ? c.substring(0, 8) : c}';
  }
}

enum SeatStatus {
  available,
  held,
  sold,
  unavailable;

  static SeatStatus parse(String? raw) => switch (raw?.toUpperCase()) {
        'AVAILABLE' || 'FREE' => SeatStatus.available,
        'HELD' || 'RESERVED' => SeatStatus.held,
        'SOLD' || 'BOOKED' => SeatStatus.sold,
        _ => SeatStatus.unavailable,
      };
}

/// Место на схеме зала (W4, §4.3.1).
class SeatInfo {
  const SeatInfo({
    required this.id,
    required this.section,
    required this.row,
    required this.number,
    required this.status,
    this.ticketTypeId,
    this.ticketTypeName,
    this.price,
    this.heldByMe = false,
    this.heldUntil,
  });

  final int id;
  final String section;
  final String row;
  final String number;
  final SeatStatus status;
  final int? ticketTypeId;
  final String? ticketTypeName;
  final double? price;
  final bool heldByMe;
  final DateTime? heldUntil;

  bool get selectable => status == SeatStatus.available || heldByMe;

  String get label => 'Sec $section · Row $row · Seat $number';
}

enum DiscountType {
  percentage,
  fixed;

  static DiscountType parse(String? raw) =>
      raw?.toUpperCase() == 'FIXED_KZT' ? DiscountType.fixed : DiscountType.percentage;

  String get wire => this == DiscountType.fixed ? 'FIXED_KZT' : 'PERCENTAGE';
}

/// Промокод / кампания (W3, O8).
class CampaignInfo {
  const CampaignInfo({
    required this.id,
    required this.name,
    required this.discountType,
    required this.discountValue,
    this.code,
    this.eventId,
    this.eventTitle,
    this.maxRedemptions,
    this.redemptions = 0,
    this.validFrom,
    this.validTo,
    this.active = true,
  });

  final int id;
  final String name;
  final String? code;
  final int? eventId;
  final String? eventTitle;
  final DiscountType discountType;
  final double discountValue;
  final int? maxRedemptions;
  final int redemptions;
  final DateTime? validFrom;
  final DateTime? validTo;
  final bool active;

  int? get remaining => maxRedemptions == null ? null : (maxRedemptions! - redemptions).clamp(0, maxRedemptions!);

  bool isLive(DateTime now) {
    if (!active) return false;
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validTo != null && now.isAfter(validTo!)) return false;
    return remaining != 0;
  }

  /// Скидка на одну цену — тот же расчёт, что показывает сервер в итоге.
  double discountFor(double price) => switch (discountType) {
        DiscountType.percentage => (price * discountValue / 100).clamp(0, price),
        DiscountType.fixed => discountValue.clamp(0, price),
      };
}
