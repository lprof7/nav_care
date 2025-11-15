import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart';

part 'appointment_model.freezed.dart';
part 'appointment_model.g.dart';

@freezed
class AppointmentModel with _$AppointmentModel {
  const factory AppointmentModel({
    required String id,
    required Patient patient,
    required Provider provider,
    required Service service,
    required String status,
    required String startTime,
    required String endTime,
    required double price,
  }) = _AppointmentModel;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);
}

@freezed
class Patient with _$Patient {
  const factory Patient({
    required String id,
    required String phone,
    required String name,
    required String email,
    required String profilePicture,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}

@freezed
class Provider with _$Provider {
  const factory Provider({
    required String id,
    required User user,
    required String specialty,
    required double rating,
    required String cover,
    @JsonKey(name: 'bio_en') String? bioEn,
    @JsonKey(name: 'bio_fr') String? bioFr,
    @JsonKey(name: 'bio_ar') String? bioAr,
    @JsonKey(name: 'bio_sp') String? bioSp,
    String? boost,
    String? boostType,
    String? boostExpiresAt,
  }) = _Provider;

  factory Provider.fromJson(Map<String, dynamic> json) =>
      _$ProviderFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String phone,
    required String name,
    required String email,
    required String profilePicture,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class Service with _$Service {
  const factory Service({
    required String name,
    required String provider,
    required String providerType,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);
}

@freezed
class AppointmentListModel with _$AppointmentListModel {
  const factory AppointmentListModel({
    required List<AppointmentModel> appointments,
    required Pagination pagination,
  }) = _AppointmentListModel;

  factory AppointmentListModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentListModelFromJson(json);
}
