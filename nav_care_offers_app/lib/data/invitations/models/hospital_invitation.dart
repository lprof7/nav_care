import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';

class HospitalInvitation {
  final String id;
  final String status;
  final String? purpose;
  final DoctorModel? inviteeDoctor;
  final String? invitedByName;

  HospitalInvitation({
    required this.id,
    required this.status,
    this.purpose,
    this.inviteeDoctor,
    this.invitedByName,
  });

  factory HospitalInvitation.fromJson(Map<String, dynamic> json) {
    final inviteeDoctorJson =
        json['inviteeDoctor'] is Map<String, dynamic> ? json['inviteeDoctor'] : null;
    final invitedBy = json['invitedBy'] is Map<String, dynamic> ? json['invitedBy'] : null;
    return HospitalInvitation(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      status: json['status']?.toString() ?? 'pending',
      purpose: json['purpose']?.toString(),
      inviteeDoctor: inviteeDoctorJson != null
          ? DoctorModel.fromJson(inviteeDoctorJson as Map<String, dynamic>)
          : null,
      invitedByName: invitedBy?['name']?.toString(),
    );
  }
}
