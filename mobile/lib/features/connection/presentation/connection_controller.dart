import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/network_info.dart';

/// Состояние связи для A5. Связь есть, только когда у устройства есть сеть
/// И сервер последним запросом ответил.
class ConnectionController extends ChangeNotifier {
  ConnectionController({
    required this._network,
    required this._lastResponseAt,
    required Future<bool> Function() probeServer,
  })  : _probe = probeServer {
    _sub = _network.onStatusChange.listen((online) {
      _hasNetwork = online;
      notifyListeners();
    });
    _lastResponseAt.addListener(_onResponse);
    _network.isOnline.then((online) {
      _hasNetwork = online;
      notifyListeners();
    });
  }

  final NetworkInfo _network;
  final ValueListenable<DateTime?> _lastResponseAt;
  final Future<bool> Function() _probe;
  StreamSubscription<bool>? _sub;

  bool _hasNetwork = true;
  bool _serverReachable = true;
  bool _isChecking = false;

  bool get hasNetwork => _hasNetwork;
  bool get serverReachable => _serverReachable;
  bool get isOnline => _hasNetwork && _serverReachable;
  bool get isChecking => _isChecking;
  DateTime? get lastSyncAt => _lastResponseAt.value;

  void _onResponse() {
    if (!_serverReachable) {
      _serverReachable = true;
    }
    notifyListeners();
  }

  /// Запрос завершился без ответа сервера.
  void reportServerUnreachable() {
    if (!_serverReachable) return;
    _serverReachable = false;
    notifyListeners();
  }

  /// RETRY CONNECTION: true — связь восстановлена.
  Future<bool> retry() async {
    _isChecking = true;
    notifyListeners();
    _hasNetwork = await _network.isOnline;
    _serverReachable = _hasNetwork && await _probe();
    _isChecking = false;
    notifyListeners();
    return isOnline;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _lastResponseAt.removeListener(_onResponse);
    super.dispose();
  }
}
