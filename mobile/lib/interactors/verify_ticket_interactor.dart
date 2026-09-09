import 'package:mobile/core/result.dart';
import 'package:mobile/models/scan_outcome.dart';
import 'package:mobile/models/ticket.dart';
import 'package:mobile/repositories/ticket_repository.dart';

class VerifyTicketInteractor {
  VerifyTicketInteractor({
    required TicketRepository tickets,
    required Future<bool> Function() isOnline,
  }) : _tickets = tickets,
     _isOnline = isOnline;

  final TicketRepository _tickets;
  final Future<bool> Function() _isOnline;

  static const _repeatWindow = Duration(seconds: 3);

  String? _lastCode;
  DateTime? _lastAt;

  Future<Result<ScanOutcome>> call({
    required String code,
    required String eventId,
  }) async {
    final now = DateTime.now();

    // A5: в офлайне проверка блокируется, а не откладывается.
    if (!await _isOnline()) {
      return const Err('Нет связи. Проверка недоступна.', isOffline: true);
    }

    // B6: то же самое срабатывание секундой позже — один вход, не отказ.
    if (_lastCode == code &&
        _lastAt != null &&
        now.difference(_lastAt!) < _repeatWindow) {
      return Ok(ScanOutcome(verdict: Verdict.repeatScan, at: now));
    }
    _lastCode = code;
    _lastAt = now;

    try {
      // B10: промо-код — отдельный случай, не отказ по билету.
      if (await _tickets.isCampaignCode(code)) {
        return Ok(ScanOutcome(verdict: Verdict.campaignCode, at: now));
      }

      final ticket = await _tickets.findByCode(code);

      // B8: кода нет в системе.
      if (ticket == null) {
        return Ok(ScanOutcome(verdict: Verdict.unknownCode, at: now));
      }

      // B9: билет настоящий, но на другое мероприятие.
      if (ticket.eventId != eventId) {
        return Ok(ScanOutcome(
          verdict: Verdict.wrongEvent, at: now, ticket: ticket));
      }

      // B7: возвращён или аннулирован.
      if (ticket.isSpent) {
        return Ok(ScanOutcome(
          verdict: Verdict.refunded, at: now, ticket: ticket));
      }

      // B5: уже проходил.
      if (ticket.status == TicketStatus.used) {
        return Ok(ScanOutcome(
          verdict: Verdict.alreadyUsed, at: now, ticket: ticket));
      }

      // B4: пропускаем.
      final admitted = await _tickets.checkIn(ticket.id);
      return Ok(ScanOutcome(
        verdict: Verdict.valid, at: now, ticket: admitted));
    } on Exception catch (e) {
      return Err('Не удалось проверить билет: $e');
    }
  }
}