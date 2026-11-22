import 'package:flutter/foundation.dart';

import '../../domain/entities/user_session.dart';
import '../../domain/usecases/session_usecases.dart';

enum SessionStatus { unknown, signedIn, signedOut }

/// Глобальное состояние входа. Роутер слушает его и перенаправляет
/// на A1, когда сессия пропадает.
class SessionController extends ChangeNotifier {
  SessionController({required this._restore, required this._signOut});

  final RestoreSession _restore;
  final SignOut _signOut;

  SessionStatus _status = SessionStatus.unknown;
  UserSession? _session;

  SessionStatus get status => _status;
  UserSession? get session => _session;
  bool get isSignedIn => _status == SessionStatus.signedIn;

  Future<void> restore() async {
    _session = await _restore();
    _status = _session == null ? SessionStatus.signedOut : SessionStatus.signedIn;
    notifyListeners();
  }

  void signedIn(UserSession session) {
    _session = session;
    _status = SessionStatus.signedIn;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (_status == SessionStatus.signedOut) return;
    await _signOut();
    _session = null;
    _status = SessionStatus.signedOut;
    notifyListeners();
  }
}
