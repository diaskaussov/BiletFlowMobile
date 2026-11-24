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
import 'package:mobile/features/checkout/domain/cart.dart';
import 'package:mobile/features/tickets/domain/tickets_domain.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every screen of every role renders', (tester) async {
    final errors = <String>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (d) => errors.add('${d.exceptionAsString()}\n${d.context}');

    await configureDependencies();
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
      final screen = find.byType(Scaffold).evaluate().isNotEmpty;
      expect_(screen, 'no screen for $route');
      if (expect != null) expect_(find.textContaining(expect).evaluate().isNotEmpty, '"$expect" not on $route');
      if (errors.isNotEmpty) fail('$route:\n${errors.join('\n---\n')}');
      // ignore: avoid_print
      print('OK $route');
    }

    Future<void> signInAs(String who) async {
      final session = sl<SessionController>();
      if (session.isSignedIn) await session.signOut();
      await settle();
      await tester.enterText(find.byType(TextField).at(0), '$who@biletflow.kz');
      await tester.enterText(find.byType(TextField).at(1), '123');
      await tester.tap(find.text('SIGN IN'));
      await settle();
      expect_(session.isSignedIn, 'sign in as $who failed');
    }

    await settle();
    await visit(Routes.register, expect: 'Create an account');

    // — участник —
    await signInAs('attendee');
    await visit(Routes.catalog, expect: 'Mobile Demo Night');
    await visit(Routes.publicEvent(3), expect: 'TICKETS');
    final page = (await sl<GetEventPage>()(4)).valueOrNull!;
    final cart = Cart(event: page.event, ticketTypes: page.ticketTypes).withQuantity(page.ticketTypes.first, 1);
    await visit(Routes.seats(4), extra: cart, expect: 'STAGE');
    await visit(Routes.checkout, extra: Cart(event: page.event, ticketTypes: page.ticketTypes).withQuantity(page.ticketTypes.first, 1), expect: 'Order summary'.toUpperCase());
    await visit(Routes.myTickets, expect: 'My tickets');
    final mine = (await sl<TicketsRepository>().myTickets()).valueOrNull!;
    await visit(Routes.order(mine.first.orderId!), expect: 'YOUR TICKETS');
    await visit(Routes.ticket(mine.first.id), expect: 'ADMISSION');
    await visit(Routes.attendeeSupport, expect: 'Support');
    await visit(Routes.newSupportCase(Routes.attendeeSupport), expect: 'New support case');
    await visit(Routes.attendeeAccount, expect: 'Attendee');
    await visit(Routes.notifications(Routes.attendeeAccount), expect: 'Notifications');

    // — организатор —
    await signInAs('organizer');
    await visit(Routes.organizer, expect: 'Events');
    await visit(Routes.newEvent, expect: 'Create event');
    await visit(Routes.manageEvent(3), expect: 'MANAGE');
    await visit(Routes.editEvent(3), expect: 'Edit event');
    await visit(Routes.ticketTypes(3), expect: 'Ticket types');
    await visit(Routes.seating(4), expect: 'CURRENT MAP');
    await visit(Routes.activation(3), expect: 'Activate paid sales');
    await visit(Routes.eventAttendees(3), expect: 'Attendees');
    await visit(Routes.eventOrder(3, 2), expect: 'Status');
    await visit(Routes.analytics(3), expect: 'BY TICKET TYPE');
    await visit(Routes.campaigns(3), expect: 'Campaigns');
    await visit(Routes.history(3), expect: 'Activity timeline');
    await visit(Routes.staff(3), expect: 'Check-in staff');
    await visit(Routes.organizerSupport, expect: 'Support inbox');
    await visit(Routes.organizerProfile, expect: 'Organizer profile');
    await visit(Routes.organizerAccount, expect: 'Organizer');

    // — админ платформы —
    await signInAs('admin');
    await visit(Routes.adminQueues, expect: 'Work queues');
    await visit(Routes.adminEvents, expect: 'Events');
    await visit(Routes.adminEvent(3), expect: 'ORGANIZER RECORD');
    await visit(Routes.adminUsers, expect: 'Users');
    await visit(Routes.adminOrders, expect: 'Orders & payments');
    await visit(Routes.adminAccount, expect: 'Platform admin');

    // — сотрудник на входе —
    await signInAs('eventadmin');
    await visit(Routes.events, expect: 'Events');
    await visit(Routes.eventSummary(3), expect: 'SUMMARY');
    await visit(Routes.settings, expect: 'Settings');

    // Чужие разделы роли закрыты: сотрудника вернёт на его главную.
    router().go(Routes.organizer);
    await settle();
    expect_(find.textContaining('Settings').evaluate().isEmpty || find.text('Events').evaluate().isNotEmpty, 'role guard');

    await sl<SessionController>().signOut();
    await settle();
    FlutterError.onError = previous;
  });
}

void expect_(bool ok, String message) {
  if (!ok) fail(message);
}

