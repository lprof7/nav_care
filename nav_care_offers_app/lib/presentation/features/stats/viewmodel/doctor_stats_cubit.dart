import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/stats/doctor_stats_repository.dart';

import 'doctor_stats_state.dart';

class DoctorStatsCubit extends Cubit<DoctorStatsState> {
  DoctorStatsCubit(this._repository)
      : super(const DoctorStatsState.initial());

  final DoctorStatsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: DoctorStatsStatus.loading, failure: null));
    final result = await _repository.fetchDoctorStats();
    result.fold(
      onSuccess: (stats) => emit(
        state.copyWith(status: DoctorStatsStatus.success, stats: stats),
      ),
      onFailure: (failure) => emit(
        state.copyWith(status: DoctorStatsStatus.failure, failure: failure),
      ),
    );
  }
}
