import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/service_offerings/service_offerings_repository.dart';
import 'recent_service_offerings_state.dart';

class RecentServiceOfferingsCubit extends Cubit<RecentServiceOfferingsState> {
  RecentServiceOfferingsCubit({required ServiceOfferingsRepository repository})
      : _repository = repository,
        super(const RecentServiceOfferingsState());

  final ServiceOfferingsRepository _repository;

  Future<void> loadOfferings({int limit = 10}) async {
    emit(
      state.copyWith(
        status: RecentServiceOfferingsStatus.loading,
        message: null,
        page: 1,
        hasNextPage: true,
      ),
    );
    try {
      final paged = await _repository.getRecentServiceOfferings(
        page: 1,
        limit: limit,
      );
      emit(
        state.copyWith(
          status: RecentServiceOfferingsStatus.loaded,
          offerings: paged.items,
          message: null,
          page: 1,
          hasNextPage: paged.meta?.hasNextPage ?? false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RecentServiceOfferingsStatus.failure,
          message: null,
        ),
      );
    }
  }

  Future<void> loadMoreOfferings({int limit = 10}) async {
    if (!state.hasNextPage || state.status == RecentServiceOfferingsStatus.loading) {
      return;
    }
    emit(state.copyWith(status: RecentServiceOfferingsStatus.loading));

    try {
      final nextPage = state.page + 1;
      final paged = await _repository.getRecentServiceOfferings(
        page: nextPage,
        limit: limit,
      );
      emit(
        state.copyWith(
          status: RecentServiceOfferingsStatus.loaded,
          offerings: List.of(state.offerings)..addAll(paged.items),
          page: nextPage,
          hasNextPage: paged.meta?.hasNextPage ?? false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RecentServiceOfferingsStatus.failure,
          message: null,
        ),
      );
    }
  }
}
