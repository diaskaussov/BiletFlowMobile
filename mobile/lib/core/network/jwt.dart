import 'dart:convert';

/// Срок действия JWT из поля `exp`, без проверки подписи — подпись
/// проверяет сервер. Бэкенд выдаёт токены на 24 часа и на истёкший токен
/// отвечает 403, а не 401, поэтому срок нужно знать на телефоне.
DateTime? jwtExpiry(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    final exp = payload is Map ? payload['exp'] : null;
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
  } on FormatException {
    return null;
  }
}

bool isJwtExpired(String token, {DateTime? now}) {
  final exp = jwtExpiry(token);
  return exp != null && !exp.isAfter((now ?? DateTime.now()).toUtc());
}
