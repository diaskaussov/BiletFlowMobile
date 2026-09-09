import 'package:mobile/models/ticket.dart';

abstract interface class TicketRepository {
  /// Билет по коду из QR. null — кода нет в системе.
  Future<Ticket?> findByCode(String code);

  /// Отметить вход. Возвращает обновлённый билет.
  Future<Ticket> checkIn(String ticketId);

  /// Код относится к промо-кампании, а не к билету (§4.14).
  Future<bool> isCampaignCode(String code);
}