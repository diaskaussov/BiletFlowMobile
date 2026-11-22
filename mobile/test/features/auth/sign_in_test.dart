import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/error/result.dart';
import 'package:mobile/features/auth/domain/entities/user_session.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/session_usecases.dart';
import 'package:mobile/features/auth/domain/usecases/sign_in.dart';

class FakeAuthRepository implements AuthRepository {
  Result<UserSession> next = const Ok(
    UserSession(token: 't', userId: 4, email: 'eventadmin@biletflow.kz', role: UserRole.eventAdmin),
  );
  UserSession? saved;
  bool signedOut = false;
  String? lastEmail;

  @override
  Future<Result<UserSession>> signIn({required String email, required String password}) async {
    lastEmail = email;
    return next;
  }

  Result<UserSession> registerNext = const Err(ServerFailure('not set'));

  @override
  Future<Result<UserSession>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phone,
  }) async {
    lastEmail = email;
    return registerNext;
  }

  @override
  Future<void> saveSession(UserSession session) async => saved = session;

  @override
  Future<UserSession?> restoreSession() async => saved;

  @override
  Future<void> signOut() async {
    signedOut = true;
    saved = null;
  }
}

void main() {
  late FakeAuthRepository repo;
  late SignIn signIn;

  setUp(() {
    repo = FakeAuthRepository();
    signIn = SignIn(repo);
  });

  test('event admin signs in and the session is saved', () async {
    final r = await signIn(email: ' EventAdmin@BiletFlow.kz ', password: '123');
    expect(r, isA<Ok<UserSession>>());
    expect(repo.lastEmail, 'eventadmin@biletflow.kz');
    expect(repo.saved, isNotNull);
  });

  test('every known role can sign in', () async {
    for (final role in [UserRole.organizer, UserRole.attendee, UserRole.platformAdmin]) {
      repo.next = Ok(UserSession(token: 't', userId: 2, email: 'x@biletflow.kz', role: role));
      final r = await signIn(email: 'x@biletflow.kz', password: '123');
      expect(r.valueOrNull?.role, role);
    }
  });

  test('unknown role is refused and nothing is saved', () async {
    repo.next = const Ok(
      UserSession(token: 't', userId: 2, email: 'x@biletflow.kz', role: UserRole.unknown),
    );
    final r = await signIn(email: 'x@biletflow.kz', password: '123');
    expect(r.failureOrNull, isA<ForbiddenFailure>());
    expect(repo.saved, isNull);
  });

  group('Register', () {
    test('validates input before the request', () async {
      final register = Register(repo);
      expect((await register(email: 'a@b.kz', password: '123', firstName: 'A', lastName: 'B', role: UserRole.attendee))
          .failureOrNull?.message, contains('6'));
      expect((await register(email: 'bad', password: '123456', firstName: 'A', lastName: 'B', role: UserRole.attendee))
          .failureOrNull, isA<ValidationFailure>());
      expect((await register(email: 'a@b.kz', password: '123456', firstName: ' ', lastName: 'B', role: UserRole.attendee))
          .failureOrNull, isA<ValidationFailure>());
      expect((await register(email: 'a@b.kz', password: '123456', firstName: 'A', lastName: 'B', role: UserRole.platformAdmin))
          .failureOrNull, isA<ValidationFailure>());
    });

    test('registers an organizer and saves the session', () async {
      repo.registerNext = const Ok(UserSession(token: 't', userId: 9, email: 'o@b.kz', role: UserRole.organizer));
      final r = await Register(repo)(email: 'O@b.kz', password: '123456', firstName: 'O', lastName: 'Z', role: UserRole.organizer);
      expect(r.valueOrNull?.role, UserRole.organizer);
      expect(repo.saved?.userId, 9);
      expect(repo.lastEmail, 'o@b.kz');
    });
  });

  test('bad email is rejected before the request', () async {
    final r = await signIn(email: 'not-an-email', password: '123');
    expect(r.failureOrNull, isA<ValidationFailure>());
    expect(repo.lastEmail, isNull);
  });

  test('401 and 400 read as wrong credentials', () async {
    repo.next = const Err(UnauthorizedFailure('Bad credentials'));
    var r = await signIn(email: 'a@b.kz', password: 'x');
    expect(r.failureOrNull?.message, 'Incorrect email or password.');

    repo.next = const Err(ServerFailure('Invalid email or password', statusCode: 400));
    r = await signIn(email: 'a@b.kz', password: 'x');
    expect(r.failureOrNull?.message, 'Incorrect email or password.');
  });

  test('network failure is passed through', () async {
    repo.next = const Err(NetworkFailure());
    final r = await signIn(email: 'a@b.kz', password: 'x');
    expect(r.failureOrNull, isA<NetworkFailure>());
  });

  test('restore keeps any known role and drops unknown', () async {
    repo.saved = const UserSession(token: 't', userId: 3, email: 'x@y.kz', role: UserRole.attendee);
    expect((await RestoreSession(repo)())?.role, UserRole.attendee);
    repo.saved = const UserSession(token: 't', userId: 3, email: 'x@y.kz', role: UserRole.unknown);
    expect(await RestoreSession(repo)(), isNull);
    expect(repo.signedOut, isTrue);
  });

  test('shortName', () {
    const s = UserSession(
      token: 't', userId: 1, email: 'a@b.kz', role: UserRole.eventAdmin,
      firstName: 'Aisha', lastName: 'Nurlanova',
    );
    expect(s.shortName, 'A. Nurlanova');
    expect(s.fullName, 'Aisha Nurlanova');
  });
}
