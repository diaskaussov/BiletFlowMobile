import 'package:mobile/models/ticket.dart';

enum Verdict {
  valid,        // B4  VALID
  alreadyUsed,  // B5  ALREADY USED
  repeatScan,   // B6  повтор в пределах секунд, не отказ
  refunded,     // B7  REFUNDED TICKET
  unknownCode,  // B8  CODE NOT RECOGNIZED
  wrongEvent,   // B9  WRONG EVENT
  campaignCode, // B10 PROMOTIONAL CODE
}

class ScanOutcome {
  const ScanOutcome({required this.verdict, required this.at, this.ticket});

  final Verdict verdict;
  final DateTime at;

  /// null для unknownCode и campaignCode — билета за кодом не стоит.
  final Ticket? ticket;
}