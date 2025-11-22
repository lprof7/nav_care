import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';

enum ServiceOfferingDetailStatus { initial, loading, success, failure }

class ServiceOfferingDetailState extends Equatable {
  final ServiceOfferingDetailStatus status;
  final ServiceOfferingModel? offering;
  final String? message;

  const ServiceOfferingDetailState({
    this.status = ServiceOfferingDetailStatus.initial,
    this.offering,
    this.message,
  });

  ServiceOfferingDetailState copyWith({
    ServiceOfferingDetailStatus? status,
    ServiceOfferingModel? offering,
    String? message,
  }) {
    return ServiceOfferingDetailState(
      status: status ?? this.status,
      offering: offering ?? this.offering,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, offering, message];
}
