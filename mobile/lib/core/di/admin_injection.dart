import 'package:get_it/get_it.dart';

import '../../features/admin/data/admin_repository_impl.dart';
import '../../features/admin/domain/admin_domain.dart';

/// Админ платформы (P1–P2).
void configureAdminDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetAdminQueues(sl()))
    ..registerLazySingleton(() => AdminLists(sl()))
    ..registerLazySingleton(() => GetModerationCase(sl()))
    ..registerLazySingleton(() => ModerationActions(sl()));
}
