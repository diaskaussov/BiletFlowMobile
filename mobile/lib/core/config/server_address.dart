import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import 'app_config.dart';

/// Адрес бэкенда, который можно сменить на экране входа. Нужен, когда
/// приложение запускают из Xcode (без --dart-define) или IP компьютера
/// с бэкендом поменялся. Явный --dart-define=API_BASE_URL важнее
/// сохранённого значения.
class ServerAddress extends ChangeNotifier {
  ServerAddress(this._prefs, this._api);

  final SharedPreferencesAsync _prefs;
  final ApiClient _api;

  static const _key = 'server.baseUrl';

  String get current => _api.baseUrl;

  Future<void> load() async {
    if (AppConfig.hasEnvBaseUrl) return;
    final saved = await _prefs.getString(_key);
    if (saved != null && saved.isNotEmpty) _api.baseUrl = saved;
  }

  /// null — сохранено, иначе текст ошибки.
  Future<String?> save(String raw) async {
    final url = normalize(raw);
    if (url == null) return 'Enter an address like http://192.168.1.10:8080';
    _api.baseUrl = url;
    await _prefs.setString(_key, url);
    notifyListeners();
    return null;
  }

  Future<void> reset() async {
    _api.baseUrl = AppConfig.apiBaseUrl;
    await _prefs.remove(_key);
    notifyListeners();
  }

  /// «192.168.1.10» → «http://192.168.1.10:8080».
  static String? normalize(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return null;
    if (!text.contains('://')) text = 'http://$text';
    final uri = Uri.tryParse(text);
    if (uri == null || uri.host.isEmpty || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return null;
    }
    // http без порта — локальный бэкенд на 8080; https без порта — 443.
    if (!uri.hasPort && uri.scheme == 'https') return 'https://${uri.host}';
    final port = uri.hasPort ? uri.port : 8080;
    return '${uri.scheme}://${uri.host}:$port';
  }
}
