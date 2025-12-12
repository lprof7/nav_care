import 'package:equatable/equatable.dart';

enum NetworkStatus {
  connected,
  noInternet,
  serverError,
}

class NetworkState extends Equatable {
  final NetworkStatus status;
  final bool canShowError;

  const NetworkState({
    this.status = NetworkStatus.connected,
    this.canShowError = false,
  });

  NetworkState copyWith({
    NetworkStatus? status,
    bool? canShowError,
  }) {
    return NetworkState(
      status: status ?? this.status,
      canShowError: canShowError ?? this.canShowError,
    );
  }

  @override
  List<Object?> get props => [status, canShowError];
}
