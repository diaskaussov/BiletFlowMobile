import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

/// Автовход при запуске: только если сохранена сессия администратора.
class RestoreSession {
  const RestoreSession(this._repo);

  final AuthRepository _repo;

  Future<UserSession?> call() async {
    final session = await _repo.restoreSession();
    if (session == null) return null;
    if (session.role != UserRole.eventAdmin) {
      await _repo.signOut();
      return null;
    }
    return session;
  }
}

class SignOut {
  const SignOut(this._repo);

  final AuthRepository _repo;

  Future<void> call() => _repo.signOut();
}
