import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/service_offerings/service_offerings_repository.dart';

import 'service_offering_detail_state.dart';

class ServiceOfferingDetailCubit extends Cubit<ServiceOfferingDetailState> {
  ServiceOfferingDetailCubit({required ServiceOfferingsRepository repository})
      : _repository = repository,
        super(const ServiceOfferingDetailState());

  final ServiceOfferingsRepository _repository;

  Future<void> load(String offeringId) async {
    if (offeringId.isEmpty) {
      emit(state.copyWith(
        status: ServiceOfferingDetailStatus.failure,
        message: 'Invalid offering id',
      ));
      return;
    }

    emit(state.copyWith(status: ServiceOfferingDetailStatus.loading));
    try {
      final offering = await _repository.getServiceOfferingById(offeringId);
      emit(state.copyWith(
        status: ServiceOfferingDetailStatus.success,
        offering: offering,
      ));
      _loadRelated(offeringId);
    } catch (e) {
      emit(state.copyWith(
        status: ServiceOfferingDetailStatus.failure,
        message: e.toString(),
      ));
    }
  }

  Future<void> _loadRelated(String offeringId, {bool loadMore = false}) async {
    if (state.relatedStatus == RelatedOfferingsStatus.loading && !loadMore) return;
    if (loadMore && !state.hasMoreRelated) return;

    emit(state.copyWith(relatedStatus: RelatedOfferingsStatus.loading));

    try {
      final nextPage = loadMore ? state.relatedPage + 1 : 1;
      final related = await _repository.getRelatedServiceOfferings(offeringId, page: nextPage);

      emit(state.copyWith(
        relatedStatus: RelatedOfferingsStatus.success,
        relatedOfferings: loadMore
            ? [...state.relatedOfferings, ...related]
            : related,
        relatedPage: nextPage,
        hasMoreRelated: related.isNotEmpty,
      ));
    } catch (e) {
      emit(state.copyWith(
        relatedStatus: RelatedOfferingsStatus.failure,
        relatedMessage: e.toString(),
      ));
    }
  }

  void loadMoreRelated(String offeringId) {
    _loadRelated(offeringId, loadMore: true);
  }
}
