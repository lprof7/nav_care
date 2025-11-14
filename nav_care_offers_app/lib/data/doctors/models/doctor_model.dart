import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nav_care_offers_app/core/responses/pagination.dart';

part 'doctor_model.freezed.dart';
part 'doctor_model.g.dart';

@freezed
class DoctorModel with _$DoctorModel {
  const factory DoctorModel({
    required String id,
    required String name,
    // Add other doctor properties as they become known
  }) = _DoctorModel;

  factory DoctorModel.fromJson(Map<String, dynamic> json) => _$DoctorModelFromJson(json);
}

@freezed
class DoctorListModel with _$DoctorListModel {
  const factory DoctorListModel({
    required List<DoctorModel> data,
    required Pagination pagination,
  }) = _DoctorListModel;

  factory DoctorListModel.fromJson(Map<String, dynamic> json) => _$DoctorListModelFromJson(json);
}