import '../error/failure.dart';
import '../error/result.dart';
import 'api_exception.dart';

/// Переводит исключения data-слоя в [Result]. Используется в реализациях
/// репозиториев, чтобы domain никогда не видел Dio и исключения.
Future<Result<T>> guard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on ApiException catch (e) {
    return Err(failureFromApi(e));
  } on FormatException {
    return const Err(ServerFailure('Unexpected server response.'));
  } on TypeError {
    // Поле пришло не того типа — контракт API разошёлся с моделью.
    return const Err(ServerFailure('Unexpected server response.'));
  }
}

Failure failureFromApi(ApiException e) {
  if (e.isNetwork) return const NetworkFailure();
  return switch (e.statusCode) {
    401 => UnauthorizedFailure(e.message),
    403 => const ForbiddenFailure(),
    _ => ServerFailure(e.message, statusCode: e.statusCode),
  };
}
