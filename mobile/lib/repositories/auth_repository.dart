import 'package:mobile/models/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> signIn({ 
    required String email, 
    required String password
  });

  Future<void> signOut();
}