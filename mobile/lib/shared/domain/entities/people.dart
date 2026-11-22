import '../../../features/auth/domain/entities/user_session.dart';

/// Аккаунт пользователя без секретов (P1, O10).
class UserAccount {
  const UserAccount({
    required this.id,
    required this.email,
    required this.role,
    this.firstName = '',
    this.lastName = '',
    this.phone,
    this.emailVerified = false,
    this.suspended = false,
    this.createdAt,
  });

  final int id;
  final String email;
  final UserRole role;
  final String firstName;
  final String lastName;
  final String? phone;
  final bool emailVerified;
  final bool suspended;
  final DateTime? createdAt;

  String get fullName {
    final n = '$firstName $lastName'.trim();
    return n.isEmpty ? email : n;
  }
}

/// Сотрудник на входе события (O10).
class StaffAssignment {
  const StaffAssignment({required this.id, required this.user, this.eventId});

  final int id;
  final int? eventId;
  final UserAccount user;
}

/// Профиль организатора и счёт для выплат (O4, §4.1).
class OrganizerProfile {
  const OrganizerProfile({
    this.organizationName = '',
    this.description = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.website = '',
    this.payoutBankName = '',
    this.payoutAccountNumber = '',
    this.payoutAccountHolder = '',
    this.identityVerified = false,
    this.payoutVerified = false,
  });

  final String organizationName;
  final String description;
  final String contactEmail;
  final String contactPhone;
  final String website;
  final String payoutBankName;
  final String payoutAccountNumber;
  final String payoutAccountHolder;
  final bool identityVerified;
  final bool payoutVerified;

  bool get hasPayoutAccount =>
      payoutBankName.isNotEmpty && payoutAccountNumber.isNotEmpty && payoutAccountHolder.isNotEmpty;
}
