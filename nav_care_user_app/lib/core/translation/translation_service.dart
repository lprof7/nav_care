import '../network/api_client.dart';
import '../responses/result.dart';

class TranslationService {
  final ApiClient _apiClient;

  TranslationService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Result<Map<String, String>>> translate(String text) {
    return _apiClient.post<Map<String, String>>(
      _apiClient.apiConfig.translateText,
      body: {'text': text},
      parser: _parseTranslations,
    );
  }

  Map<String, String> _parseTranslations(dynamic json) {
    if (json is! Map) return {};
    final result = json['result'];
    if (result is! Map) return {};

    final translations = <String, String>{};
    result.forEach((key, value) {
      if (value is! String) return;
      final langKey = key.toString();
      final normalizedKey =
          langKey.startsWith('text_') ? langKey.substring(5) : langKey;
      translations[normalizedKey] = value;
    });
    return translations;
  }
}
