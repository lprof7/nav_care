import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart';
import 'package:nav_care_offers_app/data/reviews/doctor_reviews/models/doctor_review_model.dart';

enum DoctorReviewsStatus { initial, loading, success, failure }

class DoctorReviewsState extends Equatable {
  final DoctorReviewsStatus status;
  final List<DoctorReviewModel> reviews;
  final PageMeta? pagination;
  final bool isLoadingMore;
  final String? message;

  const DoctorReviewsState({
    this.status = DoctorReviewsStatus.initial,
    this.reviews = const [],
    this.pagination,
    this.isLoadingMore = false,
    this.message,
  });

  bool get hasMore {
    if (pagination == null) return false;
    return pagination!.page < pagination!.pages;
  }

  DoctorReviewsState copyWith({
    DoctorReviewsStatus? status,
    List<DoctorReviewModel>? reviews,
    PageMeta? pagination,
    bool? isLoadingMore,
    String? message,
    bool clearMessage = false,
  }) {
    return DoctorReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, reviews, pagination, isLoadingMore, message];
}
