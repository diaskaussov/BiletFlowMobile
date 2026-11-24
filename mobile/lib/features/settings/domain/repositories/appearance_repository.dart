import '../entities/appearance.dart';

abstract interface class AppearanceRepository {
  Future<AppearancePreferences> load();

  Future<void> save(AppearancePreferences preferences);
}
