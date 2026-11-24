import '../../../../core/network/jwt.dart';
import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

/// Автовход при запуске для любой известной роли — если токен ещё жив.
class RestoreSession {
  const RestoreSession(this._repo, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AuthRepository _repo;
  final DateTime Function() _clock;

  Future<UserSession?> call() async {
    final session = await _repo.restoreSession();
    if (session == null) return null;
    if (session.role == UserRole.unknown || isJwtExpired(session.token, now: _clock())) {
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
