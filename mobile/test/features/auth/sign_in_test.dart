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

  test('organizer is refused and nothing is saved (§4.8)', () async {
    repo.next = const Ok(
      UserSession(token: 't', userId: 2, email: 'organizer@biletflow.kz', role: UserRole.organizer),
    );
    final r = await signIn(email: 'organizer@biletflow.kz', password: '123');
    expect(r.failureOrNull, isA<ForbiddenFailure>());
    expect(repo.saved, isNull);
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

  test('restore drops a stored session of a non-admin role', () async {
    repo.saved = const UserSession(token: 't', userId: 3, email: 'x@y.kz', role: UserRole.attendee);
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
