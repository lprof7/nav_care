import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart';

part 'clinic_model.freezed.dart';
part 'clinic_model.g.dart';

@freezed
class ClinicModel with _$ClinicModel {
  const factory ClinicModel({
    required String id,
    required String name,
    @Default([]) List<String> images,
    String? description,
    String? address,
    @Default([]) List<String> phones,
    // Add other clinic properties as they become known
  }) = _ClinicModel;

  factory ClinicModel.fromJson(Map<String, dynamic> json) =>
      _$ClinicModelFromJson(json);
}

@freezed
class ClinicListModel with _$ClinicListModel {
  const factory ClinicListModel({
    required List<ClinicModel> data,
    required Pagination pagination,
  }) = _ClinicListModel;

  factory ClinicListModel.fromJson(Map<String, dynamic> json) =>
      _$ClinicListModelFromJson(json);
}
