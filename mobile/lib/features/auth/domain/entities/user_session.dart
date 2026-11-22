enum UserRole {
  eventAdmin,
  organizer,
  attendee,
  platformAdmin,
  unknown;

  static UserRole parse(String? raw) => switch (raw?.toUpperCase()) {
        'EVENT_ADMIN' => UserRole.eventAdmin,
        'ORGANIZER' => UserRole.organizer,
        'ATTENDEE' => UserRole.attendee,
        'PLATFORM_ADMIN' => UserRole.platformAdmin,
        _ => UserRole.unknown,
      };

  String get wire => switch (this) {
        UserRole.eventAdmin => 'EVENT_ADMIN',
        UserRole.organizer => 'ORGANIZER',
        UserRole.attendee => 'ATTENDEE',
        UserRole.platformAdmin => 'PLATFORM_ADMIN',
        UserRole.unknown => 'UNKNOWN',
      };
}

/// Вошедший пользователь. Сканер доступен только [UserRole.eventAdmin] (§4.8).
class UserSession {
  const UserSession({
    required this.token,
    required this.userId,
    required this.email,
    required this.role,
    this.firstName = '',
    this.lastName = '',
  });

  final String token;
  final int userId;
  final String email;
  final UserRole role;
  final String firstName;
  final String lastName;

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? email : name;
  }

  /// «A. Nurlanova» — для шапок и журналов.
  String get shortName {
    if (firstName.isEmpty || lastName.isEmpty) return fullName;
    return '${firstName[0]}. $lastName';
  }
}
