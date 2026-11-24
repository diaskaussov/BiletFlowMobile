/// Ошибка, понятная domain-слою. Data-слой переводит в неё исключения Dio.
///
/// [code] — стабильный ключ для перевода на язык интерфейса
/// (`failureText` в presentation); [message] — английский запасной текст
/// или сообщение сервера как есть, если кода нет.
sealed class Failure {
  const Failure(this.message, {this.code, this.args = const {}});

  final String message;
  final String? code;
  final Map<String, Object> args;

  @override
  String toString() => '$runtimeType(${code ?? '-'}): $message';
}

/// Сервер недоступен: нет сети или истёк таймаут. Сканирование блокируется (A5).
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No connection to the server.']) : super(code: 'network');
}

/// 401 — токен истёк или неверные учётные данные.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired. Sign in again.', String code = 'sessionExpired'])
      : super(code: code);
}

/// 403 — роль не позволяет действие.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'You do not have permission for this action.', String? code = 'forbidden'])
      : super(code: code);
}

/// Ввод не прошёл проверку до запроса.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.args});
}

/// Любой другой ответ сервера с ошибкой. Без [code] показывается текст сервера.
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode, super.code});

  final int? statusCode;
}

/// Нарушенное правило формы — результат `validate()` у черновиков.
class Problem {
  const Problem(this.code, this.message, [this.args = const {}]);

  final String code;
  final String message;
  final Map<String, Object> args;

  ValidationFailure toFailure() => ValidationFailure(message, code: code, args: args);
}
