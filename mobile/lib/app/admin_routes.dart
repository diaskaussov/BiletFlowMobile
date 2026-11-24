import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/di/injection.dart';
import '../features/account/account_page.dart';
import '../features/admin/presentation/admin_pages.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import 'attendee_routes.dart';
import 'routes.dart';

/// Админ платформы: P1–P2, события, пользователи, заказы.
GoRoute adminRoutes() => GoRoute(
      path: Routes.adminQueues,
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => AdminQueuesViewModel(sl())..load(),
        child: const AdminQueuesPage(),
      ),
      routes: [
        GoRoute(
          path: 'events',
          builder: (_, _) => ChangeNotifierProvider(
            create: (_) => AdminEventsViewModel(sl())..load(),
            child: const AdminEventsPage(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => ModerationViewModel(
                  eventId: int.tryParse(s.pathParameters['id'] ?? '') ?? -1,
                  get: sl(),
                  actions: sl(),
                )..load(),
                child: const ModerationPage(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'users',
          builder: (_, _) => ChangeNotifierProvider(
            create: (_) => AdminUsersViewModel(
              lists: sl(),
              actions: sl(),
              currentAdminId: sl<SessionController>().session?.userId ?? -1,
            )..load(),
            child: const AdminUsersPage(),
          ),
        ),
        GoRoute(
          path: 'orders',
          builder: (_, _) => ChangeNotifierProvider(
            create: (_) => AdminOrdersViewModel(sl())..load(),
            child: const AdminOrdersPage(),
          ),
        ),
        GoRoute(
          path: 'account',
          builder: (_, _) => const AccountPage(base: Routes.adminAccount),
          routes: [notificationsRoute()],
        ),
      ],
    );
