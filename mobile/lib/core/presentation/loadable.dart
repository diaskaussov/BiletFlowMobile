import 'package:flutter/foundation.dart';

import '../error/failure.dart';
import '../error/result.dart';

/// Состояние экрана «загрузить и показать»: загрузка, данные, ошибка.
/// ViewModel'и наследуются от него и добавляют свои действия.
class Loadable<T> extends ChangeNotifier {
  Loadable(this._fetch);

  final Future<Result<T>> Function() _fetch;

  T? _data;
  Failure? _failure;
  bool _isLoading = false;
  bool _disposed = false;

  T? get data => _data;
  Failure? get failure => _failure;
  bool get isLoading => _isLoading;
  bool get hasData => _data != null;

  Future<void> load() async {
    _isLoading = true;
    _failure = null;
    _notify();
    final result = await _fetch();
    switch (result) {
      case Ok(:final value):
        _data = value;
      case Err(:final failure):
        _failure = failure;
    }
    _isLoading = false;
    _notify();
  }

  /// Заменить данные после действия, не перезагружая с сервера.
  @protected
  void setData(T value) {
    _data = value;
    _notify();
  }

  /// Выполнить действие и вернуть ошибку (null — успех). Пока идёт —
  /// [isBusy] = true, чтобы экран заблокировал кнопки.
  Future<Failure?> run<R>(
    Future<Result<R>> Function() action, {
    void Function(R value)? onOk,
    bool reload = false,
  }) async {
    if (_isBusy) return null;
    _isBusy = true;
    _notify();
    final r = await action();
    _isBusy = false;
    Failure? failure;
    switch (r) {
      case Ok(:final value):
        onOk?.call(value);
      case Err(failure: final f):
        failure = f;
    }
    _notify();
    if (failure == null && reload) await load();
    return failure;
  }

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
