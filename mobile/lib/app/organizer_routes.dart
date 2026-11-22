import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/di/injection.dart';
import '../features/account/account_page.dart';
import '../features/organizer/presentation/campaigns_staff_pages.dart';
import '../features/organizer/presentation/dashboard_page.dart';
import '../features/organizer/presentation/event_editor_page.dart';
import '../features/organizer/presentation/event_hub_page.dart';
import '../features/organizer/presentation/insights_pages.dart';
import '../features/organizer/presentation/sales_pages.dart';
import '../features/organizer/presentation/seating_activation_pages.dart';
import '../features/organizer/presentation/ticket_types_page.dart';
import '../features/support/domain/support_domain.dart' show GetOrganizerInbox;
import '../features/support/presentation/support_pages.dart';
import '../shared/domain/entities/support.dart';
import 'attendee_routes.dart';
import 'routes.dart';

int _id(GoRouterState s, [String key = 'id']) => int.tryParse(s.pathParameters[key] ?? '') ?? -1;

/// Организатор: O1–O10, профиль, входящие поддержки.
GoRoute organizerRoutes() => GoRoute(
      path: Routes.organizer,
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => DashboardViewModel(sl())..load(),
        child: const OrganizerDashboardPage(),
      ),
      routes: [
        GoRoute(
          path: 'new',
          builder: (_, _) => ChangeNotifierProvider(
            create: (_) => EventEditorViewModel(get: sl(), save: sl())..load(),
            child: const EventEditorPage(),
          ),
        ),
        GoRoute(
          path: 'e/:id',
          builder: (_, s) => ChangeNotifierProvider(
            create: (_) => EventHubViewModel(eventId: _id(s), get: sl(), change: sl())..load(),
            child: const EventHubPage(),
          ),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => EventEditorViewModel(eventId: _id(s), get: sl(), save: sl())..load(),
                child: const EventEditorPage(),
              ),
            ),
            GoRoute(
              path: 'tickets',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => TicketTypesViewModel(eventId: _id(s), manage: sl(), overview: sl())..load(),
                child: const TicketTypesPage(),
              ),
            ),
            GoRoute(
              path: 'seating',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => SeatingViewModel(eventId: _id(s), seats: sl(), types: sl())..load(),
                child: const SeatingPage(),
              ),
            ),
            GoRoute(
              path: 'activate',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => ActivationViewModel(eventId: _id(s), activation: sl())..load(),
                child: const ActivationPage(),
              ),
            ),
            GoRoute(
              path: 'attendees',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => EventAttendeesViewModel(eventId: _id(s), get: sl())..load(),
                child: const EventAttendeesPage(),
              ),
            ),
            GoRoute(
              path: 'orders/:orderId',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => ManageOrderViewModel(
                  eventId: _id(s),
                  orderId: _id(s, 'orderId'),
                  attendees: sl(),
                  refund: sl(),
                )..load(),
                child: const ManageOrderPage(),
              ),
            ),
            GoRoute(
              path: 'analytics',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => AnalyticsViewModel(eventId: _id(s), event: sl(), sales: sl(), overview: sl())..load(),
                child: const AnalyticsPage(),
              ),
            ),
            GoRoute(
              path: 'campaigns',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => CampaignsViewModel(eventId: _id(s), manage: sl())..load(),
                child: const CampaignsPage(),
              ),
            ),
            GoRoute(
              path: 'history',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => TimelineViewModel(eventId: _id(s), get: sl())..load(),
                child: const TimelinePage(),
              ),
            ),
            GoRoute(
              path: 'staff',
              builder: (_, s) => ChangeNotifierProvider(
                create: (_) => StaffViewModel(eventId: _id(s), manage: sl(), overview: sl())..load(),
                child: const StaffPage(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'support',
          builder: (_, _) => ChangeNotifierProvider(
            create: (_) => SupportListViewModel(sl<GetOrganizerInbox>().call)..load(),
            child: const SupportListPage(base: Routes.organizerSupport),
          ),
          routes: supportRoutes(categories: const [
            CaseCategory.account,
            CaseCategory.activation,
            CaseCategory.payment,
            CaseCategory.technical,
          ]),
        ),
        GoRoute(
          path: 'profile',
          builder: (_, _) => ChangeNotifierProvider(
            create: (_) => OrganizerProfileViewModel(sl())..load(),
            child: const OrganizerProfilePage(),
          ),
        ),
        GoRoute(
          path: 'account',
          builder: (_, _) => const AccountPage(base: Routes.organizerAccount),
          routes: [notificationsRoute()],
        ),
      ],
    );
