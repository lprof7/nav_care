import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/stats/hospital_stats_repository.dart';

import 'hospital_stats_state.dart';

class HospitalStatsCubit extends Cubit<HospitalStatsState> {
  HospitalStatsCubit(this._repository)
      : super(const HospitalStatsState.initial());

  final HospitalStatsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: HospitalStatsStatus.loading, failure: null));
    final result = await _repository.fetchHospitalStats();
    result.fold(
      onSuccess: (stats) => emit(
        state.copyWith(status: HospitalStatsStatus.success, stats: stats),
      ),
      onFailure: (failure) => emit(
        state.copyWith(status: HospitalStatsStatus.failure, failure: failure),
      ),
    );
  }
}
