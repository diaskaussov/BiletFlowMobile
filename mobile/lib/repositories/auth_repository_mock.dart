import 'package:mobile/features/auth/view_model/auth_exception.dart';
import 'package:mobile/models/auth_session.dart';
import 'package:mobile/repositories/auth_repository.dart';

class AuthRepositoryMock implements AuthRepository {
  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (password.length < 4) {
      throw AuthException('Incorrect email or password.');
    }
    return const AuthSession(token: 'mock-token', staffName: 'Dias Sagynbek');
  }

  @override
  Future<void> signOut() async {}
}