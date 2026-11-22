import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/di/injection.dart';
import '../core/widgets/state_views.dart';
import '../features/attendees/presentation/pages/attendee_page.dart';
import '../features/attendees/presentation/pages/search_page.dart';
import '../features/attendees/presentation/view_models/attendee_view_model.dart';
import '../features/attendees/presentation/view_models/search_view_model.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/sign_in_page.dart';
import '../features/auth/presentation/view_models/sign_in_view_model.dart';
import '../features/checkin/domain/entities/scan_result.dart';
import '../features/checkin/presentation/pages/scanner_page.dart';
import '../features/checkin/presentation/pages/verdict_page.dart';
import '../features/checkin/presentation/view_models/scanner_view_model.dart';
import '../features/checkin/presentation/view_models/verdict_view_model.dart';
import '../features/connection/presentation/offline_page.dart';
import '../features/events/presentation/controllers/active_event_controller.dart';
import '../features/events/presentation/pages/event_summary_page.dart';
import '../features/events/presentation/pages/events_page.dart';
import '../features/events/presentation/view_models/event_summary_view_model.dart';
import '../features/events/presentation/view_models/events_view_model.dart';
import '../features/settings/presentation/settings_page.dart';
import 'attendee_routes.dart';
import 'routes.dart';

GoRouter createRouter({
  required SessionController session,
  required ActiveEventController activeEvent,
}) {
  return GoRouter(
    initialLocation: Routes.splash,
    // redirect пересчитывается при каждом notifyListeners() сессии
    refreshListenable: session,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      switch (session.status) {
        case SessionStatus.unknown:
          return loc == Routes.splash ? null : Routes.splash;
        case SessionStatus.signedOut:
          return loc == Routes.signIn || loc == Routes.register ? null : Routes.signIn;
        case SessionStatus.signedIn:
          final role = session.session!.role;
          if (!Routes.allowed(role, loc)) return Routes.home(role);
          final needsEvent = loc.startsWith(Routes.scanner) || loc.startsWith(Routes.search);
          if (needsEvent && activeEvent.event == null) return Routes.events;
          return null;
      }
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, _) => const Scaffold(body: LoadingView()),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (_, _) => ChangeNotifierProvider(
          create: (_) => SignInViewModel(signIn: sl(), session: sl()),
          child: const SignInPage(),
        ),
      ),
      GoRoute(
        path: Routes.register,
        builder: (_, _) => ChangeNotifierProvider(
          create: (_) => RegisterViewModel(register: sl(), session: sl()),
          child: const RegisterPage(),
        ),
      ),
      attendeeRoutes(),
      GoRoute(
        path: Routes.events,
        builder: (_, _) => ChangeNotifierProvider(
          create: (_) => EventsViewModel(
            getEvents: sl(),
            getStats: sl(),
            active: sl(),
            connection: sl(),
          )..load(),
          child: const EventsPage(),
        ),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) => ChangeNotifierProvider(
              create: (_) => EventSummaryViewModel(
                eventId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
                getStats: sl(),
                getLog: sl(),
                active: sl(),
              )..load(),
              child: const EventSummaryPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.scanner,
        builder: (_, _) => ChangeNotifierProvider(
          create: (_) => ScannerViewModel(
            verify: sl(),
            getStats: sl(),
            active: sl(),
            connection: sl(),
          )..refreshStats(),
          child: const ScannerPage(),
        ),
        routes: [
          GoRoute(
            path: 'result',
            redirect: (_, state) => state.extra is ScanResult ? null : Routes.scanner,
            builder: (_, state) => ChangeNotifierProvider(
              create: (_) => VerdictViewModel(
                result: state.extra! as ScanResult,
                undo: sl(),
                active: sl(),
              ),
              child: VerdictPage(result: state.extra! as ScanResult),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.search,
        builder: (_, state) => ChangeNotifierProvider(
          create: (_) => SearchViewModel(
            search: sl(),
            active: sl(),
            initialQuery: state.uri.queryParameters['q'] ?? '',
          ),
          child: const SearchPage(),
        ),
        routes: [
          GoRoute(
            path: 'attendee/:id',
            builder: (_, state) => ChangeNotifierProvider(
              create: (_) => AttendeeViewModel(
                attendeeId: state.pathParameters['id']!,
                getAttendee: sl(),
                checkIn: sl(),
                undo: sl(),
                active: sl(),
                session: sl(),
              )..load(),
              child: const AttendeePage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.settings,
        builder: (_, _) => const SettingsPage(),
      ),
      GoRoute(
        path: Routes.offline,
        builder: (_, _) => const OfflinePage(),
      ),
    ],
  );
}
