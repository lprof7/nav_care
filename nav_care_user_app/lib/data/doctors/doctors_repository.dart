import 'models/doctor_model.dart';
import 'doctors_remote_service.dart';
import 'responses/fake_doctors_choice_response.dart';
import 'responses/fake_featured_doctors_response.dart';

class DoctorsRepository {
  final DoctorsRemoteService remoteService;

  DoctorsRepository({required this.remoteService});

  Future<List<DoctorModel>> getFakeNavcareDoctorsChoice() {
    return Future.value(FakeDoctorsChoiceResponse.getFakeDoctorsChoice());
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

    final doctorMaps = _extractDoctorMaps(result.data);
    if (doctorMaps.isEmpty) {
      return const [];
    }

    return doctorMaps
        .take(requestLimit)
        .map(DoctorModel.fromJson)
        .toList(growable: false);
  }

  Future<List<DoctorModel>> getNavcareFeaturedDoctors({int limit = 3}) async {
    try {
      return await getFeaturedDoctors(limit: limit);
    } on UnimplementedError {
      return getFakeFeaturedDoctors(limit: limit);
    }
  }

  Future<List<DoctorModel>> getFeaturedDoctors({int limit = 6}) {
    // TODO: connect to remote service once endpoint is available
    throw UnimplementedError();
  }

  Future<List<DoctorModel>> getFakeFeaturedDoctors({int limit = 6}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 12
            ? 12
            : limit;

    final doctors = FakeFeaturedDoctorsResponse.getFakeFeaturedDoctors();
    if (doctors.isEmpty) {
      return doctors;
    }

    final sorted = [...doctors]..sort((a, b) => b.rating.compareTo(a.rating));
    final cappedLimit =
        requestLimit > sorted.length ? sorted.length : requestLimit;
    return sorted.sublist(0, cappedLimit);
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

  List<Map<String, dynamic>> _extractDoctorMaps(dynamic source) {
    if (source is List) {
      return source
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
    }

    if (source is Map<String, dynamic>) {
      const candidateKeys = ['data', 'doctors', 'docs', 'items', 'results'];
      for (final key in candidateKeys) {
        if (!source.containsKey(key)) continue;
        final extracted = _extractDoctorMaps(source[key]);
        if (extracted.isNotEmpty) {
          return extracted;
        }
      }

      // Fallback: inspect nested map values
      for (final value in source.values) {
        final extracted = _extractDoctorMaps(value);
        if (extracted.isNotEmpty) {
          return extracted;
        }
      }
    }

    return <Map<String, dynamic>>[];
  }
}
