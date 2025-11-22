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
      print("offering price is ${offering?.price}");
      print("offering rating is ${offering?.provider.rating}");
      print("offering email is ${offering?.provider.user.email}");
      print("offering phone is ${offering?.provider.user.phone}");
      print("offering specialty is ${offering?.provider.specialty}");
      print("offering bio is ${offering?.provider.bioEn}");
      print("offering image is ${offering?.service.image}");

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
