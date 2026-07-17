import 'dart:async';

import 'package:injectable/injectable.dart';

import '../network/network_info.dart';

/// Broadcasts a single app-wide "are we online" stream that the
/// SyncEngine (and any UI banner like "Working offline — N changes
/// pending") subscribes to, instead of every feature independently
/// polling connectivity_plus.
@lazySingleton
class ConnectivityService {
  ConnectivityService(this._networkInfo) {
    _sub = _networkInfo.onConnectivityChanged.listen(_controller.add);
  }

  final NetworkInfo _networkInfo;
  final _controller = StreamController<bool>.broadcast();
  late final StreamSubscription<bool> _sub;

  Stream<bool> get onStatusChanged => _controller.stream;

  Future<bool> get isOnlineNow => _networkInfo.isConnected;

  void dispose() {
    _sub.cancel();
    _controller.close();
  }
}
