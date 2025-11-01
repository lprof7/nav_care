import 'models/hospital_model.dart';
import 'responses/fake_featured_hospitals_response.dart';
import 'responses/fake_hospitals_choice_response.dart';
import 'hospitals_remote_service.dart';

class HospitalsRepository {
  // ignore: unused_field
  final HospitalsRemoteService _remoteService;

  HospitalsRepository({required HospitalsRemoteService remoteService})
      : _remoteService = remoteService;

  Future<List<HospitalModel>> getFakeNavcareHospitalsChoice() {
    return Future.value(FakeHospitalsChoiceResponse.getFakeHospitalsChoice());
  }

  Future<List<HospitalModel>> getNavcareHospitalsChoice({int limit = 6}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 20
            ? 20
            : limit;

    final hospitals = await getFakeNavcareHospitalsChoice();
    if (hospitals.isEmpty) {
      return hospitals;
    }

    final cappedLimit =
        requestLimit > hospitals.length ? hospitals.length : requestLimit;
    return hospitals.sublist(0, cappedLimit);
  }

  Future<List<HospitalModel>> getNavcareFeaturedHospitals({int limit = 3}) {
    return getFakeFeaturedHospitals(limit: limit);
  }

  Future<List<HospitalModel>> getNavcareFeaturedClinics({int limit = 6}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 15
            ? 15
            : limit;

    final hospitals = await getFakeNavcareHospitalsChoice();
    if (hospitals.isEmpty) {
      return hospitals;
    }

    final clinics = hospitals.where((hospital) {
      final facilityType = hospital.facilityType.trim().toLowerCase();
      final field = hospital.field.trim().toLowerCase();
      return facilityType.contains('clinic') || field.contains('clinic');
    }).toList(growable: false);

    if (clinics.isEmpty) {
      return clinics;
    }

    final sorted = [...clinics]..sort((a, b) => b.rating.compareTo(a.rating));
    final cappedLimit =
        requestLimit > sorted.length ? sorted.length : requestLimit;
    return sorted.sublist(0, cappedLimit);
  }

  Future<List<HospitalModel>> getFeaturedHospitals({int limit = 6}) {
    // TODO: replace with real API implementation
    throw UnimplementedError();
  }

  Future<List<HospitalModel>> getFakeFeaturedHospitals({int limit = 6}) async {
    final requestLimit = limit < 1
        ? 1
        : limit > 12
            ? 12
            : limit;

    final hospitals =
        FakeFeaturedHospitalsResponse.getFakeFeaturedHospitals();
    if (hospitals.isEmpty) {
      return hospitals;
    }

    final cappedLimit =
        requestLimit > hospitals.length ? hospitals.length : requestLimit;
    return hospitals.sublist(0, cappedLimit);
  }
}
