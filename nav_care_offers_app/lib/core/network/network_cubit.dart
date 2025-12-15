import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';

import 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  final Connectivity _connectivity;
  final AppConfig _appConfig;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Timer? _serverCheckTimer;
  Timer? _errorDelayTimer;

  NetworkCubit({
    required Connectivity connectivity,
    required AppConfig appConfig,
  })  : _connectivity = connectivity,
        _appConfig = appConfig,
        super(const NetworkState(status: NetworkStatus.connected)) {
    _initConnectivity();
    _startServerCheckTimer();
    _startErrorDelayTimer();
  }

  Future<void> _initConnectivity() async {
    await _checkNetworkAndServerStatus();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((_) {
      _checkNetworkAndServerStatus();
    });
  }

  void _startServerCheckTimer() {
    _serverCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkNetworkAndServerStatus();
    });
  }

  void _startErrorDelayTimer() {
    _errorDelayTimer?.cancel();
    _errorDelayTimer = Timer(const Duration(seconds: 10), () {
      emit(state.copyWith(canShowError: true));
    });
  }

  Future<void> _checkNetworkAndServerStatus() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isDeviceConnected =
        !connectivityResult.contains(ConnectivityResult.none);
    var isServerReachable = false;

    if (isDeviceConnected) {
      try {
        final dio = Dio(
          BaseOptions(
            baseUrl: _appConfig.api.baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            sendTimeout: const Duration(seconds: 5),
          ),
        );
        // Hit a lightweight public endpoint instead of root to avoid false server errors.
        await dio.get('/api/faq');
        isServerReachable = true;
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          isServerReachable = false;
        } else {
          isServerReachable = true;
        }
      } catch (_) {
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
    emit(state.copyWith(canShowError: false));
    _startErrorDelayTimer();
    await _checkNetworkAndServerStatus();
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    _serverCheckTimer?.cancel();
    _errorDelayTimer?.cancel();
    return super.close();
  }
}
