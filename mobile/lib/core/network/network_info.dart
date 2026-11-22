import 'package:connectivity_plus/connectivity_plus.dart';

/// Есть ли у устройства сеть. Наличие сети ещё не значит, что сервер
/// доступен — это видно по [NetworkFailure] от запросов.
abstract interface class NetworkInfo {
  Future<bool> get isOnline;

  Stream<bool> get onStatusChange;
}

class ConnectivityNetworkInfo implements NetworkInfo {
  ConnectivityNetworkInfo([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isOnline async =>
      _hasNetwork(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_hasNetwork).distinct();

  static bool _hasNetwork(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
