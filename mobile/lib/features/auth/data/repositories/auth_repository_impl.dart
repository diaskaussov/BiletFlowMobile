import '../../../../core/error/result.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/request_guard.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_sources.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this._remote,
    required this._local,
    required this._api,
  });

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final ApiClient _api;

  @override
  Future<Result<UserSession>> signIn({
    required String email,
    required String password,
  }) =>
      guard(() => _remote.login(email, password));

  @override
  Future<Result<UserSession>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phone,
  }) =>
      guard(() => _remote.register({
            'email': email,
            'password': password,
            'firstName': firstName,
            'lastName': lastName,
            'role': role.wire,
            if (phone != null && phone.isNotEmpty) 'phone': phone,
          }));

  @override
  Future<void> saveSession(UserSession session) async {
    _api.setToken(session.token);
    await _local.save(session);
  }

  @override
  Future<UserSession?> restoreSession() async {
    final session = await _local.read();
    _api.setToken(session?.token);
    return session;
  }

  @override
  Future<void> signOut() async {
    _api.setToken(null);
    await _local.clear();
  }
}
