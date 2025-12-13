import 'package:nav_care_user_app/core/responses/result.dart';

abstract class FaqService {
  Future<Result<Map<String, dynamic>>> fetchFaq();
}
