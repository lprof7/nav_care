import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/data/faq/models/faq_item.dart';

import 'faq_service.dart';

class FaqRepository {
  FaqRepository(this._service);

  final FaqService _service;

  Future<Result<List<FaqItem>>> fetchFaq() async {
    final response = await _service.fetchFaq();
    return response.fold(
      onSuccess: (data) {
        final list = (data['data']?['faqs'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => FaqItem.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ))
            .toList();
        return Result.success(list);
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }
}
