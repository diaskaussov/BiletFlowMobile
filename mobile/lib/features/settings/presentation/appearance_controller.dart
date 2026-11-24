import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../core/presentation/safe_notifier.dart';
import '../domain/entities/appearance.dart';
import '../domain/usecases/appearance_usecases.dart';

/// Тема и язык приложения. MaterialApp слушает его и перестраивается.
class AppearanceController extends ChangeNotifier with SafeNotifier {
  AppearanceController({required this._load, required this._save});

  final LoadAppearance _load;
  final SaveAppearance _save;

  AppearancePreferences _prefs = const AppearancePreferences();

  AppearancePreferences get preferences => _prefs;

  ThemeMode get themeMode => switch (_prefs.theme) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      };

  Locale get locale => Locale(_prefs.language.code);

  Future<void> load() async {
    _prefs = await _load();
    await _applyIntl();
    notifyListeners();
  }

  Future<void> setTheme(ThemePreference theme) => _update(_prefs.copyWith(theme: theme));

  Future<void> setLanguage(AppLanguage language) => _update(_prefs.copyWith(language: language));

  Future<void> _update(AppearancePreferences next) async {
    _prefs = next;
    await _applyIntl();
    notifyListeners();
    await _save(next);
  }

  /// Даты и числа (`intl`) форматируются на выбранном языке.
  Future<void> _applyIntl() async {
    final code = _prefs.language.code;
    await initializeDateFormatting(code);
    Intl.defaultLocale = code;
  }
}
