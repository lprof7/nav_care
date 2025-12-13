import 'package:nav_care_offers_app/core/network/api_client.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';
import 'faq_service.dart';

class RemoteFaqService implements FaqService {
  RemoteFaqService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<Map<String, dynamic>>> fetchFaq() {
    return _apiClient.get(
      _apiClient.apiConfig.faq,
      parser: (data) => data as Map<String, dynamic>,
    );
  }
}
