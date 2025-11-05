part of 'hospital_form_cubit.dart';

class HospitalFormState extends Equatable {
  final Hospital? initialHospital;
  final bool isSubmitting;
  final Hospital? lastSaved;
  final bool submissionSuccess;
  final String? errorMessage;

  const HospitalFormState({
    this.initialHospital,
    this.isSubmitting = false,
    this.lastSaved,
    this.submissionSuccess = false,
    this.errorMessage,
  });

  bool get isEditing => initialHospital != null;

  HospitalFormState copyWith({
    Hospital? initialHospital,
    bool? isSubmitting,
    Hospital? lastSaved,
    bool? submissionSuccess,
    String? errorMessage,
  }) {
    return HospitalFormState(
      initialHospital: initialHospital ?? this.initialHospital,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastSaved: lastSaved ?? this.lastSaved,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        initialHospital,
        isSubmitting,
        lastSaved,
        submissionSuccess,
        errorMessage,
      ];
}
