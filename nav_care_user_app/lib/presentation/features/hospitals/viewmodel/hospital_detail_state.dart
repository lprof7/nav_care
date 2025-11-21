import 'package:equatable/equatable.dart';
import 'package:nav_care_user_app/data/clinics/models/clinic_model.dart';
import 'package:nav_care_user_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_user_app/data/hospitals/models/hospital_model.dart';
import 'package:nav_care_user_app/data/service_offerings/models/service_offering_model.dart';

enum HospitalDetailStatus { initial, loading, success, failure }

class HospitalDetailState extends Equatable {
  final HospitalDetailStatus status;
  final HospitalModel? hospital;
  final List<ClinicModel> clinics;
  final List<DoctorModel> doctors;
  final List<ServiceOfferingModel> offerings;
  final String? message;

  const HospitalDetailState({
    this.status = HospitalDetailStatus.initial,
    this.hospital,
    this.clinics = const [],
    this.doctors = const [],
    this.offerings = const [],
    this.message,
  });

  HospitalDetailState copyWith({
    HospitalDetailStatus? status,
    HospitalModel? hospital,
    List<ClinicModel>? clinics,
    List<DoctorModel>? doctors,
    List<ServiceOfferingModel>? offerings,
    String? message,
    bool clearMessage = false,
  }) {
    return HospitalDetailState(
      status: status ?? this.status,
      hospital: hospital ?? this.hospital,
      clinics: clinics ?? this.clinics,
      doctors: doctors ?? this.doctors,
      offerings: offerings ?? this.offerings,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props =>
      [status, hospital, clinics, doctors, offerings, message];
}
