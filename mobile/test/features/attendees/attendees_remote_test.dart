import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/attendees/data/attendees_remote_data_source.dart';
import 'package:mobile/features/attendees/domain/entities/attendee.dart';

void main() {
  test('tickets of one order are grouped into one attendee', () {
    final rows = [
      {'ticketId': 1, 'ticketCode': 'c67b8e0d-9530', 'orderId': 1, 'attendeeName': 'Test Scan',
       'attendeeEmail': 'a@b.kz', 'ticketType': 'General Admission', 'status': 'CHECKED_IN',
       'checkedInAt': '2026-11-22T11:11:58'},
      {'ticketId': 2, 'ticketCode': 'aa11bb22-0000', 'orderId': 1, 'attendeeName': 'Test Scan',
       'ticketType': 'General Admission', 'status': 'VALID'},
      {'ticketId': 3, 'orderId': 2, 'attendeeName': 'Other', 'ticketType': 'VIP', 'status': 'REFUNDED',
       'seatSection': 'B', 'seatRow': '12', 'seatNumber': '7'},
    ].map(AttendeeTicketRow.fromJson).toList();
    final list = groupByOrder(rows);
    expect(list, hasLength(2));
    expect(list.first.id, '1');
    expect(list.first.orderNumber, 'Order #1');
    expect(list.first.tickets.map((t) => t.status),
        [AttendeeTicketStatus.checkedIn, AttendeeTicketStatus.valid]);
    expect(list.first.notArrivedCount, 1);
    expect(list.first.tickets.first.label, 'C67B8E0D');
    expect(list.first.tickets.first.checkedInAt, DateTime.utc(2026, 11, 22, 11, 11, 58).toLocal());
    expect(list.last.tickets.single.seat, 'Sec B · Row 12 · Seat 7');
    expect(list.last.tickets.single.label, '#3');
  });
}
