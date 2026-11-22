import 'dart:io' show Platform;

/// Настройки сборки. Адрес API задаётся при запуске:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080`
abstract final class AppConfig {
  static const _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get hasEnvBaseUrl => _envBaseUrl.isNotEmpty;

  /// Без dart-define: Android-эмулятор видит компьютер как 10.0.2.2,
  /// iOS-симулятор — как localhost.
  static String get apiBaseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
  }

  /// SRS §7: проверка QR должна укладываться примерно в 2 с; 5 с — запас на
  /// слабую сеть площадки, дальше считаем, что связи нет.
  static const requestTimeout = Duration(seconds: 5);

  /// B6: тот же код повторно в этом окне — одна и та же проходка, не отказ.
  static const repeatScanWindow = Duration(seconds: 10);

  static const appVersion = '0.3';
}
