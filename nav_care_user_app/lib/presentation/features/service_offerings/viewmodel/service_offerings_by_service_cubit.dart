import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nav_care_user_app/data/services/services_repository.dart';

import 'service_offerings_by_service_state.dart';

class ServiceOfferingsByServiceCubit
    extends Cubit<ServiceOfferingsByServiceState> {
  ServiceOfferingsByServiceCubit(this._repository)
      : super(const ServiceOfferingsByServiceState());

  final ServicesRepository _repository;

  Future<void> loadOfferings(String serviceId) async {
    emit(state.copyWith(status: ServiceOfferingsByServiceStatus.loading));
    try {
      final paged =
          await _repository.getServiceOfferings(serviceId: serviceId, limit: 20);
      emit(
        state.copyWith(
          status: ServiceOfferingsByServiceStatus.success,
          offerings: paged.items,
          message: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ServiceOfferingsByServiceStatus.failure,
          message: 'services.offerings.error'.tr(),
        ),
      );
    }
  }
}
