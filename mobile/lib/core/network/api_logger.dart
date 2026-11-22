import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Лог каждого запроса в консоль (flutter run / Xcode):
///   GET /api/staff/my-events Request sent
///   GET /api/staff/my-events Request SUCCESS
///   GET /api/staff/my-events Request FAILED httpCode(500)
///
/// Тело запроса и заголовки не пишем: там пароль, токен и коды билетов.
/// В release-сборке лог выключен.
class ApiLogger extends Interceptor {
  const ApiLogger();

  static String _name(RequestOptions o) => '${o.method} ${o.uri.path}';

  static void _log(String line) {
    if (kDebugMode) debugPrint('[API] $line');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('${_name(options)} Request sent → ${options.uri.origin}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _log('${_name(response.requestOptions)} Request SUCCESS httpCode(${response.statusCode})');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final code = err.response?.statusCode;
    final reason = code != null ? 'httpCode($code)' : 'no response (${err.type.name})';
    _log('${_name(err.requestOptions)} Request FAILED $reason');
    handler.next(err);
  }
}
