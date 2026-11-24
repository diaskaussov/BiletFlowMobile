/// Тема интерфейса: как в системе, светлая или тёмная.
enum ThemePreference { system, light, dark }

/// Языки из SRS §7: казахский и русский, английский дополнительно.
enum AppLanguage {
  ru('ru'),
  kk('kk'),
  en('en');

  const AppLanguage(this.code);

  final String code;

  static AppLanguage parse(String? code) =>
      values.where((l) => l.code == code).firstOrNull ?? AppLanguage.ru;
}

class AppearancePreferences {
  const AppearancePreferences({this.theme = ThemePreference.system, this.language = AppLanguage.ru});

  final ThemePreference theme;
  final AppLanguage language;

  AppearancePreferences copyWith({ThemePreference? theme, AppLanguage? language}) =>
      AppearancePreferences(theme: theme ?? this.theme, language: language ?? this.language);
}
