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

  @override
  Future<Result<HospitalInvitation>> createInvitation({
    required String doctorId,
    required String purpose,
  }) {
    return _apiClient.post<HospitalInvitation>(
      _apiClient.apiConfig.hospitalInvitations,
      body: {
        'doctorId': doctorId,
        'purpose': purpose,
      },
      parser: _parseInvitation,
      useHospitalToken: true,
    );
  }

  @override
  Future<Result<HospitalInvitation>> cancelInvitation({
    required String invitationId,
  }) {
    final path = '${_apiClient.apiConfig.hospitalInvitations}/$invitationId';
    return _apiClient.patch<HospitalInvitation>(
      path,
      body: const {'status': 'cancelled'},
      parser: _parseUpdatedInvitation,
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

  HospitalInvitation _parseInvitation(dynamic json) {
    if (json is Map<String, dynamic>) {
      final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
      final invitation = data?['invitation'];
      if (invitation is Map) {
        return HospitalInvitation.fromJson(
            invitation.map((key, value) => MapEntry(key.toString(), value)));
      }
      if (data is Map) {
        return HospitalInvitation.fromJson(
            data.map((key, value) => MapEntry(key.toString(), value)));
      }
    }
    return HospitalInvitation(id: '', status: 'pending');
  }

  HospitalInvitation _parseUpdatedInvitation(dynamic json) {
    if (json is Map<String, dynamic>) {
      final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
      final invitation = data?['updatedInvitation'];
      if (invitation is Map) {
        return HospitalInvitation.fromJson(
            invitation.map((key, value) => MapEntry(key.toString(), value)));
      }
      if (data is Map) {
        return HospitalInvitation.fromJson(
            data.map((key, value) => MapEntry(key.toString(), value)));
      }
    }
    return HospitalInvitation(id: '', status: 'cancelled');
  }
}
