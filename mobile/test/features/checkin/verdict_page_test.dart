import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/domain/usecases/session_usecases.dart';
import 'package:mobile/features/auth/presentation/controllers/session_controller.dart';
import 'package:mobile/features/checkin/domain/entities/scan_result.dart';
import 'package:mobile/features/checkin/domain/usecases/checkin_usecases.dart';
import 'package:mobile/features/checkin/presentation/pages/verdict_page.dart';
import 'package:mobile/features/checkin/presentation/view_models/verdict_view_model.dart';
import 'package:mobile/features/events/domain/entities/assigned_event.dart';
import 'package:mobile/features/events/domain/entities/event_stats.dart';
import 'package:mobile/features/events/presentation/controllers/active_event_controller.dart';
import 'package:mobile/features/settings/domain/entities/scanner_settings.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:mobile/features/settings/domain/usecases/settings_usecases.dart';
import 'package:mobile/features/settings/presentation/settings_controller.dart';
import 'package:provider/provider.dart';

import '../auth/sign_in_test.dart' show FakeAuthRepository;
import 'fakes.dart';

class _MemorySettings implements SettingsRepository {
  ScannerSettings s = const ScannerSettings(gate: 'Gate 3', soundOnResult: false);

  @override
  Future<ScannerSettings> load() async => s;

  @override
  Future<void> save(ScannerSettings settings) async => s = settings;
}

void main() {
  final scannedAt = DateTime(2026, 11, 22, 19, 43, 2);
  const ticket = ScannedTicket(
    ticketId: 'TCK-8F42-19KD',
    attendeeName: 'Dias Sagynbek',
    ticketType: 'VIP Balcony',
    seat: 'Sec B · Row 12 · Seat 7',
    orderNumber: 'ORD-20260831-0412',
    checkedInAt: null,
  );

  Future<void> pump(WidgetTester tester, ScanResult result) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final active = ActiveEventController()
      ..setAssigned([AssignedEvent(id: 1, title: 'Alma Fest 2026', startsAt: scannedAt)])
      ..select(AssignedEvent(id: 1, title: 'Alma Fest 2026', startsAt: scannedAt));
    active.updateStats(1, const EventStats(registered: 1043, checkedIn: 613, notCheckedIn: 430));
    final settingsRepo = _MemorySettings();
    final settings = SettingsController(load: LoadSettings(settingsRepo), save: SaveSettings(settingsRepo));
    await settings.load();
    final authRepo = FakeAuthRepository();
    final session = SessionController(restore: RestoreSession(authRepo), signOut: SignOut(authRepo));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: session),
          ChangeNotifierProvider(
            create: (_) => VerdictViewModel(
              result: result,
              undo: UndoCheckIn(checkin: FakeCheckinRepository(), log: memoryLog()),
              active: active,
            ),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: VerdictPage(result: result)),
      ),
    );
    await tester.pump();
  }

  ScanResult result(Verdict v, {ScannedTicket? t, CampaignInfo? c, DateTime? previous}) => ScanResult(
        verdict: v,
        code: 'TCK-8F42-19KD',
        eventId: 1,
        scannedAt: scannedAt,
        ticket: t,
        campaign: c,
        previousScanAt: previous,
      );

  final cases = <Verdict, (ScanResult, String, String)>{
    Verdict.valid: (result(Verdict.valid, t: ticket), 'VALID', 'SCAN NEXT TICKET'),
    Verdict.alreadyUsed: (
      result(Verdict.alreadyUsed, t: ticket),
      'ALREADY\nUSED',
      'OPEN ATTENDEE RECORD',
    ),
    Verdict.repeatScan: (
      result(Verdict.repeatScan, t: ticket, previous: scannedAt.subtract(const Duration(seconds: 3))),
      'SAME TICKET\nJUST NOW',
      'CONTINUE SCANNING',
    ),
    Verdict.refunded: (result(Verdict.refunded, t: ticket), 'REFUNDED\nTICKET', 'COPY TICKET ID'),
    Verdict.cancelled: (result(Verdict.cancelled, t: ticket), 'CANCELLED\nTICKET', 'COPY TICKET ID'),
    Verdict.unknownCode: (result(Verdict.unknownCode), 'CODE NOT\nRECOGNIZED', 'FIND BY NAME'),
    Verdict.wrongEvent: (
      result(Verdict.wrongEvent, t: const ScannedTicket(eventTitle: 'Qazaq Jazz Nights vol. 4')),
      'WRONG\nEVENT',
      'FIND BY NAME',
    ),
    Verdict.campaignCode: (
      result(Verdict.campaignCode, c: const CampaignInfo(link: 'https://biletflow.kz', promoCode: 'STUDENT-20')),
      'PROMOTIONAL\nCODE',
      'FIND BY NAME',
    ),
  };

  for (final MapEntry(key: verdict, value: (r, word, action)) in cases.entries) {
    testWidgets('$verdict renders word, status and action without overflow', (tester) async {
      await pump(tester, r);
      expect(find.text(word), findsOneWidget);
      expect(find.text(action), findsOneWidget);
      expect(
        find.text(verdict.admits ? '613 / 1 043 IN' : 'NOT ADMITTED'),
        findsOneWidget,
      );
      expect(find.text('GATE 3 · 19:43:02'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('B4 undo is offered only when the server returned a ticket id', (tester) async {
    await pump(tester, result(Verdict.valid, t: const ScannedTicket(attendeeName: 'X')));
    final button = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'UNDO THIS CHECK-IN'));
    expect(button.onPressed, isNull);
  });
}
