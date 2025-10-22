import 'package:nav_care_user_app/core/responses/failure.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/data/service_creation/models/service_creation_result.dart';
import 'package:nav_care_user_app/data/service_creation/models/service_model.dart';

import 'services/service_creation_service.dart';

class ServiceCreationRepository {
  final ServiceCreationService _serviceCreationService;

  ServiceCreationRepository(this._serviceCreationService);

  Future<Result<ServiceCreationResult>> createService(
    Map<String, dynamic> body,
  ) async {
    final result = await _serviceCreationService.createService(body);

    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      final data = response['data'];
      final message =
          response['message']?.toString() ?? 'Service created successfully';

      ServiceModel? service;
      if (data is Map<String, dynamic>) {
        try {
          service = ServiceModel.fromJson(data);
        } catch (_) {
          service = null;
        }
      }

      return Result.success(
        ServiceCreationResult(service: service, message: message),
      );
    }

    return Result.failure(result.error ?? const Failure.unknown());
  }
}
