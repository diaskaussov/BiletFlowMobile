/// Итог одного сканирования — экраны B4–B10.
enum Verdict {
  valid, //        B4  VALID — вход записан
  alreadyUsed, //  B5  ALREADY USED
  repeatScan, //   B6  тот же код секунды спустя — не отказ
  refunded, //     B7  REFUNDED TICKET
  cancelled, //    B7' CANCELLED TICKET (§4.7, §4.8)
  unknownCode, //  B8  CODE NOT RECOGNIZED
  wrongEvent, //   B9  WRONG EVENT
  campaignCode; // B10 PROMOTIONAL CODE (§4.14)

  /// Человек проходит (или уже прошёл по этому же скану).
  bool get admits => this == Verdict.valid || this == Verdict.repeatScan;

  bool get isRejection => !admits;
}

/// Что сервер сообщил о билете. Поля, которых нет в ответе, — null:
/// контракт `/api/checkin/scan` пока возвращает только имя и тип билета.
class ScannedTicket {
  const ScannedTicket({
    this.ticketId,
    this.attendeeName,
    this.ticketType,
    this.seat,
    this.orderNumber,
    this.status,
    this.checkedInAt,
    this.checkedInBy,
    this.refundedAt,
    this.eventId,
    this.eventTitle,
    this.eventStartsAt,
    this.eventVenue,
  });

  final String? ticketId;
  final String? attendeeName;
  final String? ticketType;
  final String? seat;
  final String? orderNumber;
  final String? status;
  final DateTime? checkedInAt;
  final String? checkedInBy;
  final DateTime? refundedAt;
  final int? eventId;
  final String? eventTitle;
  final DateTime? eventStartsAt;
  final String? eventVenue;
}

/// Данные Campaign QR — ссылка на страницу события с промо-токеном.
class CampaignInfo {
  const CampaignInfo({required this.link, this.promoCode});

  final String link;
  final String? promoCode;
}

class ScanResult {
  const ScanResult({
    required this.verdict,
    required this.code,
    required this.eventId,
    required this.scannedAt,
    this.ticket,
    this.campaign,
    this.serverMessage,
    this.previousScanAt,
  });

  final Verdict verdict;

  /// Содержимое QR как прочитано.
  final String code;
  final int eventId;
  final DateTime scannedAt;
  final ScannedTicket? ticket;
  final CampaignInfo? campaign;
  final String? serverMessage;

  /// B6: когда был первый (засчитанный) скан этого кода.
  final DateTime? previousScanAt;

  /// ID для отмены прохода, если сервер его вернул.
  String? get ticketId => ticket?.ticketId;

  /// То, что показываем как «Ticket ID»: ID с сервера, иначе код из QR.
  String get displayTicketId => ticket?.ticketId ?? code;
}
