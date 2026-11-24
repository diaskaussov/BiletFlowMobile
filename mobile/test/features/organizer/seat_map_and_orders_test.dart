import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/error/result.dart';
import 'package:mobile/features/organizer/domain/organizer_events_domain.dart';
import 'package:mobile/features/organizer/domain/organizer_operations_domain.dart';
import 'package:mobile/features/organizer/presentation/sales_pages.dart';
import 'package:mobile/shared/domain/entities/commerce.dart';

SeatInfo seat(int id, String section, String row, {int type = 1}) =>
    SeatInfo(id: id, section: section, row: row, number: '$id', status: SeatStatus.available, ticketTypeId: type);

const vip = TicketTypeInfo(id: 1, name: 'VIP', price: 25000, quantity: 30);
const standard = TicketTypeInfo(id: 2, name: 'Standard', price: 10000, quantity: 100);

void main() {
  group('SectionDraft', () {
    test('equal rows come back as a quick section', () {
      final seats = [for (var r = 1; r <= 3; r++) for (var n = 0; n < 4; n++) seat(r * 10 + n, 'A', '$r')];
      final s = SectionDraft.fromSeats(seats).single;
      expect(s.isManual, isFalse);
      expect((s.rows, s.seatsPerRow, s.seats, s.ticketTypeId), (3, 4, 12, 1));
    });

    test('uneven rows come back as manual rows', () {
      final seats = [seat(1, 'B', '1', type: 2), seat(2, 'B', '1', type: 2), seat(3, 'B', '2', type: 2)];
      final s = SectionDraft.fromSeats(seats).single;
      expect(s.isManual, isTrue);
      expect(s.rowSeats, [2, 1]);
      expect(s.seats, 3);
    });
  });

  test('seatOverflow reports a type with more seats than tickets', () {
    final over = seatOverflow([
      const SectionDraft(name: 'A', ticketTypeId: 1, rows: 4, seatsPerRow: 10),
      const SectionDraft(name: 'B', ticketTypeId: 2, rows: 5, seatsPerRow: 10),
    ], const [vip, standard]);
    expect(over, hasLength(1));
    expect((over.single.name, over.single.seats, over.single.quantity), ('VIP', 40, 30));
  });

  group('ManageSeatMap.save validation', () {
    // Репозиторий не нужен: все случаи отсекаются до запроса.
    final save = const ManageSeatMap(_NoRepo()).save;

    Future<String?> code(List<SectionDraft> s) async => switch (await save(1, s, types: const [vip, standard])) {
          Err(:final failure) => failure.code,
          Ok() => null,
        };

    test('manual row without a label is refused', () async {
      expect(
        await code([const SectionDraft(name: 'A', ticketTypeId: 1, manualRows: [RowDraft(label: ' ', seats: 5)])]),
        'rowInvalid',
      );
    });

    test('more seats than tickets is refused', () async {
      expect(await code([const SectionDraft(name: 'A', ticketTypeId: 1, rows: 4, seatsPerRow: 10)]), 'seatsOverTickets');
    });
  });

  test('groupOrders keeps one card per order and items line lists seats', () {
    const order = OrderInfo(
      id: 210,
      status: OrderStatus.completed,
      total: 50000,
      items: [OrderItemInfo(ticketTypeName: 'VIP', quantity: 2, unitPrice: 25000)],
    );
    final rows = [
      const AttendeeRow(ticket: TicketInfo(id: 1, code: 'a', status: TicketStatus.valid, ticketTypeName: 'VIP', seat: 'A-3-12'), order: order),
      const AttendeeRow(ticket: TicketInfo(id: 2, code: 'b', status: TicketStatus.valid, ticketTypeName: 'VIP', seat: 'A-3-13'), order: order),
    ];
    final g = groupOrders(rows).single;
    expect(g.tickets, hasLength(2));
    expect(g.refundable, isTrue);
    expect(g.itemsLine, '2× VIP · A-3-12, A-3-13');
  });
}

class _NoRepo implements OrganizerEventsRepository {
  const _NoRepo();

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value(const Err<Never>(ServerFailure('unused')));
}
