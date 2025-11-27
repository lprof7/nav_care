part of 'network_cubit.dart';

enum NetworkStatus {
  connected,
  noInternet,
  serverError,
}

class NetworkState extends Equatable {
  final NetworkStatus status;

  const NetworkState({this.status = NetworkStatus.connected});

  NetworkState copyWith({
    NetworkStatus? status,
  }) {
    return NetworkState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}