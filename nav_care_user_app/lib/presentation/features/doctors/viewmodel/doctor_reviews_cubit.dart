import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/core/responses/pagination.dart';
import 'package:nav_care_user_app/data/reviews/doctor_reviews/doctor_reviews_repository.dart';
import 'package:nav_care_user_app/data/reviews/doctor_reviews/models/doctor_review_model.dart';
import 'package:nav_care_user_app/presentation/features/doctors/viewmodel/doctor_reviews_state.dart';

class DoctorReviewsCubit extends Cubit<DoctorReviewsState> {
  DoctorReviewsCubit({required DoctorReviewsRepository repository})
      : _repository = repository,
        super(const DoctorReviewsState());

  final DoctorReviewsRepository _repository;
  String? _doctorId;

  Future<void> loadReviews({
    required String doctorId,
    int page = 1,
    int limit = 10,
  }) async {
    _doctorId = doctorId;
    emit(state.copyWith(
      status: DoctorReviewsStatus.loading,
      isLoadingMore: false,
      clearMessage: true,
      isSubmittingReview: false,
      submitSuccess: false,
      clearSubmitMessage: true,
    ));
    await _fetch(page: page, limit: limit, append: false);
  }

  Future<void> loadMore({int limit = 10}) async {
    if (state.isLoadingMore || !state.hasMore || _doctorId == null) return;
    final nextPage = (state.pagination?.page ?? 1) + 1;
    emit(state.copyWith(isLoadingMore: true, clearMessage: true));
    await _fetch(page: nextPage, limit: limit, append: true);
  }

  Future<void> refresh({int limit = 10}) async {
    if (_doctorId == null) return;
    await loadReviews(doctorId: _doctorId!, page: 1, limit: limit);
  }

  Future<void> submitReview({
    required double rating,
    required String comment,
  }) async {
    final doctorId = _doctorId;
    if (doctorId == null) return;
    emit(state.copyWith(
      isSubmittingReview: true,
      submitSuccess: false,
      clearSubmitMessage: true,
    ));
    try {
      final result = await _repository.createDoctorReview(
        doctorId: doctorId,
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
        status: DoctorReviewsStatus.success,
        pagination: updatedMeta,
        isSubmittingReview: false,
        submitSuccess: true,
        submitMessage: 'doctors.reviews.submit_success',
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
    final doctorId = _doctorId;
    if (doctorId == null) return;
    final current = append ? List.of(state.reviews) : <DoctorReviewModel>[];
    try {
      final paged = await _repository.getDoctorReviews(
        doctorId: doctorId,
        page: page,
        limit: limit,
      );
      final newList = append ? [...current, ...paged.items] : paged.items;
      emit(state.copyWith(
        status: DoctorReviewsStatus.success,
        reviews: newList,
        pagination: paged.meta,
        isLoadingMore: false,
        clearMessage: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: append ? state.status : DoctorReviewsStatus.failure,
        isLoadingMore: false,
        message: error.toString(),
      ));
    }
  }
}
