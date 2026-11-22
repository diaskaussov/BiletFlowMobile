import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/scanner_settings.dart';
import '../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _torch = 'settings.torchOnByDefault';
  static const _sound = 'settings.soundOnResult';
  static const _vibrate = 'settings.vibrateOnReject';
  static const _gate = 'settings.gate';

  @override
  Future<ScannerSettings> load() async {
    const d = ScannerSettings();
    return ScannerSettings(
      torchOnByDefault: await _prefs.getBool(_torch) ?? d.torchOnByDefault,
      soundOnResult: await _prefs.getBool(_sound) ?? d.soundOnResult,
      vibrateOnReject: await _prefs.getBool(_vibrate) ?? d.vibrateOnReject,
      gate: await _prefs.getString(_gate) ?? d.gate,
    );
  }

  @override
  Future<void> save(ScannerSettings s) async {
    await _prefs.setBool(_torch, s.torchOnByDefault);
    await _prefs.setBool(_sound, s.soundOnResult);
    await _prefs.setBool(_vibrate, s.vibrateOnReject);
    await _prefs.setString(_gate, s.gate);
  }
}
