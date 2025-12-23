part of 'doctor_invitations_cubit.dart';

enum DoctorInvitationsStatus { initial, loading, success, failure }

class DoctorInvitationsState extends Equatable {
  final DoctorInvitationsStatus status;
  final List<DoctorInvitation> invitations;
  final String? errorMessage;
  final Map<String, String> respondingDecisions;
  final String? feedbackMessage;
  final bool feedbackIsError;

  const DoctorInvitationsState({
    this.status = DoctorInvitationsStatus.initial,
    this.invitations = const [],
    this.errorMessage,
    this.respondingDecisions = const {},
    this.feedbackMessage,
    this.feedbackIsError = false,
  });

  int get pendingCount => invitations
      .where((inv) => inv.status.toLowerCase() == 'pending')
      .length;

  DoctorInvitationsState copyWith({
    DoctorInvitationsStatus? status,
    List<DoctorInvitation>? invitations,
    String? errorMessage,
    Map<String, String>? respondingDecisions,
    String? feedbackMessage,
    bool? feedbackIsError,
    bool clearFeedback = false,
  }) {
    return DoctorInvitationsState(
      status: status ?? this.status,
      invitations: invitations ?? this.invitations,
      errorMessage: errorMessage ?? this.errorMessage,
      respondingDecisions: respondingDecisions ?? this.respondingDecisions,
      feedbackMessage: clearFeedback ? null : feedbackMessage ?? this.feedbackMessage,
      feedbackIsError: clearFeedback ? false : feedbackIsError ?? this.feedbackIsError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        invitations,
        errorMessage,
        respondingDecisions,
        feedbackMessage,
        feedbackIsError,
      ];
}
