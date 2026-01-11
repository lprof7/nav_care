import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';

enum ServiceOfferingsByServiceStatus { initial, loading, success, failure }

class ServiceOfferingsByServiceState extends Equatable {
  final ServiceOfferingsByServiceStatus status;
  final List<ServiceOfferingModel> offerings;
  final String? message;
  final int page;
  final bool hasNextPage;
  final bool isLoadingMore;

  const ServiceOfferingsByServiceState({
    this.status = ServiceOfferingsByServiceStatus.initial,
    this.offerings = const [],
    this.message,
    this.page = 1,
    this.hasNextPage = true,
    this.isLoadingMore = false,
  });

  ServiceOfferingsByServiceState copyWith({
    ServiceOfferingsByServiceStatus? status,
    List<ServiceOfferingModel>? offerings,
    String? message,
    int? page,
    bool? hasNextPage,
    bool? isLoadingMore,
  }) {
    return ServiceOfferingsByServiceState(
      status: status ?? this.status,
      offerings: offerings ?? this.offerings,
      message: message ?? this.message,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [status, offerings, message, page, hasNextPage, isLoadingMore];
}
