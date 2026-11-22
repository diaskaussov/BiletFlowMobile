import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/scan_result.dart';

/// Ответ `POST /api/checkin/scan`.
///
/// По API_GUIDE гарантированы только `valid`, `message`, `attendeeName`,
/// `ticketType`. Остальные поля читаем, если бэкенд их добавит.
class ScanResponseModel {
  const ScanResponseModel({
    required this.valid,
    this.message,
    this.ticket = const ScannedTicket(),
  });

  /// Ошибка 4xx `{ "error": "..." }` — тоже ответ про билет.
  factory ScanResponseModel.rejected(String message) =>
      ScanResponseModel(valid: false, message: message);

  factory ScanResponseModel.fromJson(Map<String, dynamic> json) {
    final t = json.obj('ticket') ?? json;
    final e = json.obj('event') ?? t.obj('event');
    return ScanResponseModel(
      valid: json.boolean(['valid', 'success']) ?? false,
      message: json.str(['message', 'error', 'reason']),
      ticket: ScannedTicket(
        ticketId: t.str(['ticketId', 'id']),
        attendeeName: t.str(['attendeeName', 'holderName', 'name']) ?? json.str(['attendeeName']),
        ticketType: t.str(['ticketType', 'ticketTypeName', 'type']) ?? json.str(['ticketType']),
        seat: t.str(['seat', 'seatLabel']) ?? _seat(t),
        orderNumber: t.str(['orderNumber', 'orderCode', 'orderId']),
        status: t.str(['status', 'ticketStatus']),
        checkedInAt: t.date(['checkedInAt', 'firstCheckInAt', 'usedAt']),
        checkedInBy: t.str(['checkedInBy', 'checkedInByName', 'scannedBy']),
        refundedAt: t.date(['refundedAt', 'cancelledAt']),
        eventId: e?.integer(['id']) ?? t.integer(['eventId']),
        eventTitle: e?.str(['title', 'name']) ?? t.str(['eventTitle', 'eventName']),
        eventStartsAt: e?.date(['eventDate', 'startDate']) ?? t.date(['eventDate']),
        eventVenue: e?.str(['venueName']) ?? t.str(['venueName']),
      ),
    );
  }

  final bool valid;
  final String? message;
  final ScannedTicket ticket;

  static String? _seat(Map<String, dynamic> t) {
    final parts = [
      if (t.str(['section']) case final s?) 'Sec $s',
      if (t.str(['row', 'rowNumber']) case final r?) 'Row $r',
      if (t.str(['seatNumber']) case final n?) 'Seat $n',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// Сопоставление ответа с вердиктом. Сначала структурный `status`,
  /// иначе — ключевые слова в `message`, потому что других признаков
  /// отказа контракт сейчас не даёт.
  Verdict toVerdict() {
    if (valid) return Verdict.valid;

    switch (ticket.status?.toUpperCase()) {
      case 'USED' || 'CHECKED_IN':
        return Verdict.alreadyUsed;
      case 'REFUNDED':
        return Verdict.refunded;
      case 'CANCELLED' || 'CANCELED' || 'VOID':
        return Verdict.cancelled;
    }

    // Возврат, отмену и промо проверяем раньше «used»: «refunded and cannot be
    // used» — это возврат, а не повторный проход.
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
