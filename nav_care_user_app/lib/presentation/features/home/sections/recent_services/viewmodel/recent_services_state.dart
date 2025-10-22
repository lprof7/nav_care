import 'package:equatable/equatable.dart';

import '../../../../../../data/services/models/service_model.dart';

enum RecentServicesStatus { initial, loading, loaded, failure }

class RecentServicesState extends Equatable {
  final RecentServicesStatus status;
  final List<ServiceModel> services;
  final String? message;

  const RecentServicesState({
    this.status = RecentServicesStatus.initial,
    this.services = const [],
    this.message,
  });

  RecentServicesState copyWith({
    RecentServicesStatus? status,
    List<ServiceModel>? services,
    String? message,
  }) {
    return RecentServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, services, message];
}
