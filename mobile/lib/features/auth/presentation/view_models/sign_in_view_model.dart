import 'package:flutter/foundation.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/sign_in.dart';
import '../controllers/session_controller.dart';
import '../../../../core/presentation/safe_notifier.dart';
import '../../../../core/error/failure.dart';

class SignInViewModel extends ChangeNotifier with SafeNotifier {
  SignInViewModel({required this._signIn, required this._session});

  final SignIn _signIn;
  final SessionController _session;

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _isPasswordHidden = true;
  Failure? _error;

  bool get isLoading => _isLoading;
  bool get isPasswordHidden => _isPasswordHidden;
  Failure? get error => _error;
  bool get canSubmit =>
      _email.trim().isNotEmpty && _password.isNotEmpty && !_isLoading;

  void setEmail(String value) {
    _email = value;
    _error = null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordHidden = !_isPasswordHidden;
    notifyListeners();
  }

  Future<void> submit() async {
    if (!canSubmit) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _signIn(email: _email, password: _password);

    _isLoading = false;
    switch (result) {
      case Ok(:final value):
        _session.signedIn(value);
      case Err(:final failure):
        _error = failure;
    }
    notifyListeners();
  }
}
