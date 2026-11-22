import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/attendees/data/attendees_remote_data_source.dart';
import '../../features/attendees/data/attendees_repository_impl.dart';
import '../../features/attendees/domain/repositories/attendees_repository.dart';
import '../../features/attendees/domain/usecases/attendee_usecases.dart';
import '../../features/auth/data/datasources/auth_data_sources.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/session_usecases.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/presentation/controllers/session_controller.dart';
import '../../features/checkin/data/datasources/checkin_data_sources.dart';
import '../../features/checkin/data/repositories/checkin_repositories_impl.dart';
import '../../features/checkin/domain/repositories/checkin_repositories.dart';
import '../../features/checkin/domain/usecases/checkin_usecases.dart';
import '../../features/checkin/domain/usecases/verify_ticket.dart';
import '../../features/connection/presentation/connection_controller.dart';
import '../../features/events/data/datasources/events_remote_data_source.dart';
import '../../features/events/data/repositories/events_repository_impl.dart';
import '../../features/events/domain/repositories/events_repository.dart';
import '../../features/events/domain/usecases/event_usecases.dart';
import '../../features/events/presentation/controllers/active_event_controller.dart';
import '../../features/settings/data/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/settings_usecases.dart';
import '../../features/settings/presentation/settings_controller.dart';
import '../config/app_config.dart';
import '../config/server_address.dart';
import '../error/failure.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

/// Регистрация зависимостей. Слои связываются только здесь:
/// presentation → use case → интерфейс репозитория ← реализация в data.
Future<void> configureDependencies() async {
  // — core —
  sl
    ..registerLazySingleton(() => ApiClient(
          baseUrl: AppConfig.apiBaseUrl,
          timeout: AppConfig.requestTimeout,
        ))
    ..registerLazySingleton<NetworkInfo>(ConnectivityNetworkInfo.new)
    ..registerLazySingleton(() => const FlutterSecureStorage())
    ..registerLazySingleton(SharedPreferencesAsync.new)
    ..registerLazySingleton(() => ServerAddress(sl(), sl()));

  // — data sources —
  sl
    ..registerLazySingleton(() => AuthRemoteDataSource(sl()))
    ..registerLazySingleton(() => AuthLocalDataSource(sl()))
    ..registerLazySingleton(() => EventsRemoteDataSource(sl()))
    ..registerLazySingleton(() => CheckinRemoteDataSource(sl()))
    ..registerLazySingleton(() => AttendeesRemoteDataSource(sl()))
    ..registerLazySingleton(ScanLogMemoryDataSource.new);

  // — repositories —
  sl
    ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remote: sl(), local: sl(), api: sl()))
    ..registerLazySingleton<EventsRepository>(() => EventsRepositoryImpl(sl()))
    ..registerLazySingleton<CheckinRepository>(() => CheckinRepositoryImpl(sl()))
    ..registerLazySingleton<ScanLogRepository>(() => ScanLogRepositoryImpl(sl()))
    ..registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()))
    ..registerLazySingleton<AttendeesRepository>(() => AttendeesRepositoryImpl(sl()));

  // — use cases —
  sl
    ..registerLazySingleton(() => SignIn(sl()))
    ..registerLazySingleton(() => RestoreSession(sl()))
    ..registerLazySingleton(() => SignOut(sl()))
    ..registerLazySingleton(() => GetAssignedEvents(sl()))
    ..registerLazySingleton(() => GetEventStats(sl()))
    ..registerLazySingleton(() => VerifyTicket(
          checkin: sl(),
          log: sl(),
          network: sl(),
          repeatWindow: AppConfig.repeatScanWindow,
        ))
    ..registerLazySingleton(() => UndoCheckIn(checkin: sl(), log: sl()))
    ..registerLazySingleton(() => GetScanLog(sl()))
    ..registerLazySingleton(() => ClearScanLog(sl()))
    ..registerLazySingleton(() => LoadSettings(sl()))
    ..registerLazySingleton(() => SaveSettings(sl()))
    ..registerLazySingleton(() => SearchAttendees(sl()))
    ..registerLazySingleton(() => GetAttendee(sl()))
    ..registerLazySingleton(() => CheckInAttendee(sl()))
    ..registerLazySingleton(() => UndoAttendeeCheckIn(sl()));

  // — глобальные контроллеры —
  sl
    ..registerLazySingleton(() => SessionController(restore: sl(), signOut: sl()))
    ..registerLazySingleton(ActiveEventController.new)
    ..registerLazySingleton(() => SettingsController(load: sl(), save: sl()))
    ..registerLazySingleton(() => ConnectionController(
          network: sl(),
          lastResponseAt: sl<ApiClient>().lastResponseAt,
          probeServer: () async {
            final r = await sl<GetAssignedEvents>()();
            return r.failureOrNull is! NetworkFailure;
          },
        ));

  await sl<ServerAddress>().load();

  // Сервер отверг токен — выходим, роутер вернёт на A1.
  sl<ApiClient>().onUnauthorized = () => sl<SessionController>().signOut();
}
