import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

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
      final services =
          await _repository.getServices(page: 1, limit: 10);
      emit(
        state.copyWith(
          status: FeaturedServicesStatus.loaded,
          services: services.items,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FeaturedServicesStatus.failure,
          message: 'home.featured_services.error'.tr(),
        ),
      );
    }
  }
}
