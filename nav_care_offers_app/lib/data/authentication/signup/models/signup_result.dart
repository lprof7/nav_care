import 'package:nav_care_offers_app/data/authentication/models.dart';

class SignupResult {
  final User? user;
  final String? token;
  final String message;

  SignupResult({
    this.user,
    this.token,
    required this.message,
  });
}
