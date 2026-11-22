import 'scan_result.dart';

/// Запись журнала смены на этом устройстве. Хранится только в памяти:
/// офлайн-проверка вне MVP, на телефоне ничего не копится (A5).
class ScanLogEntry {
  const ScanLogEntry({
    required this.eventId,
    required this.at,
    required this.verdict,
    required this.code,
    this.attendeeName,
    this.ticketType,
    this.ticketId,
    this.reversedAt,
  });

  factory ScanLogEntry.fromResult(ScanResult r) => ScanLogEntry(
        eventId: r.eventId,
        at: r.scannedAt,
        verdict: r.verdict,
        code: r.code,
        attendeeName: r.ticket?.attendeeName,
        ticketType: r.ticket?.ticketType,
        ticketId: r.ticket?.ticketId,
      );

  final int eventId;
  final DateTime at;
  final Verdict verdict;
  final String code;
  final String? attendeeName;
  final String? ticketType;
  final String? ticketId;
  final DateTime? reversedAt;

  bool get isReversed => reversedAt != null;

  ScanLogEntry reversed(DateTime at) => ScanLogEntry(
        eventId: eventId,
        at: this.at,
        verdict: verdict,
        code: code,
        attendeeName: attendeeName,
        ticketType: ticketType,
        ticketId: ticketId,
        reversedAt: at,
      );
}

/// Сводка журнала для A4: то, чего нет в `/checkin/stats`.
class ScanLogSummary {
  const ScanLogSummary({
    required this.rejected,
    required this.reversed,
    required this.voided,
    required this.admittedByType,
    required this.recent,
  });

  factory ScanLogSummary.of(List<ScanLogEntry> newestFirst, {int recentCount = 5}) {
    var rejected = 0, reversed = 0, voided = 0;
    final byType = <String, int>{};
    for (final e in newestFirst) {
      if (e.verdict.isRejection) rejected++;
      if (e.isReversed) reversed++;
      if (e.verdict == Verdict.refunded || e.verdict == Verdict.cancelled) voided++;
      if (e.verdict == Verdict.valid && !e.isReversed) {
        final type = e.ticketType ?? 'Other';
        byType[type] = (byType[type] ?? 0) + 1;
      }
    }
    return ScanLogSummary(
      rejected: rejected,
      reversed: reversed,
      voided: voided,
      admittedByType: byType,
      recent: newestFirst.take(recentCount).toList(),
    );
  }

  final int rejected;
  final int reversed;
  final int voided;
  final Map<String, int> admittedByType;
  final List<ScanLogEntry> recent;
}
