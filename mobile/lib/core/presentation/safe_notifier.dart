import 'package:flutter/foundation.dart';

/// ViewModel экрана может пережить сам экран: запрос ещё идёт, а
/// пользователь уже ушёл. После dispose уведомления молча игнорируются,
/// вместо «X was used after being disposed».
mixin SafeNotifier on ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
