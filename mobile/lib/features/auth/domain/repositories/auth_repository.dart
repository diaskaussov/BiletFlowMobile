import '../../../../core/error/result.dart';
import '../entities/user_session.dart';

abstract interface class AuthRepository {
  /// Проверяет учётные данные на сервере. Сессию не сохраняет —
  /// это решает use case после проверки роли.
  Future<Result<UserSession>> signIn({required String email, required String password});

  /// Регистрация участника или организатора (§4.1). Сессию не сохраняет.
  Future<Result<UserSession>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phone,
  });

  /// Запоминает сессию на устройстве и подставляет токен в запросы.
  Future<void> saveSession(UserSession session);

  /// Сессия, сохранённая при прошлом запуске, или null.
  Future<UserSession?> restoreSession();

  Future<void> signOut();
}
