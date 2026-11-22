import 'package:flutter/foundation.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../domain/entities/scanner_settings.dart';
import '../domain/usecases/settings_usecases.dart';

/// Глобальные настройки сканера — их читают сканер и экраны результата.
class SettingsController extends ChangeNotifier {
  SettingsController({required this._load, required this._save});

  final LoadSettings _load;
  final SaveSettings _save;

  ScannerSettings _settings = const ScannerSettings();

  ScannerSettings get settings => _settings;

  Future<void> load() async {
    _settings = await _load();
    notifyListeners();
  }

  /// null — сохранено, иначе ошибка проверки.
  Future<Failure?> update(ScannerSettings next) async {
    final result = await _save(next);
    switch (result) {
      case Ok(:final value):
        _settings = value;
        notifyListeners();
        return null;
      case Err(:final failure):
        return failure;
    }
  }
}
