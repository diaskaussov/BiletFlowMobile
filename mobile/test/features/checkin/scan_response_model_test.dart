import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/checkin/data/models/scan_response_model.dart';
import 'package:mobile/features/checkin/domain/entities/scan_result.dart';

void main() {
  Verdict verdictOf(Map<String, dynamic> json) => ScanResponseModel.fromJson(json).toVerdict();
  Verdict rejected(String message) => ScanResponseModel.rejected(message).toVerdict();

  group('ScanResponseModel', () {
    test('documented valid response', () {
      final m = ScanResponseModel.fromJson({
        'valid': true,
        'message': 'Check-in successful',
        'attendeeName': 'John Doe',
        'ticketType': 'VIP',
      });
      expect(m.toVerdict(), Verdict.valid);
      expect(m.ticket.attendeeName, 'John Doe');
      expect(m.ticket.ticketType, 'VIP');
      expect(m.ticket.ticketId, isNull);
    });

    test('documented already-used response', () {
      expect(verdictOf({'valid': false, 'message': 'Ticket already used'}), Verdict.alreadyUsed);
    });

    test('status field wins over message', () {
      expect(verdictOf({'valid': false, 'status': 'REFUNDED', 'message': 'nope'}), Verdict.refunded);
      expect(verdictOf({'valid': false, 'status': 'CANCELLED'}), Verdict.cancelled);
      expect(verdictOf({'valid': false, 'status': 'USED'}), Verdict.alreadyUsed);
    });

    test('refund message is not mistaken for already used', () {
      expect(rejected('Ticket has been refunded and cannot be used'), Verdict.refunded);
      expect(rejected('Ticket was cancelled'), Verdict.cancelled);
    });

    test('unknown and wrong-event messages', () {
      expect(rejected('Ticket not found'), Verdict.unknownCode);
      expect(rejected('Invalid ticket code'), Verdict.unknownCode);
      expect(rejected('Ticket is for a different event'), Verdict.wrongEvent);
      expect(rejected('Something odd'), Verdict.unknownCode);
    });

    test('server-side promo refusal maps to campaign', () {
      expect(rejected('Promotional code cannot be used for admission'), Verdict.campaignCode);
    });

    test('reads optional fields when the backend adds them', () {
      final m = ScanResponseModel.fromJson({
        'valid': false,
        'message': 'Ticket already used',
        'ticketId': 42,
        'checkedInAt': '2026-11-22T19:11:00',
        'checkedInBy': 'T. Abenov',
        'section': 'B',
        'row': 12,
        'seatNumber': 7,
        'event': {'id': 3, 'title': 'Qazaq Jazz Nights'},
      });
      expect(m.ticket.ticketId, '42');
      expect(m.ticket.checkedInAt, DateTime(2026, 11, 22, 19, 11));
      expect(m.ticket.checkedInBy, 'T. Abenov');
      expect(m.ticket.seat, 'Sec B · Row 12 · Seat 7');
      expect(m.ticket.eventId, 3);
      expect(m.ticket.eventTitle, 'Qazaq Jazz Nights');
    });
  });
}
