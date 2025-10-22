import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/services/models/service_model.dart';
import '../../../../../../data/services/services_repository.dart';
import 'featured_services_state.dart';

class FeaturedServicesCubit extends Cubit<FeaturedServicesState> {
  FeaturedServicesCubit({required ServicesRepository repository})
      : _repository = repository,
        super(const FeaturedServicesState());

  final ServicesRepository _repository;

  Future<void> loadFeaturedServices() async {
    emit(state.copyWith(status: FeaturedServicesStatus.loading));
    try {
      final List<ServiceModel> services =
          await _repository.getFakeFeaturedServices();
      emit(
        state.copyWith(
          status: FeaturedServicesStatus.loaded,
          services: services,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FeaturedServicesStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
