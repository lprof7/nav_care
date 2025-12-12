import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/reviews/hospital_reviews/hospital_reviews_repository.dart';
import 'package:nav_care_offers_app/data/reviews/hospital_reviews/models/hospital_review_model.dart';
import 'hospital_reviews_state.dart';

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

  Future<void> _fetch({
    required int page,
    required int limit,
    required bool append,
  }) async {
    final hospitalId = _hospitalId;
    if (hospitalId == null) return;
    try {
      final paged = await _repository.getHospitalReviews(
        hospitalId: hospitalId,
        page: page,
        limit: limit,
      );
      final existing = append
          ? List<HospitalReviewModel>.of(state.reviews)
          : <HospitalReviewModel>[];
      final newList = append ? [...existing, ...paged.items] : paged.items;
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
        message: error.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
