import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exception.dart';

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
  }

  final Dio _dio;
  String? _token;

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
