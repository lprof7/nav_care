import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/reviews/service_offering_reviews/models/service_offering_review_model.dart';
import 'package:nav_care_user_app/data/reviews/service_offering_reviews/service_offering_reviews_repository.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/viewmodel/service_offering_reviews_state.dart';

class ServiceOfferingReviewsCubit extends Cubit<ServiceOfferingReviewsState> {
  ServiceOfferingReviewsCubit({
    required ServiceOfferingReviewsRepository repository,
  })  : _repository = repository,
        super(const ServiceOfferingReviewsState());

  final ServiceOfferingReviewsRepository _repository;
  String? _offeringId;

  Future<void> loadReviews({
    required String offeringId,
    int page = 1,
    int limit = 10,
  }) async {
    _offeringId = offeringId;
    emit(state.copyWith(
      status: ServiceOfferingReviewsStatus.loading,
      isLoadingMore: false,
      clearMessage: true,
    ));
    await _fetch(page: page, limit: limit, append: false);
  }

  Future<void> loadMore({int limit = 10}) async {
    if (state.isLoadingMore || !state.hasMore || _offeringId == null) return;
    final nextPage = (state.pagination?.page ?? 1) + 1;
    emit(state.copyWith(isLoadingMore: true, clearMessage: true));
    await _fetch(page: nextPage, limit: limit, append: true);
  }

  Future<void> refresh({int limit = 10}) async {
    if (_offeringId == null) return;
    await loadReviews(offeringId: _offeringId!, page: 1, limit: limit);
  }

  Future<void> _fetch({
    required int page,
    required int limit,
    required bool append,
  }) async {
    final offeringId = _offeringId;
    if (offeringId == null) return;
    final current = append
        ? List<ServiceOfferingReviewModel>.of(state.reviews)
        : <ServiceOfferingReviewModel>[];
    try {
      final paged = await _repository.getReviews(
        offeringId: offeringId,
        page: page,
        limit: limit,
      );
      final newList = append
          ? <ServiceOfferingReviewModel>[...current, ...paged.items]
          : paged.items;
      emit(state.copyWith(
        status: ServiceOfferingReviewsStatus.success,
        reviews: newList,
        pagination: paged.meta,
        isLoadingMore: false,
        clearMessage: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: append ? state.status : ServiceOfferingReviewsStatus.failure,
        isLoadingMore: false,
        message: error.toString(),
      ));
    }
  }
}
