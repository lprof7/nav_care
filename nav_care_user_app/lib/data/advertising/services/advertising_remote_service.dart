import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/data/advertising/models/advertising_model.dart';

abstract class AdvertisingService {
  Future<Result<List<Advertising>>> getAdvertisings({String? position});
}

class AdvertisingRemoteService implements AdvertisingService {
  final ApiClient _apiClient;

  AdvertisingRemoteService({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Result<List<Advertising>>> getAdvertisings({String? position}) async {
    return _apiClient.get(
      _apiClient.apiConfig.getAdvertisings,
      query: {'position': position},
      parser: (dynamic data) {
        final List<dynamic> advertisingsJson = data['data']['advertisings'];
        return advertisingsJson
            .map((json) => Advertising.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
