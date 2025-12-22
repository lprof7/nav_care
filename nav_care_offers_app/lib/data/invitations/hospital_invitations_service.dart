import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';

abstract class HospitalInvitationsService {
  Future<Result<List<HospitalInvitation>>> fetchInvitations();
  Future<Result<HospitalInvitation>> createInvitation({
    required String doctorId,
    required String purpose,
  });
  Future<Result<HospitalInvitation>> cancelInvitation({
    required String invitationId,
  });
}
