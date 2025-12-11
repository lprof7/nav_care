import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/doctors/doctors_repository.dart';
import 'recent_doctors_state.dart';

class RecentDoctorsCubit extends Cubit<RecentDoctorsState> {
  RecentDoctorsCubit({required DoctorsRepository repository})
      : _repository = repository,
        super(const RecentDoctorsState());

  final DoctorsRepository _repository;
  int _currentLimit = 6;

  Future<void> loadDoctors({int limit = 6}) async {
    _currentLimit = limit;
    emit(
      state.copyWith(
        status: RecentDoctorsStatus.loading,
        message: null,
        page: 1,
        hasNextPage: true,
      ),
    );

    try {
      final paged =
          await _repository.getRecentDoctors(page: 1, limit: _currentLimit);
      emit(
        state.copyWith(
          status: RecentDoctorsStatus.loaded,
          doctors: paged.items,
          page: 1,
          hasNextPage: paged.meta?.hasNextPage ?? false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RecentDoctorsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> loadMoreDoctors() async {
    if (!state.hasNextPage || state.status == RecentDoctorsStatus.loading) {
      return;
    }

    emit(state.copyWith(status: RecentDoctorsStatus.loading));

    try {
      final nextPage = state.page + 1;
      final paged = await _repository.getRecentDoctors(
        page: nextPage,
        limit: _currentLimit,
      );

      emit(
        state.copyWith(
          status: RecentDoctorsStatus.loaded,
          doctors: List.of(state.doctors)..addAll(paged.items),
          page: nextPage,
          hasNextPage: paged.meta?.hasNextPage ?? false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RecentDoctorsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
