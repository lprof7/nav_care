part of 'hospital_detail_cubit.dart';

class HospitalDetailState extends Equatable {
  final Hospital hospital;
  final bool isDeleting;
  final bool isDeleted;
  final String? errorMessage;
  final String? successMessageKey;

  const HospitalDetailState({
    required this.hospital,
    this.isDeleting = false,
    this.isDeleted = false,
    this.errorMessage,
    this.successMessageKey,
  });

  HospitalDetailState copyWith({
    Hospital? hospital,
    bool? isDeleting,
    bool? isDeleted,
    String? errorMessage,
    String? successMessageKey,
  }) {
    return HospitalDetailState(
      hospital: hospital ?? this.hospital,
      isDeleting: isDeleting ?? this.isDeleting,
      isDeleted: isDeleted ?? this.isDeleted,
      errorMessage: errorMessage,
      successMessageKey: successMessageKey,
    );
  }

  @override
  List<Object?> get props => [
        hospital,
        isDeleting,
        isDeleted,
        errorMessage,
        successMessageKey,
      ];
}
