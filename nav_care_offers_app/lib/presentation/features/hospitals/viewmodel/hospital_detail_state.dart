part of 'hospital_detail_cubit.dart';

class HospitalDetailState extends Equatable {
  final Hospital hospital;
  final bool isDeleting;
  final bool isDeleted;
  final String? errorMessage;
  final String? successMessageKey;
  final bool isFetchingToken;
  final String? hospitalToken;

  const HospitalDetailState({
    required this.hospital,
    this.isDeleting = false,
    this.isDeleted = false,
    this.errorMessage,
    this.successMessageKey,
    this.isFetchingToken = false,
    this.hospitalToken,
  });

  HospitalDetailState copyWith({
    Hospital? hospital,
    bool? isDeleting,
    bool? isDeleted,
    String? errorMessage,
    String? successMessageKey,
    bool? isFetchingToken,
    String? hospitalToken,
  }) {
    return HospitalDetailState(
      hospital: hospital ?? this.hospital,
      isDeleting: isDeleting ?? this.isDeleting,
      isDeleted: isDeleted ?? this.isDeleted,
      errorMessage: errorMessage,
      successMessageKey: successMessageKey,
      isFetchingToken: isFetchingToken ?? this.isFetchingToken,
      hospitalToken: hospitalToken ?? this.hospitalToken,
    );
  }

  @override
  List<Object?> get props => [
        hospital,
        isDeleting,
        isDeleted,
        errorMessage,
        successMessageKey,
        isFetchingToken,
        hospitalToken,
      ];
}
