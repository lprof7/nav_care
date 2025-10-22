import 'service_model.dart';

class ServiceCreationResult {
  final ServiceModel? service;
  final String message;

  ServiceCreationResult({
    this.service,
    required this.message,
  });
}
