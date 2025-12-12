import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart';
import 'package:nav_care_offers_app/data/reviews/hospital_reviews/models/hospital_review_model.dart';

enum HospitalReviewsStatus { initial, loading, success, failure }

class HospitalReviewsState extends Equatable {
  final HospitalReviewsStatus status;
  final List<HospitalReviewModel> reviews;
  final PageMeta? pagination;
  final bool isLoadingMore;
  final String? message;

  const HospitalReviewsState({
    this.status = HospitalReviewsStatus.initial,
    this.reviews = const [],
    this.pagination,
    this.isLoadingMore = false,
    this.message,
  });

  bool get hasMore {
    if (pagination == null) return false;
    return pagination!.page < pagination!.pages;
  }

  HospitalReviewsState copyWith({
    HospitalReviewsStatus? status,
    List<HospitalReviewModel>? reviews,
    PageMeta? pagination,
    bool? isLoadingMore,
    String? message,
    bool clearMessage = false,
  }) {
    return HospitalReviewsState(
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
