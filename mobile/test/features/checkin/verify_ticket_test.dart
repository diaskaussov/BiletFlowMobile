import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/error/result.dart';
import 'package:mobile/features/checkin/domain/entities/scan_result.dart';
import 'package:mobile/features/checkin/domain/repositories/checkin_repositories.dart';
import 'package:mobile/features/checkin/domain/usecases/checkin_usecases.dart';
import 'package:mobile/features/checkin/domain/usecases/verify_ticket.dart';

import 'fakes.dart';

void main() {
  late FakeCheckinRepository server;
  late ScanLogRepository log;
  late FakeNetwork network;
  late Clock clock;
  late VerifyTicket verify;

  const eventId = 1;
  const window = Duration(seconds: 10);

  setUp(() {
    server = FakeCheckinRepository();
    log = memoryLog();
    network = FakeNetwork();
    clock = Clock();
    verify = VerifyTicket(
      checkin: server,
      log: log,
      network: network,
      repeatWindow: window,
      clock: clock.call,
    );
  });

  Future<ScanResult> ok(String code) async {
    final r = await verify(rawCode: code, eventId: eventId);
    return (r as Ok<ScanResult>).value;
  }

  test('B4: valid ticket is admitted and logged', () async {
    server.verdicts['abc'] = Verdict.valid;
    final r = await ok('abc');
    expect(r.verdict, Verdict.valid);
    expect(r.ticketId, 'T-abc');
    expect(log.entries(eventId).single.verdict, Verdict.valid);
  });

  test('B10: campaign QR is refused without asking the server (§4.14)', () async {
    final r = await ok('https://biletflow.kz/e/alma?promo=STUDENT-20');
    expect(r.verdict, Verdict.campaignCode);
    expect(r.campaign?.promoCode, 'STUDENT-20');
    expect(server.scanned, isEmpty);
    expect(r.verdict.admits, isFalse);
  });

  test('B10: campaign QR is refused even offline', () async {
    network.online = false;
    final r = await ok('https://biletflow.kz/e/alma?promo=X');
    expect(r.verdict, Verdict.campaignCode);
  });

  test('B8: foreign QR is refused locally', () async {
    final r = await ok('https://example.com/menu');
    expect(r.verdict, Verdict.unknownCode);
    expect(server.scanned, isEmpty);
  });

  test('B6: same valid code inside the window is a repeat, not a second check-in', () async {
    server.verdicts['abc'] = Verdict.valid;
    await ok('abc');
    clock.advance(const Duration(seconds: 3));
    final r = await ok('abc');
    expect(r.verdict, Verdict.repeatScan);
    expect(r.previousScanAt, DateTime(2026, 11, 22, 19, 43, 2));
    expect(server.scanned, ['abc']);
    expect(r.verdict.admits, isTrue);
  });

  test('after the window the server decides again (B5)', () async {
    server.verdicts['abc'] = Verdict.valid;
    await ok('abc');
    clock.advance(window + const Duration(seconds: 1));
    server.verdicts['abc'] = Verdict.alreadyUsed;
    final r = await ok('abc');
    expect(r.verdict, Verdict.alreadyUsed);
    expect(server.scanned, ['abc', 'abc']);
  });

  test('a rejected code is not turned into a repeat', () async {
    server.verdicts['bad'] = Verdict.refunded;
    await ok('bad');
    final r = await ok('bad');
    expect(r.verdict, Verdict.refunded);
    expect(server.scanned.length, 2);
  });

  test('after a reversal the same ticket is checked again, not a repeat', () async {
    server.verdicts['abc'] = Verdict.valid;
    await ok('abc');
    final undo = UndoCheckIn(checkin: server, log: log, clock: clock.call);
    await undo(ticketId: 'T-abc', reason: 'Wrong person');
    clock.advance(const Duration(seconds: 2));
    final r = await ok('abc');
    expect(r.verdict, Verdict.valid);
    expect(server.scanned.length, 2);
  });

  test('A5: offline blocks verification instead of queueing it', () async {
    network.online = false;
    final r = await verify(rawCode: 'abc', eventId: eventId);
    expect(r.failureOrNull, isA<NetworkFailure>());
    expect(server.scanned, isEmpty);
    expect(log.entries(eventId), isEmpty);
  });

  test('server failure is passed through and nothing is logged', () async {
    server.failNext = const ServerFailure('boom', statusCode: 500);
    final r = await verify(rawCode: 'abc', eventId: eventId);
    expect(r.failureOrNull, isA<ServerFailure>());
    expect(log.entries(eventId), isEmpty);
  });

  group('UndoCheckIn', () {
    test('requires a ticket id', () async {
      final undo = UndoCheckIn(checkin: server, log: log);
      final r = await undo(ticketId: null, reason: 'x');
      expect(r.failureOrNull, isA<ValidationFailure>());
    });

    test('requires a reason', () async {
      final undo = UndoCheckIn(checkin: server, log: log);
      final r = await undo(ticketId: 'T-1', reason: '  ');
      expect(r.failureOrNull, isA<ValidationFailure>());
      expect(server.undone, isEmpty);
    });

    test('marks the log entry as reversed', () async {
      server.verdicts['abc'] = Verdict.valid;
      await ok('abc');
      final undo = UndoCheckIn(checkin: server, log: log, clock: clock.call);
      final r = await undo(ticketId: 'T-abc', reason: 'Scanned the wrong person');
      expect(r, isA<Ok<void>>());
      expect(server.undone, ['T-abc']);
      expect(GetScanLog(log)(eventId).reversed, 1);
    });
  });
}
