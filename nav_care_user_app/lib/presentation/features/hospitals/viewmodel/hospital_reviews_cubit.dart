import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/responses/pagination.dart';
import 'package:nav_care_user_app/data/reviews/hospital_reviews/hospital_reviews_repository.dart';
import 'package:nav_care_user_app/data/reviews/hospital_reviews/models/hospital_review_model.dart';
import 'package:nav_care_user_app/presentation/features/hospitals/viewmodel/hospital_reviews_state.dart';

class HospitalReviewsCubit extends Cubit<HospitalReviewsState> {
  HospitalReviewsCubit({required HospitalReviewsRepository repository})
      : _repository = repository,
        super(const HospitalReviewsState());

  final HospitalReviewsRepository _repository;
  String? _hospitalId;

  Future<void> loadReviews({
    required String hospitalId,
    int page = 1,
    int limit = 10,
  }) async {
    _hospitalId = hospitalId;
    emit(state.copyWith(
      status: HospitalReviewsStatus.loading,
      isLoadingMore: false,
      clearMessage: true,
      isSubmittingReview: false,
      submitSuccess: false,
      clearSubmitMessage: true,
    ));
    await _fetch(page: page, limit: limit, append: false);
  }

  Future<void> loadMore({int limit = 10}) async {
    if (state.isLoadingMore || !state.hasMore || _hospitalId == null) return;
    final nextPage = (state.pagination?.page ?? 1) + 1;
    emit(state.copyWith(isLoadingMore: true, clearMessage: true));
    await _fetch(page: nextPage, limit: limit, append: true);
  }

  Future<void> refresh({int limit = 10}) async {
    if (_hospitalId == null) return;
    await loadReviews(hospitalId: _hospitalId!, page: 1, limit: limit);
  }

  Future<void> submitReview({
    required double rating,
    required String comment,
  }) async {
    final hospitalId = _hospitalId;
    if (hospitalId == null) return;
    emit(state.copyWith(
      isSubmittingReview: true,
      submitSuccess: false,
      clearSubmitMessage: true,
    ));
    try {
      final result = await _repository.createHospitalReview(
        hospitalId: hospitalId,
        rating: rating,
        comment: comment,
      );
      final updatedList = [result.review, ...state.reviews];
      final meta = state.pagination;
      final updatedMeta = meta != null
          ? PageMeta(
              page: 1,
              pageSize: meta.pageSize,
              total: meta.total + 1,
              totalPages: meta.totalPages,
            )
          : null;

      emit(state.copyWith(
        reviews: updatedList,
        status: HospitalReviewsStatus.success,
        pagination: updatedMeta,
        isSubmittingReview: false,
        submitSuccess: true,
        submitMessage: 'hospitals.reviews.submit_success',
      ));
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        isSubmittingReview: false,
        submitSuccess: false,
        submitMessage: message,
      ));
    }
  }

  Future<void> _fetch({
    required int page,
    required int limit,
    required bool append,
  }) async {
    final hospitalId = _hospitalId;
    if (hospitalId == null) return;
    final current =
        append ? List.of(state.reviews) : <HospitalReviewModel>[];
    try {
      final paged = await _repository.getHospitalReviews(
        hospitalId: hospitalId,
        page: page,
        limit: limit,
      );
      final newList = append ? [...current, ...paged.items] : paged.items;
      emit(state.copyWith(
        status: HospitalReviewsStatus.success,
        reviews: newList,
        pagination: paged.meta,
        isLoadingMore: false,
        clearMessage: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: append ? state.status : HospitalReviewsStatus.failure,
        isLoadingMore: false,
        message: error.toString(),
      ));
    }
  }
}
