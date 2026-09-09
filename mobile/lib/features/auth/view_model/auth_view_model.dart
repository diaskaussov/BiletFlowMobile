import 'package:flutter/foundation.dart';
import 'package:mobile/features/auth/view_model/auth_exception.dart';
import 'package:mobile/models/auth_session.dart';
import 'package:mobile/repositories/auth_repository.dart';

final class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo);
  final AuthRepository _repo; 

  bool _isLoading = false;
  String? _error;
  AuthSession? _session;
  String _email = '';
  String _password = '';
  bool _isPasswordHidden = true;
  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthSession? get session => _session;
  bool get isSignedIn => _session != null;
  bool get canSubmit => 
    _email.trim().isNotEmpty && _password.isNotEmpty && !_isLoading;
  bool get isPasswordHidden => _isPasswordHidden;
  bool get isEmailValid => _emailPattern.hasMatch(_email.trim());

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

  Future<void> signIn() async {
    if (!canSubmit) return;
    if (!isEmailValid) {
      _error = 'Enter a valid email address.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    clearError();

    try {
      _session = await _repo.signIn(
        email: _email.trim(), 
        password: _password
      );
    } on AuthException catch (error) {
      _error = error.message;
    } on Exception {
      _error = 'Something went wrong. Try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _session = null;
    _email = '';
    _password = '';
    _error = null;
    notifyListeners();
  }
}