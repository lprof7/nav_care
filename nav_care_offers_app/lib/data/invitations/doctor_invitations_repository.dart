import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/invitations/doctor_invitations_service.dart';
import 'package:nav_care_offers_app/data/invitations/models/doctor_invitation.dart';

class DoctorInvitationsRepository {
  final DoctorInvitationsService _service;

  DoctorInvitationsRepository(this._service);

  Future<Result<List<DoctorInvitation>>> fetchInvitations() {
    return _service.fetchInvitations();
  }

  Future<Result<DoctorInvitation>> respondToInvitation({
    required String invitationId,
    required String decision,
  }) {
    return _service.respondToInvitation(
      invitationId: invitationId,
      decision: decision,
    );
  }
}
