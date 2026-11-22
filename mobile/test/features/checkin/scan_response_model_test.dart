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
      expect(m.ticket.checkedInAt, DateTime.utc(2026, 11, 22, 19, 11).toLocal());
      expect(m.ticket.checkedInBy, 'T. Abenov');
      expect(m.ticket.seat, 'Sec B · Row 12 · Seat 7');
      expect(m.ticket.eventId, 3);
      expect(m.ticket.eventTitle, 'Qazaq Jazz Nights');
    });

    test('real backend: verdict enum and UTC timestamps', () {
      final m = ScanResponseModel.fromJson({
        'attendeeName': 'Test Scan', 'checkedInAt': '2026-11-22T11:11:58.115296',
        'checkedInBy': 'Demo EventAdmin', 'eventId': 1, 'eventTitle': 'BiletFlow Demo Concert',
        'message': 'Ticket already used', 'orderId': 1, 'status': 'CHECKED_IN',
        'ticketCode': 'c67b8e0d', 'ticketId': 1, 'ticketType': 'General Admission',
        'valid': false, 'verdict': 'ALREADY_USED',
      });
      expect(m.toVerdict(), Verdict.alreadyUsed);
      expect(m.ticket.ticketId, '1');
      expect(m.ticket.orderNumber, 'Order #1');
      expect(m.ticket.checkedInAt, DateTime.utc(2026, 11, 22, 11, 11, 58, 115, 296).toLocal());
    });

    test('real backend verdicts', () {
      for (final (raw, v) in [
        ('OK', Verdict.valid), ('WRONG_EVENT', Verdict.wrongEvent), ('NOT_FOUND', Verdict.unknownCode),
        ('REFUNDED', Verdict.refunded), ('CANCELLED', Verdict.cancelled), ('PROMO_CODE', Verdict.campaignCode),
      ]) {
        expect(verdictOf({'valid': raw == 'OK', 'verdict': raw, 'message': 'x'}), v, reason: raw);
      }
    });

    test('promo info from the server', () {
      final m = ScanResponseModel.fromJson({
        'valid': false, 'verdict': 'PROMO_CODE', 'message': 'This is a promo code, not a ticket',
        'promo': {'code': 'BF-LAUNCH20', 'campaignName': 'Launch Discount', 'discountType': 'PERCENTAGE', 'discountValue': 20.00},
      });
      expect(m.campaign?.promoCode, 'BF-LAUNCH20');
      expect(m.campaign?.campaignName, 'Launch Discount');
      expect(m.campaign?.discount, '20%');
    });
  });
}
