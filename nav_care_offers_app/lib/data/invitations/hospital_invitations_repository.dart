import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/invitations/hospital_invitations_service.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';

class HospitalInvitationsRepository {
  final HospitalInvitationsService _service;

  HospitalInvitationsRepository(this._service);

  Future<Result<List<HospitalInvitation>>> fetchInvitations() {
    return _service.fetchInvitations();
  }

  Future<Result<HospitalInvitation>> createInvitation({
    required String doctorId,
    required String purpose,
  }) {
    return _service.createInvitation(doctorId: doctorId, purpose: purpose);
  }

  Future<Result<HospitalInvitation>> cancelInvitation({
    required String invitationId,
  }) {
    return _service.cancelInvitation(invitationId: invitationId);
  }
}
