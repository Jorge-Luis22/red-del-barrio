import 'package:connectivity_plus/connectivity_plus.dart';

import '../domain/connectivity_monitor.dart';

/// Informa del tipo de red del teléfono. No garantiza que haya internet de verdad:
/// en etapa 2 se complementa con una comprobación contra el servidor.
class ConnectivityPlusMonitor implements ConnectivityMonitor {
  ConnectivityPlusMonitor([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _hasNetwork(List<ConnectivityResult> r) =>
      r.any((e) => e != ConnectivityResult.none);

  @override
  Future<bool> get isOnline async => _hasNetwork(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onlineChanges =>
      _connectivity.onConnectivityChanged.map(_hasNetwork).distinct();
}
