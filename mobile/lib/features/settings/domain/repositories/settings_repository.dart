import '../entities/scanner_settings.dart';

abstract interface class SettingsRepository {
  Future<ScannerSettings> load();

  Future<void> save(ScannerSettings settings);
}
