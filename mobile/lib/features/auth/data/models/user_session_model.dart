import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/user_session.dart';

/// Ответ `POST /api/auth/login`:
/// `{ token, userId, email, role, firstName, lastName }`.
abstract final class UserSessionModel {
  static UserSession fromJson(Map<String, dynamic> json) {
    final token = json.str(['token', 'accessToken', 'jwt']);
    if (token == null) {
      throw const FormatException('Login response has no token');
    }
    return UserSession(
      token: token,
      userId: json.integer(['userId', 'id']) ?? 0,
      email: json.str(['email']) ?? '',
      role: UserRole.parse(json.str(['role'])),
      firstName: json.str(['firstName']) ?? '',
      lastName: json.str(['lastName']) ?? '',
    );
  }

  static Map<String, dynamic> toJson(UserSession s) => {
        'token': s.token,
        'userId': s.userId,
        'email': s.email,
        'role': s.role.wire,
        'firstName': s.firstName,
        'lastName': s.lastName,
      };
}
