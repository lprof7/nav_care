import 'models/doctor_model.dart';
import 'responses/fake_doctors_choice_response.dart';
import 'doctors_remote_service.dart';

class DoctorsRepository {
  final DoctorsRemoteService remoteService;

  DoctorsRepository({required this.remoteService});

  Future<List<DoctorModel>> getFakeNavcareDoctorsChoice() async {
    return FakeDoctorsChoiceResponse.getFakeDoctorsChoice();
  }

  Future<List<DoctorModel>> getNavcareDoctorsChoice({int limit = 6}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 20
            ? 20
            : limit;
    final result =
        await remoteService.listDoctors(page: 1, limit: requestLimit);

    if (!result.isSuccess || result.data == null) {
      final message =
          result.error?.message ?? 'Failed to load NavCare doctors.';
      throw Exception(message);
    }

    final payload = result.data!;
    if (payload['success'] != true) {
      throw Exception(_extractMessage(payload['message']) ??
          'Failed to load NavCare doctors.');
    }

    final data = payload['data'];
    final doctorsList = (data is Map<String, dynamic>)
        ? data['doctors'] as List<dynamic>? ?? const []
        : const <dynamic>[];

    return doctorsList
        .whereType<Map<String, dynamic>>()
        .map(DoctorModel.fromJson)
        .toList(growable: false);
  }

  String? _extractMessage(dynamic message) {
    if (message is String && message.isNotEmpty) {
      return message;
    }
    if (message is Map<String, dynamic>) {
      final localized = [
        message['ar'],
        message['fr'],
        message['en'],
      ].whereType<String>().firstWhere(
            (value) => value.isNotEmpty,
            orElse: () => '',
          );
      if (localized.isNotEmpty) {
        return localized;
      }
    }
    return null;
  }
}
