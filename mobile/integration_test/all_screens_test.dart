// Прогон всех экранов всех ролей против живого бэкенда:
//   flutter test integration_test/all_screens_test.dart -d <simulator>
// Нужен запущенный бэкенд с демо-аккаунтами (password 123) и событием 3/4,
// созданными при разработке. Тест падает на любом исключении или
// переполнении вёрстки.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/routes.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/auth/presentation/controllers/session_controller.dart';
import 'package:mobile/features/catalog/domain/catalog_domain.dart';
import 'package:mobile/features/settings/domain/entities/appearance.dart';
import 'package:mobile/features/settings/presentation/appearance_controller.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/checkout/domain/cart.dart';
import 'package:mobile/features/tickets/domain/tickets_domain.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final language in [AppLanguage.ru, AppLanguage.en]) {
    testWidgets('every screen of every role renders · ${language.name}', (tester) async {
      final errors = <String>[];
      final previous = FlutterError.onError;
      _restore = previous;
      FlutterError.onError = (d) => errors.add('${d.exceptionAsString()}\n${d.context}');

      addTearDown(() => FlutterError.onError = previous);
      await configureDependencies();
      await sl<AppearanceController>().setLanguage(language);
      final l = lookupAppLocalizations(Locale(language.name));
      await tester.pumpWidget(const BiletFlowApp());

      Future<void> settle() async {
        for (var i = 0; i < 40; i++) {
          await tester.pump(const Duration(milliseconds: 150));
          if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
        }
        await tester.pump(const Duration(milliseconds: 300));
      }

      GoRouter router() => GoRouter.of(tester.element(find.byType(Scaffold).first));

      Future<void> visit(String route, {Object? extra, String? expect}) async {
        router().go(route, extra: extra);
        await settle();
        expect_(find.byType(Scaffold).evaluate().isNotEmpty, 'no screen for $route');
        if (expect != null) expect_(find.textContaining(expect).evaluate().isNotEmpty, '"$expect" not on $route');
        if (errors.isNotEmpty) {
          FlutterError.onError = previous;
          fail('$route:\n${errors.join('\n---\n')}');
        }
        // ignore: avoid_print
        print('OK ${language.name} $route');
      }

      Future<void> signInAs(String who) async {
        final session = sl<SessionController>();
        if (session.isSignedIn) await session.signOut();
        await settle();
        router().go(Routes.signIn);
        await settle();
        await tester.enterText(find.byType(TextField).at(0), '$who@biletflow.kz');
        await tester.enterText(find.byType(TextField).at(1), '123');
        // Кнопку может закрыть клавиатура — отправляем форму «Готово» с поля пароля.
        await tester.testTextInput.receiveAction(TextInputAction.done);
        for (var i = 0; i < 40 && !session.isSignedIn; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        await settle();
        expect_(session.isSignedIn, 'sign in as $who failed');
      }

      await settle();
      await visit(Routes.register, expect: l.registerTitle);

      // — участник —
      await signInAs('attendee');
      await visit(Routes.catalog, expect: 'Mobile Demo Night');
      await visit(Routes.publicEvent(3), expect: l.secTickets);
      final page = (await sl<GetEventPage>()(4)).valueOrNull!;
      Cart cart() => Cart(event: page.event, ticketTypes: page.ticketTypes).withQuantity(page.ticketTypes.first, 1);
      await visit(Routes.seats(4), extra: cart(), expect: l.stage);
      await visit(Routes.checkout, extra: cart(), expect: l.orderSummary);
      await visit(Routes.myTickets, expect: l.myTickets);
      final mine = (await sl<TicketsRepository>().myTickets()).valueOrNull!;
      await visit(Routes.order(mine.first.orderId!), expect: l.yourTickets);
      await visit(Routes.ticket(mine.first.id), expect: l.admissionTicket);
      await visit(Routes.attendeeSupport, expect: l.navSupport);
      await visit(Routes.newSupportCase(Routes.attendeeSupport), expect: l.newCase);
      await visit(Routes.attendeeAccount, expect: l.roleAttendee);
      await visit(Routes.notifications(Routes.attendeeAccount), expect: l.notifications);

      // — организатор —
      await signInAs('organizer');
      await visit(Routes.organizer, expect: l.myEvents);
      await visit(Routes.newEvent, expect: l.createEventTitle);
      await visit(Routes.manageEvent(3), expect: l.kpiSold);
      await visit(Routes.editEvent(3), expect: l.editEventTitle);
      await visit(Routes.ticketTypes(3), expect: l.addTicketType);
      await visit(Routes.seating(4), expect: l.sectionsTitle);
      await visit(Routes.activation(3), expect: l.chkPaidType);
      await visit(Routes.eventAttendees(3), expect: l.secOrders);
      await visit(Routes.eventOrder(3, 2), expect: l.statusLabel);
      await visit(Routes.analytics(3), expect: l.kpiAttendance);
      await visit(Routes.campaigns(3), expect: l.createCampaign);
      await visit(Routes.history(3), expect: l.secHistory);
      await visit(Routes.staff(3), expect: l.addEventAdmin);
      await visit(Routes.organizerSupport, expect: l.supportInbox);
      await visit(Routes.organizerNotifications, expect: l.notifications);
      await visit(Routes.organizerProfile, expect: l.orgProfileTitle);
      await visit(Routes.organizerAccount, expect: l.roleOrganizer);

      // — админ платформы —
      await signInAs('admin');
      await visit(Routes.adminQueues, expect: l.workQueues);
      await visit(Routes.adminEvents, expect: l.navEvents);
      await visit(Routes.adminEvent(3), expect: l.organizerRecord);
      await visit(Routes.adminUsers, expect: l.navUsers);
      await visit(Routes.adminOrders, expect: l.navOrders);
      await visit(Routes.adminAccount, expect: l.rolePlatformAdmin);

      // — сотрудник на входе —
      await signInAs('eventadmin');
      await visit(Routes.events, expect: l.myEvents);
      await visit(Routes.settings, expect: l.settings);
      await visit(Routes.search, expect: l.navGuests);
      await visit(Routes.stats, expect: l.navStats);
      await visit(Routes.offline, expect: l.offlineBody);

      // Чужие разделы роли закрыты: сотрудника вернёт на его главную.
      router().go(Routes.organizer);
      await settle();
      expect_(find.text(l.supportInbox).evaluate().isEmpty, 'role guard');

      await sl<SessionController>().signOut();
      await settle();
      await sl.reset();
      FlutterError.onError = previous;
    });
  }
}

void Function(FlutterErrorDetails)? _restore;

void expect_(bool ok, String message) {
  if (ok) return;
  if (_restore != null) FlutterError.onError = _restore;
  fail(message);
}
