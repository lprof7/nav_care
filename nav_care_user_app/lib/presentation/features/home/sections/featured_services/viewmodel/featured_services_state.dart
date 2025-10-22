import 'package:equatable/equatable.dart';

import '../../../../../../data/services/models/service_model.dart';

enum FeaturedServicesStatus { initial, loading, loaded, failure }

class FeaturedServicesState extends Equatable {
  final FeaturedServicesStatus status;
  final List<ServiceModel> services;
  final String? message;

  const FeaturedServicesState({
    this.status = FeaturedServicesStatus.initial,
    this.services = const [],
    this.message,
  });

  FeaturedServicesState copyWith({
    FeaturedServicesStatus? status,
    List<ServiceModel>? services,
    String? message,
  }) {
    return FeaturedServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, services, message];
}
