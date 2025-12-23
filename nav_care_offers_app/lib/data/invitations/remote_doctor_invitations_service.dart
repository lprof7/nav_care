import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'package:nav_care_offers_app/data/invitations/doctor_invitations_service.dart';
import 'package:nav_care_offers_app/data/invitations/models/doctor_invitation.dart';

class RemoteDoctorInvitationsService implements DoctorInvitationsService {
  final ApiClient _apiClient;

  RemoteDoctorInvitationsService(this._apiClient);

  @override
  Future<Result<List<DoctorInvitation>>> fetchInvitations() {
    return _apiClient.get<List<DoctorInvitation>>(
      _apiClient.apiConfig.doctorInvitations,
      parser: _parseInvitations,
      useDoctorToken: true,
    );
  }

  @override
  Future<Result<DoctorInvitation>> respondToInvitation({
    required String invitationId,
    required String decision,
  }) {
    return _apiClient.patch<DoctorInvitation>(
      _apiClient.apiConfig.doctorInvitationsRespond,
      body: {
        'invitationId': invitationId,
        'decision': decision,
      },
      parser: _parseInvitation,
      useDoctorToken: true,
    );
  }

  List<DoctorInvitation> _parseInvitations(dynamic json) {
    if (json is Map<String, dynamic>) {
      final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
      final invitations = data?['invitations'];
      if (invitations is Iterable) {
        return invitations
            .whereType<Map>()
            .map((e) => DoctorInvitation.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                  baseUrl: _apiClient.apiConfig.baseUrl,
                ))
            .toList();
      }
    }
    return const [];
  }

  DoctorInvitation _parseInvitation(dynamic json) {
    if (json is Map<String, dynamic>) {
      final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
      final invitation = data?['invitation'];
      if (invitation is Map) {
        return DoctorInvitation.fromJson(
          invitation.map((key, value) => MapEntry(key.toString(), value)),
          baseUrl: _apiClient.apiConfig.baseUrl,
        );
      }
    }
    return DoctorInvitation(
      id: '',
      status: 'pending',
      hospitalId: '',
      hospitalName: 'Facility',
    );
  }
}
