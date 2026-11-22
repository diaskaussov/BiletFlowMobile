import '../../core/utils/json_reader.dart';
import '../../features/auth/domain/entities/user_session.dart';
import '../../features/checkin/data/models/scan_response_model.dart';
import '../domain/entities/commerce.dart';
import '../domain/entities/event_info.dart';
import '../domain/entities/insights.dart';
import '../domain/entities/people.dart';
import '../domain/entities/support.dart';

/// Парсеры ответов бэкенда в сущности. Даты событий — местное время
/// площадки; моменты (`createdAt`, `heldUntil`, …) сервер пишет в UTC без
/// пояса, поэтому читаются с `naiveIsUtc`.
abstract final class Models {
  static EventInfo event(Map<String, dynamic> j) {
    final organizer = j.obj('organizer');
    return EventInfo(
      id: j.integer(['id', 'eventId']) ?? 0,
      title: j.str(['title', 'name']) ?? 'Event',
      description: j.str(['description']),
      category: j.str(['category']),
      imageUrl: j.str(['imageUrl']),
      venueName: j.str(['venueName']),
      venueAddress: j.str(['venueAddress']),
      city: j.str(['city']),
      startsAt: j.date(['eventDate', 'startDate']),
      endsAt: j.date(['eventEndDate', 'endDate']),
      registrationOpensAt: j.date(['registrationOpenDate']),
      registrationClosesAt: j.date(['registrationCloseDate']),
      capacity: j.integer(['capacity']),
      status: EventStatus.parse(j.str(['status'])),
      visibility: EventVisibility.parse(j.str(['visibility'])),
      paidSalesActivated: j.boolean(['paidSalesActivated']) ?? false,
      assignedSeating: j.boolean(['assignedSeating']) ?? false,
      organizerId: j.integer(['organizerId']) ?? organizer?.integer(['id']),
      organizerName: j.str(['organizerName']) ??
          (organizer == null ? null : user(organizer).fullName),
    );
  }

  static TicketTypeInfo ticketType(Map<String, dynamic> j) => TicketTypeInfo(
        id: j.integer(['id']) ?? 0,
        eventId: j.obj('event')?.integer(['id']) ?? j.integer(['eventId']),
        name: j.str(['name']) ?? 'Ticket',
        description: j.str(['description']),
        price: double.tryParse(j.str(['price']) ?? '') ?? 0,
        quantity: j.integer(['quantity']) ?? 0,
        sold: j.integer(['sold']) ?? 0,
        free: j.boolean(['free']) ?? false,
        hidden: j.boolean(['hidden']) ?? false,
        salesStart: j.date(['salesStart']),
        salesEnd: j.date(['salesEnd']),
        maxPerOrder: j.integer(['maxPerOrder']),
      );

  static OrderInfo order(Map<String, dynamic> j) {
    final attendee = j.obj('attendee');
    final event = j.obj('event');
    final promo = j['promoCode'];
    return OrderInfo(
      id: j.integer(['id']) ?? 0,
      eventId: j.integer(['eventId']) ?? event?.integer(['id']),
      eventTitle: j.str(['eventTitle']) ?? event?.str(['title']),
      attendeeName: j.str(['attendeeName']) ??
          _join(j.str(['attendeeFirstName']), j.str(['attendeeLastName'])) ??
          (attendee == null ? null : user(attendee).fullName),
      attendeeEmail: j.str(['attendeeEmail']) ?? attendee?.str(['email']),
      total: _num(j, ['totalAmount', 'total']),
      discount: _num(j, ['discountAmount', 'discount']),
      status: OrderStatus.parse(j.str(['status'])),
      promoCode: promo is Map ? promo.cast<String, dynamic>().str(['code']) : j.str(['promoCode']),
      items: jsonList(j['items']).map((i) {
        return OrderItemInfo(
          ticketTypeName: i.str(['ticketTypeName']) ?? 'Ticket',
          quantity: i.integer(['quantity']) ?? 1,
          unitPrice: _num(i, ['unitPrice', 'price']),
          discount: _num(i, ['discount']),
          seats: (i['seats'] is List) ? (i['seats'] as List).map((s) => '$s').toList() : const [],
        );
      }).toList(),
      createdAt: j.date(['createdAt'], naiveIsUtc: true),
    );
  }

  static TicketInfo ticket(Map<String, dynamic> j) {
    final type = j.obj('ticketType');
    final order = j.obj('order');
    final event = j.obj('event') ?? type?.obj('event');
    return TicketInfo(
      id: j.integer(['id', 'ticketId']) ?? 0,
      code: j.str(['ticketCode', 'code']) ?? '',
      status: TicketStatus.parse(j.str(['status'])),
      ticketTypeName: type?.str(['name']) ?? j.str(['ticketType', 'ticketTypeName']),
      attendeeName: j.str(['attendeeName']) ??
          _join(order?.str(['attendeeFirstName']), order?.str(['attendeeLastName'])),
      attendeeEmail: j.str(['attendeeEmail']) ?? order?.str(['attendeeEmail']),
      seat: ScanResponseModel.seatLabel(j),
      orderId: order?.integer(['id']) ?? j.integer(['orderId']),
      eventId: event?.integer(['id']) ?? j.integer(['eventId']),
      eventTitle: event?.str(['title']) ?? j.str(['eventTitle']),
      eventStartsAt: event?.date(['eventDate']),
      eventVenue: event == null
          ? null
          : [event.str(['venueName']), event.str(['city'])].whereType<String>().join(', '),
      createdAt: j.date(['createdAt'], naiveIsUtc: true),
      price: type == null ? null : double.tryParse(type.str(['price']) ?? ''),
    );
  }

  static SeatInfo seat(Map<String, dynamic> j) => SeatInfo(
        id: j.integer(['id']) ?? 0,
        section: j.str(['section', 'seatSection']) ?? '',
        row: j.str(['row', 'seatRow']) ?? '',
        number: j.str(['number', 'seatNumber']) ?? '',
        status: SeatStatus.parse(j.str(['status'])),
        ticketTypeId: j.integer(['ticketTypeId']),
        ticketTypeName: j.str(['ticketTypeName']),
        price: double.tryParse(j.str(['price']) ?? ''),
        heldByMe: j.boolean(['heldByMe']) ?? false,
        heldUntil: j.date(['heldUntil'], naiveIsUtc: true),
      );

  static CampaignInfo campaign(Map<String, dynamic> j) {
    final event = j.obj('event');
    final promo = j.obj('promoCode');
    return CampaignInfo(
      id: j.integer(['id']) ?? 0,
      name: j.str(['name', 'campaignName']) ?? 'Campaign',
      code: j.str(['code', 'promoCode']) ?? promo?.str(['code']),
      eventId: event?.integer(['id']) ?? j.integer(['eventId']),
      eventTitle: event?.str(['title']),
      discountType: DiscountType.parse(j.str(['discountType'])),
      discountValue: _num(j, ['discountValue']),
      maxRedemptions: j.integer(['maxRedemptions']),
      redemptions: j.integer(['currentRedemptions', 'redemptions']) ?? promo?.integer(['redemptions']) ?? 0,
      validFrom: j.date(['validFrom']),
      validTo: j.date(['validTo']),
      active: j.boolean(['active']) ?? true,
    );
  }

  static UserAccount user(Map<String, dynamic> j) => UserAccount(
        id: j.integer(['id', 'userId']) ?? 0,
        email: j.str(['email']) ?? '',
        role: UserRole.parse(j.str(['role'])),
        firstName: j.str(['firstName']) ?? '',
        lastName: j.str(['lastName']) ?? '',
        phone: j.str(['phone']),
        emailVerified: j.boolean(['emailVerified']) ?? false,
        suspended: j.boolean(['suspended']) ?? false,
        createdAt: j.date(['createdAt'], naiveIsUtc: true),
      );

  static StaffAssignment staff(Map<String, dynamic> j) => StaffAssignment(
        id: j.integer(['id']) ?? 0,
        eventId: j.obj('event')?.integer(['id']) ?? j.integer(['eventId']),
        user: user(j.obj('user') ?? j),
      );

  static OrganizerProfile organizerProfile(Map<String, dynamic> j) => OrganizerProfile(
        organizationName: j.str(['organizationName']) ?? '',
        description: j.str(['description']) ?? '',
        contactEmail: j.str(['contactEmail']) ?? '',
        contactPhone: j.str(['contactPhone']) ?? '',
        website: j.str(['website']) ?? '',
        payoutBankName: j.str(['payoutBankName']) ?? '',
        payoutAccountNumber: j.str(['payoutAccountNumber']) ?? '',
        payoutAccountHolder: j.str(['payoutAccountHolder']) ?? '',
        identityVerified: j.boolean(['identityVerified']) ?? false,
        payoutVerified: j.boolean(['payoutVerified']) ?? false,
      );

  static SupportMessageInfo supportMessage(Map<String, dynamic> j) {
    final sender = j.obj('sender');
    return SupportMessageInfo(
      id: j.integer(['id']) ?? 0,
      text: j.str(['message', 'text']) ?? '',
      senderName: sender == null ? (j.str(['senderName']) ?? 'Support') : user(sender).fullName,
      senderId: sender?.integer(['id']) ?? j.integer(['senderId']),
      senderRole: sender?.str(['role']),
      createdAt: j.date(['createdAt'], naiveIsUtc: true),
    );
  }

  static SupportCaseInfo supportCase(Map<String, dynamic> j) {
    final requester = j.obj('user');
    final event = j.obj('event');
    final assigned = j.obj('assignedTo');
    return SupportCaseInfo(
      id: j.integer(['id']) ?? 0,
      subject: j.str(['subject']) ?? 'Support request',
      category: CaseCategory.parse(j.str(['category'])),
      status: CaseStatus.parse(j.str(['status'])),
      requesterName: requester == null ? null : user(requester).fullName,
      requesterId: requester?.integer(['id']),
      eventId: event?.integer(['id']) ?? j.integer(['eventId']),
      eventTitle: event?.str(['title']),
      orderId: j.obj('order')?.integer(['id']) ?? j.integer(['orderId']),
      assignedTo: assigned == null ? null : user(assigned).fullName,
      messages: jsonList(j['messages']).map(supportMessage).toList(),
      createdAt: j.date(['createdAt'], naiveIsUtc: true),
      updatedAt: j.date(['updatedAt'], naiveIsUtc: true),
    );
  }

  static NotificationInfo notification(Map<String, dynamic> j) => NotificationInfo(
        id: j.integer(['id']) ?? 0,
        title: j.str(['title']) ?? 'Notification',
        message: j.str(['message']) ?? '',
        type: j.str(['type']),
        read: j.boolean(['read', 'isRead']) ?? false,
        createdAt: j.date(['createdAt'], naiveIsUtc: true),
      );

  static EventAnalytics analytics(Map<String, dynamic> j) => EventAnalytics(
        totalCapacity: j.integer(['totalCapacity']) ?? 0,
        ticketsSold: j.integer(['ticketsSold']) ?? 0,
        ticketsRemaining: j.integer(['ticketsRemaining']) ?? 0,
        percentageSold: _num(j, ['percentageSold']),
        grossRevenue: _num(j, ['grossRevenue']),
        totalDiscounts: _num(j, ['totalDiscounts']),
        totalRefunds: _num(j, ['totalRefunds']),
        netRevenue: _num(j, ['netRevenue']),
        totalOrders: j.integer(['totalOrders']) ?? 0,
        totalAttendees: j.integer(['totalAttendees']) ?? 0,
        checkedIn: j.integer(['checkedIn']) ?? 0,
        checkInPercentage: _num(j, ['checkInPercentage']),
        byTicketType: jsonList(j['salesByTicketType'])
            .map((t) => TicketTypeSales(
                  name: t.str(['name']) ?? 'Ticket',
                  quantity: t.integer(['quantity']) ?? 0,
                  sold: t.integer(['sold']) ?? 0,
                  revenue: _num(t, ['revenue']),
                ))
            .toList(),
        campaigns: jsonList(j['campaigns'])
            .map((c) => CampaignStats(
                  name: c.str(['name']) ?? 'Campaign',
                  redemptions: c.integer(['redemptions']) ?? 0,
                  maxRedemptions: c.integer(['maxRedemptions']),
                ))
            .toList(),
      );

  static AuditEntry audit(Map<String, dynamic> j) => AuditEntry(
        id: j.integer(['id']) ?? 0,
        actionType: j.str(['actionType']) ?? 'UPDATE',
        description: j.str(['description']) ?? '',
        entityType: j.str(['entityType']),
        entityId: j.integer(['entityId']),
        userId: j.integer(['userId']),
        at: j.date(['timestamp', 'createdAt'], naiveIsUtc: true),
      );

  static ActivationChecklist checklist(Map<String, dynamic> j) => ActivationChecklist(
        hasPaidTicketType: j.boolean(['hasPaidTicketType']) ?? false,
        identityVerified: j.boolean(['identityVerified']) ?? false,
        payoutVerified: j.boolean(['payoutVerified']) ?? false,
        activationFeePaid: j.boolean(['activationFeePaid']) ?? false,
        allRequirementsMet: j.boolean(['allRequirementsMet']) ?? false,
        alreadyActivated: j.boolean(['alreadyActivated']) ?? false,
      );

  static double _num(Map<String, dynamic> j, List<String> keys) =>
      double.tryParse(j.str(keys) ?? '') ?? 0;

  static String? _join(String? a, String? b) {
    final s = [a, b].whereType<String>().join(' ').trim();
    return s.isEmpty ? null : s;
  }
}

/// Объект из ответа или ошибка формата.
Map<String, dynamic> jsonObject(dynamic data) {
  if (data is Map) return data.cast<String, dynamic>();
  throw const FormatException('Expected a JSON object');
}
