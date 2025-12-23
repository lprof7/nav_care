import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/data/invitations/doctor_invitations_repository.dart';
import 'package:nav_care_offers_app/data/invitations/models/doctor_invitation.dart';

part 'doctor_invitations_state.dart';

class DoctorInvitationsCubit extends Cubit<DoctorInvitationsState> {
  DoctorInvitationsCubit(this._repository)
      : super(const DoctorInvitationsState());

  final DoctorInvitationsRepository _repository;

  Future<void> load({bool refresh = false}) async {
    if (state.status == DoctorInvitationsStatus.loading && !refresh) return;
    emit(state.copyWith(
      status: DoctorInvitationsStatus.loading,
      errorMessage: null,
    ));

    final result = await _repository.fetchInvitations();
    result.fold(
      onFailure: (failure) => emit(state.copyWith(
        status: DoctorInvitationsStatus.failure,
        errorMessage: failure.message,
      )),
      onSuccess: (invitations) => emit(state.copyWith(
        status: DoctorInvitationsStatus.success,
        invitations: invitations,
      )),
    );
  }

  Future<void> respond({
    required DoctorInvitation invitation,
    required String decision,
  }) async {
    if (state.respondingDecisions.containsKey(invitation.id)) return;
    final responding = Map<String, String>.from(state.respondingDecisions);
    responding[invitation.id] = decision;
    emit(state.copyWith(respondingDecisions: responding, clearFeedback: true));

    final result = await _repository.respondToInvitation(
      invitationId: invitation.id,
      decision: decision,
    );

    if (isClosed) return;

    result.fold(
      onFailure: (failure) {
        final next = Map<String, String>.from(state.respondingDecisions);
        next.remove(invitation.id);
        emit(state.copyWith(
          respondingDecisions: next,
          feedbackMessage: failure.message,
          feedbackIsError: true,
        ));
      },
      onSuccess: (updated) {
        final next = Map<String, String>.from(state.respondingDecisions);
        next.remove(invitation.id);
        final updatedList = state.invitations
            .map((item) => item.id == invitation.id ? updated : item)
            .toList();
        emit(state.copyWith(
          respondingDecisions: next,
          invitations: updatedList,
          feedbackMessage: decision == 'accepted'
              ? 'doctor_invitations.accept_success'
              : 'doctor_invitations.decline_success',
          feedbackIsError: false,
        ));
      },
    );
  }

  void clearFeedback() {
    emit(state.copyWith(clearFeedback: true));
  }

  void reset() {
    emit(const DoctorInvitationsState());
  }
}
