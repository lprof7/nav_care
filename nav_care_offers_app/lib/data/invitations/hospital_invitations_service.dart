import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';

abstract class HospitalInvitationsService {
  Future<Result<List<HospitalInvitation>>> fetchInvitations();
}
