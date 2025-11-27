import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart'; // Import Dio for DioExceptionType
import 'package:nav_care_user_app/core/config/app_config.dart'; // Import AppConfig

part 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  final Connectivity _connectivity;
  final AppConfig _appConfig; // Inject AppConfig instead of ApiClient
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Timer? _serverCheckTimer; // Add a timer for periodic server checks

  NetworkCubit({required Connectivity connectivity, required AppConfig appConfig})
      : _connectivity = connectivity,
        _appConfig = appConfig,
        super(const NetworkState(status: NetworkStatus.connected)) {
    _initConnectivity();
    _startServerCheckTimer(); // Start the periodic server check
  }

  Future<void> _initConnectivity() async {
    await _checkNetworkAndServerStatus();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) {
      _checkNetworkAndServerStatus();
    });
  }

  void _startServerCheckTimer() {
    _serverCheckTimer = Timer.periodic(const Duration(seconds:10), (_) {
      _checkNetworkAndServerStatus();
    });
  }

  Future<void> _checkNetworkAndServerStatus() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    bool isDeviceConnected = !connectivityResult.contains(ConnectivityResult.none);
    bool isServerReachable = false;

    if (isDeviceConnected) {
      try {
        // Create a minimal Dio instance for a lightweight server health check
        final dio = Dio(BaseOptions(
          baseUrl: _appConfig.api.baseUrl,
          connectTimeout: const Duration(seconds: 5), // Short timeout for health check
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ));
        await dio.get('/'); // Simple GET request to the base URL
        isServerReachable = true;
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout) {
          isServerReachable = false;
        } else {
          // Other Dio errors (e.g., 404, 500) mean the server is reachable but returned an error status
          isServerReachable = true;
        }
      } catch (e) {
        isServerReachable = false;
      }
    }

    NetworkStatus newStatus;
    if (!isDeviceConnected) {
      newStatus = NetworkStatus.noInternet;
    } else if (!isServerReachable) {
      newStatus = NetworkStatus.serverError;
    } else {
      newStatus = NetworkStatus.connected;
    }
    emit(state.copyWith(status: newStatus));
  }

  Future<void> recheckConnectivity() async {
    await _checkNetworkAndServerStatus();
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    _serverCheckTimer?.cancel(); // Cancel the timer
    return super.close();
  }
}