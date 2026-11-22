import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/config/server_address.dart';
import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/checkin/domain/usecases/checkin_usecases.dart';
import '../features/connection/presentation/connection_controller.dart';
import '../features/events/presentation/controllers/active_event_controller.dart';
import '../features/settings/presentation/settings_controller.dart';
import 'router.dart';

class BiletFlowApp extends StatefulWidget {
  const BiletFlowApp({super.key});

  @override
  State<BiletFlowApp> createState() => _BiletFlowAppState();
}

class _BiletFlowAppState extends State<BiletFlowApp> {
  final _session = sl<SessionController>();
  final _activeEvent = sl<ActiveEventController>();
  late final GoRouter _router = createRouter(session: _session, activeEvent: _activeEvent);

  @override
  void initState() {
    super.initState();
    _session.addListener(_onSessionChanged);
    sl<SettingsController>().load();
    _session.restore();
  }

  /// При выходе данные смены прошлого пользователя не должны остаться.
  void _onSessionChanged() {
    if (_session.status == SessionStatus.signedOut) {
      _activeEvent.clear();
      sl<ClearScanLog>()();
    }
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _session),
        ChangeNotifierProvider.value(value: _activeEvent),
        ChangeNotifierProvider.value(value: sl<SettingsController>()),
        ChangeNotifierProvider.value(value: sl<ConnectionController>()),
        ChangeNotifierProvider.value(value: sl<ServerAddress>()),
      ],
      child: MaterialApp.router(
        title: 'BiletFlow Scanner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
