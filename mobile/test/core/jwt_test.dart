import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/jwt.dart';
import 'package:mobile/features/auth/domain/entities/user_session.dart';
import 'package:mobile/features/auth/domain/usecases/session_usecases.dart';

import '../features/auth/sign_in_test.dart' show FakeAuthRepository;

String token(int exp) {
  String part(Map<String, dynamic> m) => base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part({'sub': '4', 'exp': exp})}.sig';
}

void main() {
  final now = DateTime.utc(2026, 11, 24, 12);
  final past = now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
  final future = now.add(const Duration(hours: 5)).millisecondsSinceEpoch ~/ 1000;

  test('reads exp and detects expiry', () {
    expect(jwtExpiry(token(future)), DateTime.fromMillisecondsSinceEpoch(future * 1000, isUtc: true));
    expect(isJwtExpired(token(past), now: now), isTrue);
    expect(isJwtExpired(token(future), now: now), isFalse);
    expect(isJwtExpired('not-a-jwt', now: now), isFalse);
  });

  test('expired stored session is dropped at start', () async {
    final repo = FakeAuthRepository()
      ..saved = UserSession(token: token(past), userId: 4, email: 'e@x.kz', role: UserRole.eventAdmin);
    expect(await RestoreSession(repo, clock: () => now)(), isNull);
    expect(repo.signedOut, isTrue);
  });

  test('live stored session is kept', () async {
    final repo = FakeAuthRepository()
      ..saved = UserSession(token: token(future), userId: 4, email: 'e@x.kz', role: UserRole.eventAdmin);
    expect((await RestoreSession(repo, clock: () => now)())?.userId, 4);
  });
}
