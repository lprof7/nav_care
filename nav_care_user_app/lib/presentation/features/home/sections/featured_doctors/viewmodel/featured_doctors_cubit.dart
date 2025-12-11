import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/doctors/doctors_repository.dart';
import 'featured_doctors_state.dart';

class FeaturedDoctorsCubit extends Cubit<FeaturedDoctorsState> {
  FeaturedDoctorsCubit({required DoctorsRepository repository})
      : _repository = repository,
        super(const FeaturedDoctorsState());

  final DoctorsRepository _repository;
  int _currentLimit = 6;

  Future<void> loadDoctors() async {
    emit(
      state.copyWith(
        status: FeaturedDoctorsStatus.loading,
        message: null,
        page: 1,
        hasNextPage: true,
      ),
    );

    try {
      final paged = await _repository.getFeaturedDoctors(
        page: 1,
        limit: _currentLimit,
      );

      emit(
        state.copyWith(
          status: FeaturedDoctorsStatus.loaded,
          doctors: paged.items,
          page: 1,
          hasNextPage: paged.meta?.hasNextPage ?? false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FeaturedDoctorsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> loadMoreDoctors() async {
    if (!state.hasNextPage || state.status == FeaturedDoctorsStatus.loading) {
      return;
    }

    emit(state.copyWith(status: FeaturedDoctorsStatus.loading));

    try {
      final nextPage = state.page + 1;
      final paged = await _repository.getFeaturedDoctors(
        page: nextPage,
        limit: _currentLimit,
      );

      emit(
        state.copyWith(
          status: FeaturedDoctorsStatus.loaded,
          doctors: List.of(state.doctors)..addAll(paged.items),
          page: nextPage,
          hasNextPage: paged.meta?.hasNextPage ?? false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FeaturedDoctorsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
