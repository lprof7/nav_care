import 'models/doctor_model.dart';
import 'responses/fake_doctors_choice_response.dart';
import 'doctors_remote_service.dart';

class DoctorsRepository {
  // ignore: unused_field
  final DoctorsRemoteService _remoteService;

  DoctorsRepository({required DoctorsRemoteService remoteService})
      : _remoteService = remoteService;

  Future<List<DoctorModel>> getFakeNavcareDoctorsChoice() {
    return Future.value(FakeDoctorsChoiceResponse.getFakeDoctorsChoice());
  }

  Future<List<DoctorModel>> getNavcareDoctorsChoice({int limit = 6}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 20
            ? 20
            : limit;
    final doctors = await getFakeNavcareDoctorsChoice();
    if (doctors.isEmpty) {
      return doctors;
    }

    final cappedLimit =
        requestLimit > doctors.length ? doctors.length : requestLimit;
    return doctors.sublist(0, cappedLimit);
  }

  Future<List<DoctorModel>> getNavcareFeaturedDoctors({int limit = 3}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 10
            ? 10
            : limit;
    final doctors = await getFakeNavcareDoctorsChoice();
    if (doctors.isEmpty) {
      return doctors;
    }

    final sorted = [...doctors]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final cappedLimit =
        requestLimit > sorted.length ? sorted.length : requestLimit;
    return sorted.sublist(0, cappedLimit);
  }
}
