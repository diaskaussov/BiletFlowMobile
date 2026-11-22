import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/scan_result.dart';

/// Ответ `POST /api/checkin/scan` и `POST /api/checkin/tickets/{id}`
/// (схема `ScanResponse` в Swagger):
/// `{ verdict, valid, message, ticketCode, ticketId, orderId, eventId,
///    eventTitle, attendeeName, attendeeEmail, ticketType, status,
///    seatSection, seatRow, seatNumber, checkedInAt, checkedInBy, promo }`.
///
/// Время сервера (`checkedInAt`) приходит в UTC без пояса.
class ScanResponseModel {
  const ScanResponseModel({
    required this.valid,
    this.verdict,
    this.message,
    this.ticket = const ScannedTicket(),
    this.campaign,
  });

  /// Ошибка 4xx `{ "error": "..." }` — тоже ответ про билет.
  factory ScanResponseModel.rejected(String message) =>
      ScanResponseModel(valid: false, message: message);

  factory ScanResponseModel.fromJson(Map<String, dynamic> json) {
    final t = json.obj('ticket') ?? json;
    final e = json.obj('event') ?? t.obj('event');
    final promo = json.obj('promo');
    return ScanResponseModel(
      valid: json.boolean(['valid', 'success']) ?? false,
      verdict: json.str(['verdict']),
      message: json.str(['message', 'error', 'reason']),
      ticket: ScannedTicket(
        ticketId: t.str(['ticketId', 'id']),
        attendeeName: t.str(['attendeeName', 'holderName', 'name']) ?? json.str(['attendeeName']),
        ticketType: t.str(['ticketType', 'ticketTypeName', 'type']) ?? json.str(['ticketType']),
        seat: t.str(['seat', 'seatLabel']) ?? seatLabel(t),
        orderNumber: _order(t),
        status: t.str(['status', 'ticketStatus']),
        checkedInAt: t.date(['checkedInAt', 'firstCheckInAt', 'usedAt'], naiveIsUtc: true),
        checkedInBy: t.str(['checkedInBy', 'checkedInByName', 'scannedBy']),
        refundedAt: t.date(['refundedAt', 'cancelledAt'], naiveIsUtc: true),
        eventId: e?.integer(['id']) ?? t.integer(['eventId']),
        eventTitle: e?.str(['title', 'name']) ?? t.str(['eventTitle', 'eventName']),
        eventStartsAt: e?.date(['eventDate', 'startDate']) ?? t.date(['eventDate']),
        eventVenue: e?.str(['venueName']) ?? t.str(['venueName']),
      ),
      campaign: promo == null
          ? null
          : CampaignInfo(
              link: promo.str(['code']) ?? '',
              promoCode: promo.str(['code']),
              campaignName: promo.str(['campaignName', 'name']),
              discount: _discount(promo),
            ),
    );
  }

  final bool valid;

  /// `OK | ALREADY_USED | CANCELLED | REFUNDED | WRONG_EVENT | NOT_FOUND | PROMO_CODE`
  final String? verdict;
  final String? message;
  final ScannedTicket ticket;
  final CampaignInfo? campaign;

  /// «Sec B · Row 12 · Seat 7» из `seatSection / seatRow / seatNumber`.
  static String? seatLabel(Map<String, dynamic> t) {
    final parts = [
      if (t.str(['seatSection', 'section']) case final s?) 'Sec $s',
      if (t.str(['seatRow', 'row', 'rowNumber']) case final r?) 'Row $r',
      if (t.str(['seatNumber']) case final n?) 'Seat $n',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  static String? _order(Map<String, dynamic> t) {
    final named = t.str(['orderNumber', 'orderCode']);
    if (named != null) return named;
    final id = t.str(['orderId']);
    return id == null ? null : 'Order #$id';
  }

  static String? _discount(Map<String, dynamic> promo) {
    final value = promo.str(['discountValue']);
    if (value == null) return null;
    final clean = value.endsWith('.0')
        ? value.substring(0, value.length - 2)
        : value.endsWith('.00')
            ? value.substring(0, value.length - 3)
            : value;
    return promo.str(['discountType']) == 'PERCENTAGE' ? '$clean%' : '$clean ₸';
  }

  Verdict toVerdict() {
    if (valid) return Verdict.valid;

    // 1. Явный вердикт сервера.
    switch (verdict?.toUpperCase()) {
      case 'OK':
        return Verdict.valid;
      case 'ALREADY_USED':
        return Verdict.alreadyUsed;
      case 'REFUNDED':
        return Verdict.refunded;
      case 'CANCELLED':
        return Verdict.cancelled;
      case 'WRONG_EVENT':
        return Verdict.wrongEvent;
      case 'NOT_FOUND':
        return Verdict.unknownCode;
      case 'PROMO_CODE':
        return Verdict.campaignCode;
    }

    // 2. Статус билета.
    switch (ticket.status?.toUpperCase()) {
      case 'USED' || 'CHECKED_IN':
        return Verdict.alreadyUsed;
      case 'REFUNDED':
        return Verdict.refunded;
      case 'CANCELLED' || 'CANCELED' || 'VOID':
        return Verdict.cancelled;
    }

    // 3. Текст сообщения — запасной путь для ответов 4xx `{error}`.
    // Возврат, отмену и промо проверяем раньше «used»: «refunded and cannot
    // be used» — это возврат, а не повторный проход.
    final m = (message ?? '').toLowerCase();
    if (m.contains('refund')) return Verdict.refunded;
    if (m.contains('cancel') || m.contains('void')) return Verdict.cancelled;
    if (m.contains('promo') || m.contains('campaign')) return Verdict.campaignCode;
    if (m.contains('already') || m.contains('used') || m.contains('checked in')) {
      return Verdict.alreadyUsed;
    }
    if (m.contains('not found') ||
        m.contains('invalid') ||
        m.contains('unknown') ||
        m.contains('not recognized') ||
        m.contains('does not exist')) {
      return Verdict.unknownCode;
    }
    if (m.contains('event')) return Verdict.wrongEvent;
    return Verdict.unknownCode;
  }
}
