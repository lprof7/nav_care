// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advertising_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdvertisingImpl _$$AdvertisingImplFromJson(Map<String, dynamic> json) =>
    _$AdvertisingImpl(
      id: json['_id'] as String,
      owner: json['owner'] as String,
      image: json['image'] as String,
      link: json['link'] as String,
      position: json['position'] as String,
      isActive: json['isActive'] as bool,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AdvertisingImplToJson(_$AdvertisingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner': instance.owner,
      'image': instance.image,
      'link': instance.link,
      'position': instance.position,
      'isActive': instance.isActive,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
