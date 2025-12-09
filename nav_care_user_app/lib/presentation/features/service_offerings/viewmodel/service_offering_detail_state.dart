import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';

enum ServiceOfferingDetailStatus { initial, loading, success, failure }

enum RelatedOfferingsStatus { initial, loading, success, failure }

class ServiceOfferingDetailState extends Equatable {
  final ServiceOfferingDetailStatus status;
  final ServiceOfferingModel? offering;
  final String? message;
  final RelatedOfferingsStatus relatedStatus;
  final List<ServiceOfferingModel> relatedOfferings;
  final String? relatedMessage;
  final int relatedPage;
  final bool hasMoreRelated;

  const ServiceOfferingDetailState({
    this.status = ServiceOfferingDetailStatus.initial,
    this.offering,
    this.message,
    this.relatedStatus = RelatedOfferingsStatus.initial,
    this.relatedOfferings = const [],
    this.relatedMessage,
    this.relatedPage = 1,
    this.hasMoreRelated = true,
  });

  ServiceOfferingDetailState copyWith({
    ServiceOfferingDetailStatus? status,
    ServiceOfferingModel? offering,
    String? message,
    RelatedOfferingsStatus? relatedStatus,
    List<ServiceOfferingModel>? relatedOfferings,
    String? relatedMessage,
    int? relatedPage,
    bool? hasMoreRelated,
  }) {
    return ServiceOfferingDetailState(
      status: status ?? this.status,
      offering: offering ?? this.offering,
      message: message ?? this.message,
      relatedStatus: relatedStatus ?? this.relatedStatus,
      relatedOfferings: relatedOfferings ?? this.relatedOfferings,
      relatedMessage: relatedMessage ?? this.relatedMessage,
      relatedPage: relatedPage ?? this.relatedPage,
      hasMoreRelated: hasMoreRelated ?? this.hasMoreRelated,
    );
  }

  @override
  List<Object?> get props => [
        status,
        offering,
        message,
        relatedStatus,
        relatedOfferings,
        relatedMessage,
        relatedPage,
        hasMoreRelated,
      ];
}
