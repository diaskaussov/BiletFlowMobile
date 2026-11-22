import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exception.dart';
import 'api_logger.dart';

/// Обёртка над Dio: базовый адрес, Bearer-токен, единый формат ошибок
/// бэкенда `{ "error": "...", "timestamp": "..." }`.
class ApiClient {
  ApiClient({required String baseUrl, required Duration timeout, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: timeout,
              receiveTimeout: timeout,
              sendTimeout: timeout,
              headers: {'Content-Type': 'application/json'},
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(const ApiLogger());
  }

  final Dio _dio;
  String? _token;

  String get baseUrl => _dio.options.baseUrl;

  /// Адрес сервера меняется без перезапуска (экран входа → «Server»).
  set baseUrl(String value) => _dio.options.baseUrl = value;

  /// Время последнего ответа сервера — «Last sync» на A5.
  final ValueNotifier<DateTime?> lastResponseAt = ValueNotifier(null);

  /// Вызывается, когда сервер отверг действующий токен (401).
  VoidCallback? onUnauthorized;

  void setToken(String? token) => _token = token;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) {
    return _send(() => _dio.get<dynamic>(path, queryParameters: query));
  }

  Future<dynamic> post(String path, {Object? body}) {
    return _send(() => _dio.post<dynamic>(path, data: body));
  }

  Future<dynamic> put(String path, {Object? body}) {
    return _send(() => _dio.put<dynamic>(path, data: body));
  }

  Future<dynamic> patch(String path, {Object? body}) {
    return _send(() => _dio.patch<dynamic>(path, data: body));
  }

  Future<dynamic> delete(String path) {
    return _send(() => _dio.delete<dynamic>(path));
  }

  /// Бинарный ответ: QR (PNG) и билет (PDF).
  Future<Uint8List> getBytes(String path) async {
    final data = await _send(
      () => _dio.get<dynamic>(path, options: Options(responseType: ResponseType.bytes)),
    );
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    throw const FormatException('Expected binary data');
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      lastResponseAt.value = DateTime.now();
      return response.data;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null) lastResponseAt.value = DateTime.now();
      if (status == 401 && _token != null) onUnauthorized?.call();
      throw ApiException(
        _messageFrom(e),
        statusCode: status,
        isNetwork: status == null && e.type != DioExceptionType.cancel,
      );
    }
  }

  static String _messageFrom(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      for (final key in const ['error', 'message']) {
        final value = data[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }
    if (data is String && data.isNotEmpty && data.length < 200) return data;
    return e.message ?? 'Network error';
  }
}
