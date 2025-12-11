import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/core/responses/pagination.dart';
import 'package:nav_care_user_app/data/reviews/service_offering_reviews/models/service_offering_review_model.dart';

enum ServiceOfferingReviewsStatus { initial, loading, success, failure }

class ServiceOfferingReviewsState extends Equatable {
  final ServiceOfferingReviewsStatus status;
  final List<ServiceOfferingReviewModel> reviews;
  final PageMeta? pagination;
  final bool isLoadingMore;
  final String? message;
  final bool isSubmittingReview;
  final String? submitMessage;
  final bool submitSuccess;

  const ServiceOfferingReviewsState({
    this.status = ServiceOfferingReviewsStatus.initial,
    this.reviews = const [],
    this.pagination,
    this.isLoadingMore = false,
    this.message,
    this.isSubmittingReview = false,
    this.submitMessage,
    this.submitSuccess = false,
  });

  bool get hasMore {
    if (pagination == null) return false;
    return pagination!.page < pagination!.totalPages;
  }

  ServiceOfferingReviewsState copyWith({
    ServiceOfferingReviewsStatus? status,
    List<ServiceOfferingReviewModel>? reviews,
    PageMeta? pagination,
    bool? isLoadingMore,
    String? message,
    bool clearMessage = false,
    bool? isSubmittingReview,
    String? submitMessage,
    bool clearSubmitMessage = false,
    bool? submitSuccess,
  }) {
    return ServiceOfferingReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: clearMessage ? null : message ?? this.message,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      submitMessage:
          clearSubmitMessage ? null : submitMessage ?? this.submitMessage,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reviews,
        pagination,
        isLoadingMore,
        message,
        isSubmittingReview,
        submitMessage,
        submitSuccess,
      ];
}
