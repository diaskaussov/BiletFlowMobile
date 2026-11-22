import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/di/injection.dart';
import '../features/account/account_page.dart';
import '../features/catalog/domain/catalog_domain.dart' show GetEvent;
import '../features/catalog/presentation/catalog_page.dart';
import '../features/catalog/presentation/event_page.dart';
import '../features/catalog/presentation/promo_scan_page.dart';
import '../features/checkout/domain/cart.dart';
import '../features/checkout/presentation/checkout_page.dart';
import '../features/checkout/presentation/seat_map_page.dart';
import '../features/notifications/presentation/notifications_page.dart';
import '../features/support/domain/support_domain.dart' show GetMyCases;
import '../features/support/presentation/support_pages.dart';
import '../features/tickets/presentation/my_tickets_page.dart';
import '../features/tickets/presentation/order_page.dart';
import '../features/tickets/presentation/ticket_page.dart';
import '../shared/domain/entities/support.dart';
import 'routes.dart';

int _id(GoRouterState s, [String key = 'id']) => int.tryParse(s.pathParameters[key] ?? '') ?? -1;

int? _q(GoRouterState s, String key) => int.tryParse(s.uri.queryParameters[key] ?? '');

/// Маршруты поддержки — одинаковые для участника и организатора.
List<RouteBase> supportRoutes({required List<CaseCategory> categories}) => [
      GoRoute(
        path: 'new',
        builder: (_, s) => ChangeNotifierProvider(
          create: (_) => NewCaseViewModel(
            sl(),
            eventId: _q(s, 'eventId'),
            orderId: _q(s, 'orderId'),
            about: s.uri.queryParameters['about'],
            category: categories.first,
          ),
          child: NewCasePage(categories: categories),
        ),
      ),
      GoRoute(
        path: ':id',
        builder: (_, s) => ChangeNotifierProvider(
          create: (_) => SupportThreadViewModel(
            caseId: _id(s),
            info: s.extra is SupportCaseInfo ? s.extra! as SupportCaseInfo : null,
            messages: sl(),
            reply: sl(),
            status: sl(),
          )..load(),
          child: const SupportThreadPage(),
        ),
      ),
    ];

GoRoute notificationsRoute() => GoRoute(
      path: 'notifications',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => NotificationsViewModel(sl(), sl())..load(),
        child: const NotificationsPage(),
      ),
    );

/// Участник: W1–W9.
GoRoute attendeeRoutes() => GoRoute(
      path: Routes.catalog,
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => CatalogViewModel(sl())..load(),
        child: const CatalogPage(),
      ),
      routes: [
        GoRoute(path: 'scan-promo', builder: (_, _) => const PromoScanPage()),
        GoRoute(
          path: 'e/:id',
          builder: (_, s) => ChangeNotifierProvider(
            create: (_) => EventPageViewModel(
              eventId: _id(s),
              getPage: sl(),
              applyPromo: sl(),
              calendarFile: () => sl<GetEvent>().calendar(_id(s)),
              initialPromo: s.uri.queryParameters['promo'],
            )..load(),
            child: const EventPage(),
          ),
          routes: [
            GoRoute(
              path: 'seats',
              redirect: (_, s) => s.extra is Cart ? null : Routes.publicEvent(_id(s)),
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => SeatMapViewModel(cart: s.extra! as Cart, load: sl(), hold: sl())..load(),
                child: const SeatMapPage(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'checkout',
          redirect: (_, s) => s.extra is Cart ? null : Routes.catalog,
          builder: (_, s) => ChangeNotifierProvider(
            create: (_) => CheckoutViewModel(cart: s.extra! as Cart, placeOrder: sl(), release: sl()),
            child: const CheckoutPage(),
          ),
        ),
        GoRoute(
          path: 'orders/:id',
          builder: (_, s) => ChangeNotifierProvider(
            create: (_) => OrderViewModel(orderId: _id(s), get: sl(), cancel: sl(), files: sl(), event: sl())..load(),
            child: const OrderPage(),
          ),
        ),
        GoRoute(
          path: 'tickets',
          builder: (_, _) => ChangeNotifierProvider(
            create: (_) => MyTicketsViewModel(sl())..load(),
            child: const MyTicketsPage(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => TicketViewModel(ticketId: _id(s), get: sl(), files: sl())..load(),
                child: const TicketPage(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'support',
          builder: (_, _) => ChangeNotifierProvider(
            create: (_) => SupportListViewModel(sl<GetMyCases>().call)..load(),
            child: const SupportListPage(base: Routes.attendeeSupport),
          ),
          routes: supportRoutes(categories: const [
            CaseCategory.ticketDelivery,
            CaseCategory.payment,
            CaseCategory.refund,
            CaseCategory.seating,
            CaseCategory.eventInfo,
            CaseCategory.checkIn,
            CaseCategory.account,
            CaseCategory.technical,
          ]),
        ),
        GoRoute(
          path: 'account',
          builder: (_, _) => const AccountPage(base: Routes.attendeeAccount),
          routes: [notificationsRoute()],
        ),
      ],
    );
