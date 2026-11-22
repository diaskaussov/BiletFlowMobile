import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_session.dart';
import '../models/user_session_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._api);

  final ApiClient _api;

  Future<UserSession> login(String email, String password) async {
    final json = await _api.post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );
    if (json is! Map) throw const FormatException('Login response is not an object');
    return UserSessionModel.fromJson(json.cast<String, dynamic>());
  }

  Future<UserSession> register(Map<String, dynamic> body) async {
    final json = await _api.post('/api/auth/register', body: body);
    if (json is! Map) throw const FormatException('Register response is not an object');
    return UserSessionModel.fromJson(json.cast<String, dynamic>());
  }
}

/// Сессия хранится в Keychain / Keystore — токен не лежит открытым текстом.
class AuthLocalDataSource {
  const AuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'biletflow.session';

  Future<void> save(UserSession session) =>
      _storage.write(key: _key, value: jsonEncode(UserSessionModel.toJson(session)));

  Future<UserSession?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      return UserSessionModel.fromJson(
        (jsonDecode(raw) as Map).cast<String, dynamic>(),
      );
    } on Exception {
      // Повреждённая запись — просто просим войти заново.
      await clear();
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _key);
}
