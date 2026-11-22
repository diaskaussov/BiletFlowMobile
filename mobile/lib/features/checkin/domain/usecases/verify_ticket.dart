import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/network_info.dart';
import '../entities/scan_log.dart';
import '../entities/scan_result.dart';
import '../repositories/checkin_repositories.dart';
import '../services/qr_classifier.dart';

/// UC4: проверить QR и записать вход.
///
/// Порядок важен:
/// 1. Campaign QR и чужие коды отсекаются на телефоне (§4.14, B8, B10).
/// 2. Повтор того же кода в пределах окна — B6, без запроса к серверу.
/// 3. Без сети проверка блокируется, а не откладывается (A5, §4.8).
/// 4. Остальное решает сервер (B4, B5, B7, B9).
class VerifyTicket {
  VerifyTicket({
    required this._checkin,
    required this._log,
    required this._network,
    required this._repeatWindow,
    DateTime Function()? clock,
  })  : _clock = clock ?? DateTime.now;

  final CheckinRepository _checkin;
  final ScanLogRepository _log;
  final NetworkInfo _network;
  final Duration _repeatWindow;
  final DateTime Function() _clock;

  Future<Result<ScanResult>> call({
    required String rawCode,
    required int eventId,
  }) async {
    final now = _clock();

    switch (QrClassifier.classify(rawCode)) {
      case CampaignPayload(:final link, :final promoCode):
        return _logged(ScanResult(
          verdict: Verdict.campaignCode,
          code: rawCode,
          eventId: eventId,
          scannedAt: now,
          campaign: CampaignInfo(link: link, promoCode: promoCode),
        ));

      case ForeignPayload():
        return _logged(ScanResult(
          verdict: Verdict.unknownCode,
          code: rawCode,
          eventId: eventId,
          scannedAt: now,
        ));

      case TicketPayload(:final code):
        final previous = _log.lastAdmission(eventId: eventId, code: code);
        if (previous != null && now.difference(previous.at) < _repeatWindow) {
          return Ok(ScanResult(
            verdict: Verdict.repeatScan,
            code: code,
            eventId: eventId,
            scannedAt: now,
            previousScanAt: previous.at,
            ticket: ScannedTicket(
              ticketId: previous.ticketId,
              attendeeName: previous.attendeeName,
              ticketType: previous.ticketType,
              checkedInAt: previous.at,
            ),
          ));
        }

        if (!await _network.isOnline) return const Err(NetworkFailure());

        final result = await _checkin.scan(code: code, eventId: eventId, at: now);
        if (result case Ok(:final value)) _log.add(ScanLogEntry.fromResult(value));
        return result;
    }
  }

  Ok<ScanResult> _logged(ScanResult r) {
    _log.add(ScanLogEntry.fromResult(r));
    return Ok(r);
  }
}
