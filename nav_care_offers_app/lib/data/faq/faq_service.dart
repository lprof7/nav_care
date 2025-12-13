import 'package:nav_care_offers_app/core/responses/result.dart';

abstract class FaqService {
  Future<Result<Map<String, dynamic>>> fetchFaq();
}
