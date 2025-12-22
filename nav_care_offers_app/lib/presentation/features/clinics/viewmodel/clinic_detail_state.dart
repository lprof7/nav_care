part of 'clinic_detail_cubit.dart';

enum ClinicDetailStatus { initial, loading, success, failure }

class ClinicDetailState extends Equatable {
  final Hospital hospital;
  final ClinicDetailStatus status;
  final List<ClinicModel> clinics;
  final List<DoctorModel> doctors;
  final List<ServiceOffering> offerings;
  final List<HospitalInvitation> invitations;
  final bool isRefreshing;
  final bool isDeleting;
  final bool isDeleted;
  final String? errorMessage;
  final String? successMessageKey;
  final bool isFetchingToken;
  final String? clinicToken;
  final bool isFetchingClinics;

  const ClinicDetailState({
    required this.hospital,
    this.status = ClinicDetailStatus.initial,
    this.clinics = const [],
    this.doctors = const [],
    this.offerings = const [],
    this.invitations = const [],
    this.isRefreshing = false,
    this.isDeleting = false,
    this.isDeleted = false,
    this.errorMessage,
    this.successMessageKey,
    this.isFetchingToken = false,
    this.clinicToken,
    this.isFetchingClinics = false,
  });

  ClinicDetailState copyWith({
    Hospital? hospital,
    ClinicDetailStatus? status,
    List<ClinicModel>? clinics,
    List<DoctorModel>? doctors,
    List<ServiceOffering>? offerings,
    List<HospitalInvitation>? invitations,
    bool? isRefreshing,
    bool? isDeleting,
    bool? isDeleted,
    String? errorMessage,
    String? successMessageKey,
    bool? isFetchingToken,
    String? clinicToken,
    bool? isFetchingClinics,
    bool clearMessages = false,
  }) {
    return ClinicDetailState(
      hospital: hospital ?? this.hospital,
      status: status ?? this.status,
      clinics: clinics ?? this.clinics,
      doctors: doctors ?? this.doctors,
      offerings: offerings ?? this.offerings,
      invitations: invitations ?? this.invitations,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isDeleting: isDeleting ?? this.isDeleting,
      isDeleted: isDeleted ?? this.isDeleted,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessageKey:
          clearMessages ? null : successMessageKey ?? this.successMessageKey,
      isFetchingToken: isFetchingToken ?? this.isFetchingToken,
      clinicToken: clinicToken ?? this.clinicToken,
      isFetchingClinics: isFetchingClinics ?? this.isFetchingClinics,
    );
  }

  @override
  List<Object?> get props => [
        hospital,
        status,
        clinics,
        doctors,
        offerings,
        invitations,
        isRefreshing,
        isDeleting,
        isDeleted,
        errorMessage,
        successMessageKey,
        isFetchingToken,
        clinicToken,
        isFetchingClinics,
      ];
}
