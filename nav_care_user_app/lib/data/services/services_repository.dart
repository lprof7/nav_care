import 'models/service_model.dart';
import 'responses/fake_featured_services_response.dart';
import 'responses/fake_recently_added_services_response.dart';
import 'services_remote_service.dart';

class ServicesRepository {
  final ServicesRemoteService remoteService;

  ServicesRepository({required this.remoteService});

  Future<List<ServiceModel>> getFakeFeaturedServices() async {
    return FakeFeaturedServicesResponse.getFakeFeaturedServices();
  }

  Future<List<ServiceModel>> getFeaturedServices() async {
    // TODO: Implement real fetching logic when the backend is ready.
    return Future.error(
      UnimplementedError('getFeaturedServices is not implemented yet'),
    );
  }

  Future<List<ServiceModel>> getFakeRecentlyAddedServices() async {
    return FakeRecentlyAddedServicesResponse.getFakeRecentlyAddedServices();
  }

  Future<List<ServiceModel>> getRecentlyAddedServices() async {
    return Future.error(
      UnimplementedError('getRecentlyAddedServices is not implemented yet'),
    );
  }
}
