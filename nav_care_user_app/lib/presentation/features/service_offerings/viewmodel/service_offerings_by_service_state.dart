import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';

enum ServiceOfferingsByServiceStatus { initial, loading, success, failure }

class ServiceOfferingsByServiceState extends Equatable {
  final ServiceOfferingsByServiceStatus status;
  final List<ServiceOfferingModel> offerings;
  final String? message;

  const ServiceOfferingsByServiceState({
    this.status = ServiceOfferingsByServiceStatus.initial,
    this.offerings = const [],
    this.message,
  });

  ServiceOfferingsByServiceState copyWith({
    ServiceOfferingsByServiceStatus? status,
    List<ServiceOfferingModel>? offerings,
    String? message,
  }) {
    return ServiceOfferingsByServiceState(
      status: status ?? this.status,
      offerings: offerings ?? this.offerings,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, offerings, message];
}
