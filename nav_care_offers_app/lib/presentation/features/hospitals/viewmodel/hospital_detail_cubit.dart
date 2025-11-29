import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/storage/token_store.dart';
import 'package:nav_care_offers_app/data/clinics/clinics_repository.dart';
import 'package:nav_care_offers_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_offers_app/data/doctors/doctors_repository.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/hospitals/hospitals_repository.dart';
import 'package:nav_care_offers_app/data/hospitals/models/hospital.dart';
import 'package:nav_care_offers_app/data/service_offerings/models/service_offering.dart';
import 'package:nav_care_offers_app/data/service_offerings/service_offerings_repository.dart';
import 'package:nav_care_offers_app/data/invitations/hospital_invitations_repository.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';

part 'hospital_detail_state.dart';

class HospitalDetailCubit extends Cubit<HospitalDetailState> {
  HospitalDetailCubit(
    this._repository,
    this._tokenStore, {
    required Hospital initialHospital,
    required ClinicsRepository clinicsRepository,
    required DoctorsRepository doctorsRepository,
    required ServiceOfferingsRepository offeringsRepository,
    required HospitalInvitationsRepository invitationsRepository,
  })  : _clinicsRepository = clinicsRepository,
        _doctorsRepository = doctorsRepository,
        _offeringsRepository = offeringsRepository,
        _invitationsRepository = invitationsRepository,
        super(HospitalDetailState(hospital: initialHospital));

  final HospitalsRepository _repository;
  final TokenStore _tokenStore;
  final ClinicsRepository _clinicsRepository;
  final DoctorsRepository _doctorsRepository;
  final ServiceOfferingsRepository _offeringsRepository;
  final HospitalInvitationsRepository _invitationsRepository;

  void refreshFromRepository() {
    final updated = _repository.findById(state.hospital.id);
    if (updated != null) {
      emit(state.copyWith(hospital: updated));
    }
  }

  void updateHospital(Hospital hospital) {
    emit(state.copyWith(hospital: hospital));
  }

  Future<void> loadDetails({bool refresh = false}) async {
    emit(
      state.copyWith(
        status: HospitalDetailStatus.loading,
        isRefreshing: refresh,
        isFetchingToken: true,
        clearMessages: true,
      ),
    );

    refreshFromRepository();

    final token = await _fetchHospitalToken();
    if (token == null) return;

    String? failureMessage;
    final clinicsResult =
        await _clinicsRepository.getHospitalClinics(state.hospital.id);
    final doctorsResult =
        await _doctorsRepository.getHospitalDoctors(state.hospital.id);
    final offeringsResult = await _offeringsRepository.fetchMyOfferings();
    final invitationsResult = await _invitationsRepository.fetchInvitations();

    final clinics = clinicsResult.fold(
      onFailure: (failure) {
        failureMessage ??= failure.message;
        return state.clinics;
      },
      onSuccess: (data) => data.data,
    );

    final doctors = doctorsResult.fold(
      onFailure: (failure) {
        failureMessage ??= failure.message;
        return state.doctors;
      },
      onSuccess: (data) => data.data,
    );

    final offerings = offeringsResult.fold(
      onFailure: (failure) {
        failureMessage ??= failure.message;
        return state.offerings;
      },
      onSuccess: (data) => data.offerings,
    );

    final invitations = invitationsResult.fold(
      onFailure: (failure) {
        failureMessage ??= failure.message;
        return state.invitations;
      },
      onSuccess: (data) => data,
    );

    emit(
      state.copyWith(
        status: failureMessage == null
            ? HospitalDetailStatus.success
            : HospitalDetailStatus.failure,
        clinics: clinics,
        doctors: doctors,
        offerings: offerings,
        invitations: invitations,
        isRefreshing: false,
        clearMessages: true,
        errorMessage: failureMessage,
      ),
    );
  }

  Future<void> deleteHospital() async {
    emit(state.copyWith(
        isDeleting: true, errorMessage: null, successMessageKey: null));
    final result = await _repository.deleteHospital(state.hospital.id);
    result.fold(
      onFailure: (failure) => emit(state.copyWith(
        isDeleting: false,
        errorMessage: failure.message,
      )),
      onSuccess: (_) => emit(
        state.copyWith(
          isDeleting: false,
          isDeleted: true,
          successMessageKey: 'hospitals.detail.delete_success',
        ),
      ),
    );
  }

  Future<String?> _fetchHospitalToken() async {
    final result = await _repository.accessHospitalToken(state.hospital.id);
    String? token;
    result.fold(
      onFailure: (failure) => emit(
        state.copyWith(
          status: HospitalDetailStatus.failure,
          isFetchingToken: false,
          isRefreshing: false,
          errorMessage: failure.message,
        ),
      ),
      onSuccess: (value) {
        token = value;
        _tokenStore.setHospitalToken(value);
      },
    );
    emit(state.copyWith(
      hospitalToken: token ?? state.hospitalToken,
      isFetchingToken: false,
    ));
    return token;
  }
}
