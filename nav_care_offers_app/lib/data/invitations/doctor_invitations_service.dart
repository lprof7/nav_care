import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/invitations/models/doctor_invitation.dart';

abstract class DoctorInvitationsService {
  Future<Result<List<DoctorInvitation>>> fetchInvitations();

  Future<Result<DoctorInvitation>> respondToInvitation({
    required String invitationId,
    required String decision,
  });
}
