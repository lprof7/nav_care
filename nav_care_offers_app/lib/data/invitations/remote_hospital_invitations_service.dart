import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/invitations/hospital_invitations_service.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';

class RemoteHospitalInvitationsService implements HospitalInvitationsService {
  final ApiClient _apiClient;

  RemoteHospitalInvitationsService(this._apiClient);

  @override
  Future<Result<List<HospitalInvitation>>> fetchInvitations() {
    return _apiClient.get<List<HospitalInvitation>>(
      _apiClient.apiConfig.hospitalInvitations,
      parser: _parseInvitations,
      useHospitalToken: true,
    );
  }

  List<HospitalInvitation> _parseInvitations(dynamic json) {
    if (json is Map<String, dynamic>) {
      final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
      final invitations = data?['invitations'];
      if (invitations is Iterable) {
        return invitations
            .whereType<Map>()
            .map((e) => HospitalInvitation.fromJson(
                e.map((key, value) => MapEntry(key.toString(), value))))
            .toList();
      }
    }
    return const [];
  }
}
