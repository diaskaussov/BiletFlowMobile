import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/json_reader.dart';
import '../../checkin/data/models/scan_response_model.dart';
import '../domain/entities/attendee.dart';

/// Строка `AttendeeResponse` — один билет:
/// `{ ticketId, ticketCode, orderId, attendeeName, attendeeEmail, ticketType,
///    status, seatSection, seatRow, seatNumber, checkedInAt }`.
class AttendeeTicketRow {
  const AttendeeTicketRow({
    required this.orderKey,
    required this.attendeeName,
    required this.ticket,
    this.email,
    this.orderId,
  });

  factory AttendeeTicketRow.fromJson(Map<String, dynamic> j) {
    final ticketId = j.str(['ticketId', 'id']) ?? j.str(['ticketCode']) ?? '';
    final orderId = j.str(['orderId']);
    final email = j.str(['attendeeEmail', 'email']);
    return AttendeeTicketRow(
      // Участник в C1 = заказ: билеты одного заказа показываются вместе.
      orderKey: orderId ?? email ?? ticketId,
      orderId: orderId,
      attendeeName: j.str(['attendeeName', 'name']) ?? email ?? 'Attendee',
      email: email,
      ticket: AttendeeTicket(
        id: ticketId,
        code: j.str(['ticketCode']),
        type: j.str(['ticketType', 'ticketTypeName']) ?? 'Ticket',
        seat: ScanResponseModel.seatLabel(j),
        status: _status(j.str(['status'])),
        checkedInAt: j.date(['checkedInAt'], naiveIsUtc: true),
        checkedInBy: j.str(['checkedInBy']),
      ),
    );
  }

  final String orderKey;
  final String? orderId;
  final String attendeeName;
  final String? email;
  final AttendeeTicket ticket;

  static AttendeeTicketStatus _status(String? raw) => switch (raw?.toUpperCase()) {
        'CHECKED_IN' || 'USED' => AttendeeTicketStatus.checkedIn,
        'REFUNDED' => AttendeeTicketStatus.refunded,
        'CANCELLED' || 'CANCELED' || 'VOID' => AttendeeTicketStatus.cancelled,
        _ => AttendeeTicketStatus.valid,
      };
}

class AttendeesRemoteDataSource {
  const AttendeesRemoteDataSource(this._api);

  final ApiClient _api;

  /// `GET /api/checkin/events/{eventId}/attendees?q=` — поиск по имени,
  /// email или коду билета в пределах события.
  Future<List<AttendeeTicketRow>> list(int eventId, {String? query}) async {
    final data = await _api.get(
      '/api/checkin/events/$eventId/attendees',
      query: query == null || query.isEmpty ? null : {'q': query},
    );
    return jsonList(data).map(AttendeeTicketRow.fromJson).toList();
  }

  /// `POST /api/checkin/tickets/{ticketId}` — ручная отметка. Отказ
  /// (уже прошёл, возврат) — это ответ с valid=false, а не исключение.
  Future<ScanResponseModel> checkIn(String ticketId) async {
    try {
      final data = await _api.post('/api/checkin/tickets/${Uri.encodeComponent(ticketId)}');
      if (data is! Map) throw const FormatException('Check-in response is not an object');
      return ScanResponseModel.fromJson(data.cast<String, dynamic>());
    } on ApiException catch (e) {
      if (const {400, 404, 409, 410, 422}.contains(e.statusCode)) {
        return ScanResponseModel.rejected(e.message);
      }
      rethrow;
    }
  }

  Future<void> undo(String ticketId, String reason) async {
    await _api.post(
      '/api/checkin/undo/${Uri.encodeComponent(ticketId)}',
      body: {'reason': reason},
    );
  }
}

/// Билеты одного заказа → один участник. Порядок — как пришёл с сервера.
List<Attendee> groupByOrder(List<AttendeeTicketRow> rows) {
  final byOrder = <String, List<AttendeeTicketRow>>{};
  for (final r in rows) {
    byOrder.putIfAbsent(r.orderKey, () => []).add(r);
  }
  return [
    for (final MapEntry(:key, value: group) in byOrder.entries)
      Attendee(
        id: key,
        fullName: group.first.attendeeName,
        email: group.first.email,
        orderNumber: group.first.orderId == null ? null : 'Order #${group.first.orderId}',
        tickets: [for (final r in group) r.ticket],
      ),
  ];
}
