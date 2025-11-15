import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/service_offerings/service_offerings_repository.dart';
import 'recent_service_offerings_state.dart';

class RecentServiceOfferingsCubit extends Cubit<RecentServiceOfferingsState> {
  RecentServiceOfferingsCubit({required ServiceOfferingsRepository repository})
      : _repository = repository,
        super(const RecentServiceOfferingsState());

  final ServiceOfferingsRepository _repository;

  Future<void> loadOfferings({int limit = 6}) async {
    emit(
      state.copyWith(
        status: RecentServiceOfferingsStatus.loading,
        message: null,
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
