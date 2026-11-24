class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.isNetwork = false, this.code});

  final String message;
  final int? statusCode;
  final bool isNetwork;

  /// Код перевода, если сообщение сформировано на телефоне, а не сервером.
  final String? code;

  @override
  String toString() => 'ApiException($statusCode): $message';
}