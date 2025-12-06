import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/core/responses/pagination.dart';
import 'package:nav_care_user_app/data/reviews/doctor_reviews/models/doctor_review_model.dart';

enum DoctorReviewsStatus { initial, loading, success, failure }

class DoctorReviewsState extends Equatable {
  final DoctorReviewsStatus status;
  final List<DoctorReviewModel> reviews;
  final PageMeta? pagination;
  final bool isLoadingMore;
  final String? message;
  final bool isSubmittingReview;
  final String? submitMessage;
  final bool submitSuccess;

  const DoctorReviewsState({
    this.status = DoctorReviewsStatus.initial,
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

  DoctorReviewsState copyWith({
    DoctorReviewsStatus? status,
    List<DoctorReviewModel>? reviews,
    PageMeta? pagination,
    bool? isLoadingMore,
    String? message,
    bool clearMessage = false,
    bool? isSubmittingReview,
    String? submitMessage,
    bool clearSubmitMessage = false,
    bool? submitSuccess,
  }) {
    return DoctorReviewsState(
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
