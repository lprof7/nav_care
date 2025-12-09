import 'package:dio/dio.dart';
import 'package:nav_care_offers_app/core/responses/result.dart';

abstract class BecomeDoctorService {
  Future<Result<Map<String, dynamic>>> becomeDoctor(FormData body);
}
