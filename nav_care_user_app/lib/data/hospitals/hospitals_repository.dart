import 'models/hospital_model.dart';
import 'responses/fake_hospitals_choice_response.dart';
import 'hospitals_remote_service.dart';

class HospitalsRepository {
  final HospitalsRemoteService remoteService;

  HospitalsRepository({required this.remoteService});

  int _normalizeLimit(int limit) {
    if (limit < 1) return 1;
    if (limit > 20) return 20;
    return limit;
  }

  Future<List<HospitalModel>> getFakeNavcareHospitalsChoice() async {
    return FakeHospitalsChoiceResponse.getFakeHospitalsChoice();
  }

  Future<List<HospitalModel>> getNavcareHospitalsChoice({int limit = 6}) async {
    final requestLimit = _normalizeLimit(limit);
    final result =
        await remoteService.listHospitals(page: 1, limit: requestLimit);

    if (!result.isSuccess || result.data == null) {
      final errorMessage =
          result.error?.message ?? 'Failed to load NavCare hospitals.';
      throw Exception(errorMessage);
    }

    final payload = result.data!;
    final success = payload['success'] == true;
    if (!success) {
      throw Exception(_extractMessage(payload['message']) ??
          'Failed to load NavCare hospitals.');
    }

    final List hospitalsData;

    if (payload['data'] is Map<String, dynamic>) {
      final data = payload['data'] as Map<String, dynamic>;
      if (data['hospitals'] is Map<String, dynamic>) {
        final hospitals = data['hospitals'] as Map<String, dynamic>;
        hospitalsData = hospitals['data'] as List<dynamic>? ?? const [];
      } else {
        hospitalsData = const <dynamic>[];
      }
    } else {
      hospitalsData = const <dynamic>[];
    }

    return hospitalsData
        .whereType<Map<String, dynamic>>()
        .map(HospitalModel.fromJson)
        .toList(growable: false);
  }

  Future<List<HospitalModel>> getCombinedNavcareHospitalsChoice({
    int limit = 6,
  }) async {
    final normalizedLimit = _normalizeLimit(limit);

    // --- FAKE DATA (temporary stub - remove once API stabilizes) ---
    final fakeHospitals = await getFakeNavcareHospitalsChoice();

    List<HospitalModel> apiHospitals = const [];
    Exception? remoteFailure;

    try {
      // --- API DATA (remote source) ---
      apiHospitals = await getNavcareHospitalsChoice(limit: normalizedLimit);
    } catch (error) {
      remoteFailure = error is Exception ? error : Exception(error.toString());
    }

    final merged = <String, HospitalModel>{};
    for (final hospital in apiHospitals) {
      merged[hospital.id] = hospital;
    }
    for (final hospital in fakeHospitals) {
      merged.putIfAbsent(hospital.id, () => hospital);
    }

    final hospitals = merged.values.toList(growable: false);
    if (normalizedLimit > 0 && hospitals.length > normalizedLimit) {
      return hospitals.take(normalizedLimit).toList(growable: false);
    }

    if (hospitals.isEmpty && remoteFailure != null) {
      throw remoteFailure;
    }

    return hospitals;
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
