// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClinicModelImpl _$$ClinicModelImplFromJson(Map<String, dynamic> json) =>
    _$ClinicModelImpl(
      id: json['_id'] as String,
      name: json['name'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      description: json['description'] as String?,
      address: json['address'] as String?,
      phones: (json['phones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ClinicModelImplToJson(_$ClinicModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'images': instance.images,
      'description': instance.description,
      'address': instance.address,
      'phones': instance.phones,
    };

_$ClinicListModelImpl _$$ClinicListModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ClinicListModelImpl(
      data: (json['data'] as List<dynamic>)
          .map((e) => ClinicModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ClinicListModelImplToJson(
        _$ClinicListModelImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'pagination': instance.pagination,
    };
