import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/error/result.dart';
import 'package:mobile/features/admin/domain/admin_domain.dart';
import 'package:mobile/features/auth/domain/entities/user_session.dart';
import 'package:mobile/features/catalog/domain/catalog_domain.dart';
import 'package:mobile/features/checkout/domain/cart.dart';
import 'package:mobile/features/checkout/domain/checkout_domain.dart';
import 'package:mobile/features/organizer/domain/organizer_events_domain.dart';
import 'package:mobile/features/organizer/domain/organizer_operations_domain.dart';
import 'package:mobile/features/support/domain/support_domain.dart';
import 'package:mobile/features/tickets/domain/tickets_domain.dart';
import 'package:mobile/shared/domain/entities/support.dart';
import 'package:mobile/shared/data/models.dart';
import 'package:mobile/shared/domain/entities/commerce.dart';
import 'package:mobile/shared/domain/entities/event_info.dart';
import 'package:mobile/shared/domain/entities/people.dart';

final now = DateTime(2026, 11, 22, 12); // воскресенье

EventInfo event({int id = 1, String title = 'Alma Fest', String city = 'Almaty', String category = 'Music', DateTime? at, bool seated = false}) =>
    EventInfo(id: id, title: title, city: city, category: category, startsAt: at ?? now.add(const Duration(days: 3)), assignedSeating: seated, status: EventStatus.published);

TicketTypeInfo type(int id, double price, {int qty = 100, int sold = 0, int? max}) =>
    TicketTypeInfo(id: id, name: 'T$id', price: price, quantity: qty, sold: sold, maxPerOrder: max);

void main() {
  group('W1 filters', () {
    final all = [
      EventListing(event: event(id: 1, title: 'Alma Fest', at: now.add(const Duration(hours: 2))), minPrice: 4500),
      EventListing(event: event(id: 2, title: 'Demo Day', city: 'Astana', category: 'Tech', at: now.add(const Duration(days: 6))), minPrice: 0),
      EventListing(event: event(id: 3, title: 'Jazz', at: now.add(const Duration(days: 60))), minPrice: 6000),
    ];
    List<int> ids(EventFilter f) => applyFilter(all, f, now).map((l) => l.event.id).toList();

    test('search matches title, city and category', () {
      expect(ids(const EventFilter(query: 'astana')), [2]);
      expect(ids(const EventFilter(query: 'music')), [1, 3]);
    });
    test('city, category, price', () {
      expect(ids(const EventFilter(city: 'Almaty')), [1, 3]);
      expect(ids(const EventFilter(category: 'Tech')), [2]);
      expect(ids(const EventFilter(price: PriceFilter.free)), [2]);
      expect(ids(const EventFilter(price: PriceFilter.under5000)), [1, 2]);
    });
    test('when', () {
      expect(ids(const EventFilter(when: WhenFilter.today)), [1]);
      expect(ids(const EventFilter(when: WhenFilter.next30)), [1, 2]);
      expect(ids(const EventFilter(when: WhenFilter.weekend)), [2]); // следующая суббота
      expect(const EventFilter(city: 'A', price: PriceFilter.free).activeCount, 2);
    });
  });

  group('campaign link', () {
    test('server link format', () {
      final l = parseCampaignLink('https://biletflow.kz/events/3?promo=BF-A729EE33');
      expect(l.eventId, 3);
      expect(l.code, 'BF-A729EE33');
    });
    test('short /e/ form and foreign links', () {
      expect(parseCampaignLink('https://biletflow.kz/e/12?c=x').eventId, 12);
      expect(parseCampaignLink('https://kaspi.kz/pay').eventId, isNull);
    });
  });

  group('Cart', () {
    final paid = type(1, 5000, qty: 3, max: 4);
    final free = type(2, 0);
    final e = event();

    test('quantity respects remaining and per-order limit', () {
      final c = Cart(event: e, ticketTypes: [paid, free]).withQuantity(paid, 9);
      expect(c.quantities[1], 3);
      expect(Cart(event: e, ticketTypes: [type(3, 10, max: 2)]).withQuantity(type(3, 10, max: 2), 5).ticketCount, 2);
    });

    test('promo estimate and total', () {
      const promo = PromoValidation(code: 'X', discountType: DiscountType.percentage, discountValue: 20);
      final c = Cart(event: e, ticketTypes: [paid, free], promo: promo).withQuantity(paid, 2).withQuantity(free, 1);
      expect(c.subtotal, 10000);
      expect(c.discount, 2000);
      expect(c.total, 8000);
      expect(c.isFree, isFalse);
      const fixed = PromoValidation(code: 'Y', discountType: DiscountType.fixed, discountValue: 9000);
      expect(Cart(event: e, ticketTypes: [paid], promo: fixed).withQuantity(paid, 1).total, 0);
    });

    test('seats must match quantities per type', () {
      final seated = Cart(event: event(seated: true), ticketTypes: [paid]).withQuantity(paid, 2);
      expect(seated.seatsComplete, isFalse);
      const s1 = SeatInfo(id: 1, section: 'A', row: '1', number: '1', status: SeatStatus.available, ticketTypeId: 1);
      const s2 = SeatInfo(id: 2, section: 'A', row: '1', number: '2', status: SeatStatus.available, ticketTypeId: 1);
      expect(seated.copyWith(seats: [s1, s2]).seatsComplete, isTrue);
    });
  });

  group('PlaceOrder', () {
    test('validates buyer and hold before calling the server', () async {
      final repo = _FakeCheckout();
      final place = PlaceOrder(repo, clock: () => now);
      final cart = Cart(event: event(), ticketTypes: [type(1, 100)]).withQuantity(type(1, 100), 1);
      expect((await place(cart, const BuyerDetails(firstName: '', lastName: 'B', email: 'a@b.kz'))).failureOrNull, isA<ValidationFailure>());
      expect((await place(cart, const BuyerDetails(firstName: 'A', lastName: 'B', email: 'bad'))).failureOrNull, isA<ValidationFailure>());
      final expired = cart.copyWith(heldUntil: () => now.subtract(const Duration(minutes: 1)));
      expect((await place(expired, const BuyerDetails(firstName: 'A', lastName: 'B', email: 'a@b.kz'))).failureOrNull?.message, contains('expired'));
      expect(repo.created, 0);
    });

    test('paid order is paid in the sandbox; free order is not', () async {
      final repo = _FakeCheckout();
      final place = PlaceOrder(repo, clock: () => now);
      const buyer = BuyerDetails(firstName: 'A', lastName: 'B', email: 'a@b.kz');
      final paid = await place(Cart(event: event(), ticketTypes: [type(1, 100)]).withQuantity(type(1, 100), 1), buyer);
      expect(paid.valueOrNull?.status, OrderStatus.completed);
      expect(repo.paid, 1);
      repo.nextStatus = OrderStatus.completed;
      await place(Cart(event: event(), ticketTypes: [type(2, 0)]).withQuantity(type(2, 0), 1), buyer);
      expect(repo.paid, 1);
    });

    test('HoldSeats requires one seat per ticket of each type', () async {
      final cart = Cart(event: event(seated: true), ticketTypes: [type(1, 0)]).withQuantity(type(1, 0), 2);
      const s = SeatInfo(id: 1, section: 'A', row: '1', number: '1', status: SeatStatus.available, ticketTypeId: 1);
      expect((await HoldSeats(_FakeCheckout())(cart, [s])).failureOrNull?.message, contains('Choose 2 seats'));
    });
  });

  test('W8 grouping: upcoming, past, refunded', () {
    TicketInfo t(int id, int eventId, DateTime at, TicketStatus s) =>
        TicketInfo(id: id, code: 'c$id', status: s, eventId: eventId, eventStartsAt: at, eventTitle: 'E$eventId');
    final g = groupTickets([
      t(1, 1, now.add(const Duration(days: 2)), TicketStatus.valid),
      t(2, 1, now.add(const Duration(days: 2)), TicketStatus.valid),
      t(3, 2, now.subtract(const Duration(days: 5)), TicketStatus.checkedIn),
      t(4, 3, now.add(const Duration(days: 9)), TicketStatus.refunded),
    ], now);
    expect(g.upcoming.single.tickets.length, 2);
    expect(g.past.single.eventId, 2);
    expect(g.refunded.single.eventId, 3);
  });

  test('W8: a refunded and a new order for the same event are separate cards', () {
    TicketInfo t(int id, int orderId, TicketStatus s) => TicketInfo(
          id: id, code: 'c$id', status: s, eventId: 3, orderId: orderId,
          eventStartsAt: now.add(const Duration(days: 10)), eventTitle: 'Mobile Demo Night',
        );
    final g = groupTickets([t(2, 2, TicketStatus.refunded), t(3, 2, TicketStatus.refunded), t(6, 4, TicketStatus.valid)], now);
    expect(g.upcoming.single.orderId, 4);
    expect(g.upcoming.single.tickets.single.id, 6);
    expect(g.refunded.single.orderId, 2);
  });

  group('organizer rules', () {
    test('event draft validation', () {
      final base = EventDraft(title: 'T', venueName: 'V', city: 'C', startsAt: now, capacity: 10);
      expect(base.validate(), isNull);
      expect(base.copyWith(title: ' ').validate(), contains('title'));
      expect(base.copyWith(endsAt: now.subtract(const Duration(hours: 1))).validate(), contains('end after'));
      expect(base.copyWith(capacity: () => 0).validate(), contains('capacity'));
      expect(base.copyWith(registrationOpensAt: now, registrationClosesAt: now.subtract(const Duration(days: 1))).validate(), contains('close after'));
    });

    test('ticket type validation', () {
      expect(const TicketTypeDraft(name: 'GA', quantity: 10).validate(), isNull);
      expect(const TicketTypeDraft(name: 'GA', quantity: 10).validate(alreadySold: 20), contains('already sold'));
      expect(const TicketTypeDraft(name: '', quantity: 1).validate(), isNotNull);
      expect(const TicketTypeDraft(name: 'X', quantity: 1, price: -1).validate(), contains('negative'));
    });

    test('campaign validation', () {
      expect(const CampaignDraft(name: 'S', discountType: DiscountType.percentage, discountValue: 120).validate(), contains('100%'));
      expect(const CampaignDraft(name: 'S', discountType: DiscountType.fixed, discountValue: 500).validate(), isNull);
      expect(const CampaignDraft(name: 'S', discountType: DiscountType.fixed, discountValue: 0).validate(), isNotNull);
    });

    test('dashboard grouping', () {
      EventInfo e(EventStatus s, DateTime at) => EventInfo(id: 1, title: 'x', status: s, startsAt: at, endsAt: at.add(const Duration(hours: 3)));
      expect(GetOrganizerDashboard.groupOf(e(EventStatus.published, now.subtract(const Duration(hours: 1))), now), DashboardGroup.active);
      expect(GetOrganizerDashboard.groupOf(e(EventStatus.published, now.add(const Duration(days: 1))), now), DashboardGroup.upcoming);
      expect(GetOrganizerDashboard.groupOf(e(EventStatus.published, now.subtract(const Duration(days: 3))), now), DashboardGroup.completed);
      expect(GetOrganizerDashboard.groupOf(e(EventStatus.draft, now), now), DashboardGroup.draft);
    });

    test('attendee filters and CSV', () {
      AttendeeRow r(TicketStatus s, String name, {String? promo}) => AttendeeRow(
            ticket: TicketInfo(id: 1, code: 'abc', status: s, attendeeName: name, attendeeEmail: '$name@x.kz'),
            order: OrderInfo(id: 2, status: OrderStatus.completed, total: 0, promoCode: promo),
          );
      final rows = [r(TicketStatus.checkedIn, 'Dias'), r(TicketStatus.valid, 'Aliya', promo: 'S20'), r(TicketStatus.refunded, 'Ruslan, Jr')];
      expect(filterAttendees(rows, AttendeeFilter.checkedIn, '').single.ticket.attendeeName, 'Dias');
      expect(filterAttendees(rows, AttendeeFilter.campaign, '').single.ticket.attendeeName, 'Aliya');
      expect(filterAttendees(rows, AttendeeFilter.all, 'ruslan').length, 1);
      final csv = attendeesCsv(rows);
      expect(csv.split('\n').first, startsWith('Attendee,Email'));
      expect(csv, contains('"Ruslan, Jr"'));
    });

    test('sales by day ignores unpaid and cancelled orders', () {
      final d = now.subtract(const Duration(days: 1));
      OrderInfo o(OrderStatus s, DateTime at, int qty) => OrderInfo(
            id: 1, status: s, total: 0, createdAt: at,
            items: [OrderItemInfo(ticketTypeName: 'GA', quantity: qty, unitPrice: 0)],
          );
      final sales = salesByDay([o(OrderStatus.completed, d, 2), o(OrderStatus.completed, d.add(const Duration(hours: 2)), 1), o(OrderStatus.pending, now, 5), o(OrderStatus.refunded, now, 1)]);
      expect(sales.first.tickets, 3);
      expect(sales.length, 2);
    });

    test('staff assignment validation', () async {
      final current = [StaffAssignment(id: 1, user: const UserAccount(id: 4, email: 'e@x.kz', role: UserRole.eventAdmin))];
      final staff = ManageStaff(_NoOps());
      expect((await staff.assign(1, 'abc', current)).failureOrNull, isA<ValidationFailure>());
      expect((await staff.assign(1, '4', current)).failureOrNull?.message, contains('already'));
    });
  });

  test('attendee support case needs an event so an organizer receives it', () async {
    final open = OpenCase(_NoSupport());
    final r = await open(const NewCase(category: CaseCategory.eventInfo, subject: 'What is wrong?', message: 'Hi'), requireContext: true);
    expect(r.failureOrNull?.message, contains('Choose the event'));
  });

  group('admin rules', () {
    test('cannot suspend yourself or another admin', () async {
      final actions = ModerationActions(_NoAdmin());
      const me = UserAccount(id: 1, email: 'a@x', role: UserRole.platformAdmin);
      const other = UserAccount(id: 2, email: 'b@x', role: UserRole.platformAdmin);
      expect((await actions.suspendUser(me, currentAdminId: 1)).failureOrNull?.message, contains('own'));
      expect((await actions.suspendUser(other, currentAdminId: 1)).failureOrNull, isA<ValidationFailure>());
      expect((await actions.suspendEvent(event(), ' ')).failureOrNull, isA<ValidationFailure>());
    });
  });

  group('models', () {
    test('order response', () {
      final o = Models.order({
        'id': 2, 'eventId': 3, 'eventTitle': 'Mobile Demo Night', 'attendeeName': 'Mobile Tester',
        'totalAmount': 8000.0, 'discountAmount': 2000.0, 'status': 'COMPLETED', 'promoCode': 'BF-A',
        'items': [{'ticketTypeName': 'VIP', 'quantity': 2, 'unitPrice': 5000.0, 'seats': ['A-1-1']}],
        'createdAt': '2026-11-22T11:11:44.24',
      });
      expect(o.number, 'ORD-0002');
      expect(o.ticketCount, 2);
      expect(o.items.single.seats, ['A-1-1']);
      expect(o.createdAt, DateTime.utc(2026, 11, 22, 11, 11, 44, 240).toLocal());
    });

    test('ticket response with nested type, order and event', () {
      final t = Models.ticket({
        'id': 1, 'ticketCode': 'c67b8e0d-9530-4529', 'status': 'VALID', 'seatSection': 'A', 'seatRow': '1', 'seatNumber': '2',
        'ticketType': {'name': 'GA', 'price': 0},
        'order': {'id': 9, 'attendeeFirstName': 'Test', 'attendeeLastName': 'Scan'},
        'event': {'id': 3, 'title': 'Night', 'eventDate': '2026-12-02T19:00:00', 'venueName': 'Arena', 'city': 'Almaty'},
      });
      expect(t.displayId, 'TCK-C67B8E0D');
      expect(t.attendeeName, 'Test Scan');
      expect(t.seat, 'Sec A · Row 1 · Seat 2');
      expect(t.eventStartsAt, DateTime(2026, 12, 2, 19));
      expect(t.eventVenue, 'Arena, Almaty');
    });

    test('admin user model never keeps secrets', () {
      final u = Models.user({'id': 1, 'email': 'a@b', 'password': r'$2a$hash', 'role': 'ATTENDEE', 'suspended': true});
      expect(u.suspended, isTrue);
      expect(u.role, UserRole.attendee);
    });
  });
}

class _FakeCheckout implements CheckoutRepository {
  int created = 0;
  int paid = 0;
  OrderStatus nextStatus = OrderStatus.pending;

  @override
  Future<Result<OrderInfo>> createOrder(Cart cart, BuyerDetails buyer) async {
    created++;
    return Ok(OrderInfo(id: 1, status: nextStatus, total: cart.total));
  }

  @override
  Future<Result<OrderInfo>> pay(int orderId) async {
    paid++;
    return Ok(OrderInfo(id: orderId, status: OrderStatus.completed, total: 0));
  }

  @override
  Future<Result<SeatHold>> hold(int eventId, List<int> seatIds) async => const Ok(SeatHold(seats: []));

  @override
  Future<Result<void>> release(int eventId, List<int> seatIds) async => const Ok(null);

  @override
  Future<Result<List<SeatInfo>>> seats(int eventId) async => const Ok([]);
}

class _NoOps implements OrganizerOperationsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _NoSupport implements SupportRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _NoAdmin implements AdminRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}
