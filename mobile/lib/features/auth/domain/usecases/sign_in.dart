import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

/// Вход для всех ролей. После входа роутер открывает раздел по роли:
/// участник, организатор, сотрудник на входе, админ платформы.
class SignIn {
  const SignIn(this._repo);

  final AuthRepository _repo;

  Future<Result<UserSession>> call({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (!_emailPattern.hasMatch(normalized)) {
      return const Err(ValidationFailure('Enter a valid email address.', code: 'emailInvalid'));
    }
    if (password.isEmpty) {
      return const Err(ValidationFailure('Enter your password.', code: 'passwordEmpty'));
    }

    final result = await _repo.signIn(email: normalized, password: password);
    switch (result) {
      case Err(:final failure):
        return Err(_explain(failure));
      case Ok(:final value):
        if (value.role == UserRole.unknown) {
          return const Err(ForbiddenFailure('This account type is not supported by the app.', 'accountUnsupported'));
        }
        await _repo.saveSession(value);
        return Ok(value);
    }
  }

  static Failure _explain(Failure f) => switch (f) {
        UnauthorizedFailure() => const UnauthorizedFailure('Incorrect email or password.', 'wrongCredentials'),
        ServerFailure(statusCode: 400 || 404, :final message)
            when message.toLowerCase().contains('suspend') =>
          ForbiddenFailure(message),
        ServerFailure(statusCode: 400 || 404) =>
          const UnauthorizedFailure('Incorrect email or password.', 'wrongCredentials'),
        _ => f,
      };
}

/// Регистрация (§4.1). Самостоятельно можно стать только участником
/// или организатором — сотрудников назначает организатор, админов платформа.
class Register {
  const Register(this._repo);

  final AuthRepository _repo;

  static const minPasswordLength = 6;
  static const allowedRoles = [UserRole.attendee, UserRole.organizer];

  Future<Result<UserSession>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phone,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return const Err(ValidationFailure('Enter your first and last name.', code: 'nameRequired'));
    }
    if (!_emailPattern.hasMatch(normalized)) {
      return const Err(ValidationFailure('Enter a valid email address.', code: 'emailInvalid'));
    }
    if (password.length < minPasswordLength) {
      return const Err(ValidationFailure('Password must be at least 6 characters.', code: 'passwordShort'));
    }
    if (!allowedRoles.contains(role)) {
      return const Err(ValidationFailure('Choose attendee or organizer.', code: 'roleRequired'));
    }
    final result = await _repo.register(
      email: normalized,
      password: password,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      role: role,
      phone: phone?.trim(),
    );
    if (result case Ok(:final value)) await _repo.saveSession(value);
    return result;
  }
}
