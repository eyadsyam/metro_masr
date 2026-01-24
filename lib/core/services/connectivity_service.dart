import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity Service
/// Monitors network connectivity and provides offline/online status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true;

  /// Get current connectivity status
  bool get isConnected => _isConnected;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        print('Connectivity error: $error');
        _isConnected = false;
        _connectivityController?.add(false);
      },
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Check if any connection type is available
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      _connectivityController?.add(_isConnected);
      print('Connectivity changed: ${_isConnected ? "Online" : "Offline"}');
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController?.close();
  }
}
