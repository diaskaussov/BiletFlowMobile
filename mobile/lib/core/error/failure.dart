/// Ошибка, понятная domain-слою. Data-слой переводит в неё исключения Dio,
/// presentation показывает [message].
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Сервер недоступен: нет сети или истёк таймаут. Сканирование блокируется (A5).
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No connection to the server.']);
}

/// 401 — токен истёк или неверные учётные данные.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired. Sign in again.']);
}

/// 403 — роль не позволяет действие.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = 'You do not have permission for this action.',
  ]);
}

/// Ввод не прошёл проверку до запроса.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Любой другой ответ сервера с ошибкой.
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}
