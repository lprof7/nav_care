part of 'hospital_detail_cubit.dart';

enum HospitalDetailStatus { initial, loading, success, failure }

class HospitalDetailState extends Equatable {
  final Hospital hospital;
  final HospitalDetailStatus status;
  final List<ClinicModel> clinics;
  final List<DoctorModel> doctors;
  final List<ServiceOffering> offerings;
  final bool isRefreshing;
  final bool isDeleting;
  final bool isDeleted;
  final String? errorMessage;
  final String? successMessageKey;
  final bool isFetchingToken;
  final String? hospitalToken;

  const HospitalDetailState({
    required this.hospital,
    this.status = HospitalDetailStatus.initial,
    this.clinics = const [],
    this.doctors = const [],
    this.offerings = const [],
    this.isRefreshing = false,
    this.isDeleting = false,
    this.isDeleted = false,
    this.errorMessage,
    this.successMessageKey,
    this.isFetchingToken = false,
    this.hospitalToken,
  });

  HospitalDetailState copyWith({
    Hospital? hospital,
    HospitalDetailStatus? status,
    List<ClinicModel>? clinics,
    List<DoctorModel>? doctors,
    List<ServiceOffering>? offerings,
    bool? isRefreshing,
    bool? isDeleting,
    bool? isDeleted,
    String? errorMessage,
    String? successMessageKey,
    bool? isFetchingToken,
    String? hospitalToken,
    bool clearMessages = false,
  }) {
    return HospitalDetailState(
      hospital: hospital ?? this.hospital,
      status: status ?? this.status,
      clinics: clinics ?? this.clinics,
      doctors: doctors ?? this.doctors,
      offerings: offerings ?? this.offerings,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isDeleting: isDeleting ?? this.isDeleting,
      isDeleted: isDeleted ?? this.isDeleted,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessageKey:
          clearMessages ? null : successMessageKey ?? this.successMessageKey,
      isFetchingToken: isFetchingToken ?? this.isFetchingToken,
      hospitalToken: hospitalToken ?? this.hospitalToken,
    );
  }

  @override
  List<Object?> get props => [
        hospital,
        status,
        clinics,
        doctors,
        offerings,
        isRefreshing,
        isDeleting,
        isDeleted,
        errorMessage,
        successMessageKey,
        isFetchingToken,
        hospitalToken,
      ];
}
