import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/services/services_repository.dart';
import 'recent_services_state.dart';

class RecentServicesCubit extends Cubit<RecentServicesState> {
  RecentServicesCubit({required ServicesRepository repository})
      : _repository = repository,
        super(const RecentServicesState());

  final ServicesRepository _repository;

  Future<void> loadRecentServices() async {
    emit(state.copyWith(status: RecentServicesStatus.loading));
    try {
      final services = await _repository.getFakeRecentlyAddedServices();
      emit(
        state.copyWith(
          status: RecentServicesStatus.loaded,
          services: services,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RecentServicesStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
