import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/appearance.dart';
import '../domain/repositories/appearance_repository.dart';

class AppearanceRepositoryImpl implements AppearanceRepository {
  const AppearanceRepositoryImpl(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _theme = 'appearance.theme';
  static const _language = 'appearance.language';

  @override
  Future<AppearancePreferences> load() async {
    final theme = await _prefs.getString(_theme);
    return AppearancePreferences(
      theme: ThemePreference.values.where((t) => t.name == theme).firstOrNull ?? ThemePreference.system,
      language: AppLanguage.parse(await _prefs.getString(_language)),
    );
  }

  @override
  Future<void> save(AppearancePreferences p) async {
    await _prefs.setString(_theme, p.theme.name);
    await _prefs.setString(_language, p.language.code);
  }
}
