import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/auth/auth_view.dart';
import 'package:mobile/features/auth/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

abstract final class Routes {
  static const auth = '/auth';
  static const events = '/events';
  static const eventSummary = '/events/:id';
  static const scanner = '/scan';
  static const search = '/search';
  static const dashboard = '/dashboard';
  static const settings = '/settings';
}

GoRouter createRouter(AuthViewModel auth) {
  return GoRouter(
    initialLocation: Routes.auth,

    // роутер пересчитывает redirect, когда ViewModel зовёт notifyListeners()
    refreshListenable: auth,

    redirect: (context, state) {
      final atSignIn = state.matchedLocation == Routes.auth;

      if (!auth.isSignedIn) return atSignIn ? null : Routes.auth;
      if (atSignIn) return Routes.events;
      return null;
    },

    routes: [
      GoRoute(
        path: Routes.auth,
        builder: (context, state) => const AuthView(),
      ),
      GoRoute(
        path: Routes.events,
        builder: (context, state) => const _Stub('A3 · Assigned events'),
      ),
      GoRoute(
        path: Routes.eventSummary,
        builder: (context, state) =>
            _Stub('A4 · Event summary — ${state.pathParameters['id']}'),
      ),
      GoRoute(
        path: Routes.scanner,
        builder: (context, state) => const _Stub('B1 · Scanner'),
      ),
      GoRoute(
        path: Routes.search,
        builder: (context, state) => const _Stub('C1 · Find by name'),
      ),
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const _Stub('D1 · Live dashboard'),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const _Stub('A6 · Settings'),
      ),
    ],
  );
}

class _Stub extends StatelessWidget {
  const _Stub(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Center(
          child: SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => context.read<AuthViewModel>().signOut(),
              icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Icon(Icons.chevron_left, size: 18),
              ),
            ),
          ),
        )
      ),
      body: Center(child: Text(title)),
    );
  }
}