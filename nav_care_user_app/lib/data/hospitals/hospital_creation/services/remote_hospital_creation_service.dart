import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nav_care_user_app/core/network/api_client.dart';
import 'package:nav_care_user_app/core/responses/result.dart';
import 'package:nav_care_user_app/core/utils/multipart_helper.dart';
import 'hospital_creation_service.dart';

class RemoteHospitalCreationService implements HospitalCreationService {
  final ApiClient _api;

  RemoteHospitalCreationService(this._api);

  @override
  Future<Result<Map<String, dynamic>>> createHospital(
    Map<String, dynamic> body,
  ) async {
    final payload = Map<String, dynamic>.from(body);
    final fileValue = payload.remove('file');
    final file = await MultipartHelper.toMultipartFile(
      fileValue,
      fallbackName: 'hospital-image',
    );

    final coordinates = payload.remove('coordinates');
    final phones = payload.remove('phone');

    final formData = FormData();

    if (payload.isNotEmpty) {
      payload.forEach((key, value) {
        if (value == null) return;
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    if (coordinates is Map) {
      final latitude = coordinates['latitude'];
      final longitude = coordinates['longitude'];
      if (latitude != null) {
        formData.fields.add(
          MapEntry('coordinates[latitude]', latitude.toString()),
        );
      }
      if (longitude != null) {
        formData.fields.add(
          MapEntry('coordinates[longitude]', longitude.toString()),
        );
      }
    } else if (coordinates != null) {
      formData.fields
          .add(MapEntry('coordinates', jsonEncode(coordinates).toString()));
    }

    if (phones is Iterable) {
      for (final phone in phones) {
        if (phone == null) continue;
        formData.fields.add(MapEntry('phone[]', phone.toString()));
      }
    } else if (phones != null) {
      formData.fields.add(MapEntry('phone[]', phones.toString()));
    }

    if (file != null) {
      formData.files.add(MapEntry('file', file));
    }

    return _api.post(
      _api.apiConfig.createHospital,
      body: formData,
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}
