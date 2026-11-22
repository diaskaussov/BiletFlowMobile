import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

/// A1: вход администратора события.
/// Правила: корректный email, непустой пароль, роль только EVENT_ADMIN.
class SignIn {
  const SignIn(this._repo);

  final AuthRepository _repo;

  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  Future<Result<UserSession>> call({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (!_emailPattern.hasMatch(normalized)) {
      return const Err(ValidationFailure('Enter a valid email address.'));
    }
    if (password.isEmpty) {
      return const Err(ValidationFailure('Enter your password.'));
    }

    final result = await _repo.signIn(email: normalized, password: password);
    switch (result) {
      case Err(:final failure):
        return Err(_explain(failure));
      case Ok(:final value):
        if (value.role != UserRole.eventAdmin) {
          return const Err(ForbiddenFailure(
            'This account is not an event admin. The scanner is only for '
            'staff an organizer assigned to an event.',
          ));
        }
        await _repo.saveSession(value);
        return Ok(value);
    }
  }

  static Failure _explain(Failure f) => switch (f) {
        UnauthorizedFailure() => const UnauthorizedFailure('Incorrect email or password.'),
        ServerFailure(statusCode: 400 || 404) =>
          const UnauthorizedFailure('Incorrect email or password.'),
        _ => f,
      };
}
