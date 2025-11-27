import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/service_offerings/service_offerings_repository.dart';

import 'service_offering_detail_state.dart';

class ServiceOfferingDetailCubit extends Cubit<ServiceOfferingDetailState> {
  ServiceOfferingDetailCubit({required ServiceOfferingsRepository repository})
      : _repository = repository,
        super(const ServiceOfferingDetailState());

  final ServiceOfferingsRepository _repository;

  Future<void> load(String offeringId) async {
    if (offeringId.isEmpty) {
      emit(state.copyWith(
        status: ServiceOfferingDetailStatus.failure,
        message: 'Invalid offering id',
      ));
      return;
    }

    emit(state.copyWith(status: ServiceOfferingDetailStatus.loading));
    try {
      final offering = await _repository.getServiceOfferingById(offeringId);
      print("offering id is $offeringId");
      print("offering name is ${offering?.service.fallbackName}");
      print("offering price is ${offering?.descriptionEn}");


      emit(state.copyWith(
        status: ServiceOfferingDetailStatus.success,
        offering: offering,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServiceOfferingDetailStatus.failure,
        message: e.toString(),
      ));
    }
  }
}
