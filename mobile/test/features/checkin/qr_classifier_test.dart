import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/checkin/domain/services/qr_classifier.dart';

void main() {
  group('QrClassifier', () {
    test('UUID ticket code goes to the server', () {
      final p = QrClassifier.classify('  3f2b8c1e-9a4d-4e2f-8b7a-1c2d3e4f5a6b ');
      expect(p, isA<TicketPayload>());
      expect((p as TicketPayload).code, '3f2b8c1e-9a4d-4e2f-8b7a-1c2d3e4f5a6b');
    });

    test('ticket ID like TCK-8F42-19KD is a ticket', () {
      expect(QrClassifier.classify('TCK-8F42-19KD'), isA<TicketPayload>());
    });

    test('BiletFlow event link with promo token is a campaign QR (§4.14)', () {
      final p = QrClassifier.classify('https://biletflow.kz/e/alma-fest?promo=STUDENT-20');
      expect(p, isA<CampaignPayload>());
      expect((p as CampaignPayload).promoCode, 'STUDENT-20');
    });

    test('any BiletFlow https link is never treated as a ticket', () {
      expect(QrClassifier.classify('https://www.biletflow.kz/events/2'), isA<CampaignPayload>());
    });

    test('foreign link with a promo parameter is still a campaign QR', () {
      final p = QrClassifier.classify('https://bf.link/x?campaign=abc123');
      expect(p, isA<CampaignPayload>());
      expect((p as CampaignPayload).promoCode, 'abc123');
    });

    test('promo path segment is read as the campaign code', () {
      final p = QrClassifier.classify('https://go.example.kz/promo/BF-LAUNCH20');
      expect(p, isA<CampaignPayload>());
      expect((p as CampaignPayload).promoCode, 'BF-LAUNCH20');
    });

    test('unrelated website is foreign (B8)', () {
      expect(QrClassifier.classify('https://kaspi.kz/pay/123'), isA<ForeignPayload>());
    });

    test('empty, whitespace or prose is foreign', () {
      expect(QrClassifier.classify(''), isA<ForeignPayload>());
      expect(QrClassifier.classify('   '), isA<ForeignPayload>());
      expect(QrClassifier.classify('WIFI:S:Venue;T:WPA;P:secret pass;;'), isA<ForeignPayload>());
    });

    test('oversized payload is foreign', () {
      expect(QrClassifier.classify('A' * 200), isA<ForeignPayload>());
    });
  });
}
