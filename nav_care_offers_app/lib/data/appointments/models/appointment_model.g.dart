// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppointmentModelImpl _$$AppointmentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AppointmentModelImpl(
      id: json['_id'] as String,
      patient: Patient.fromJson(json['patient'] as Map<String, dynamic>),
      provider: Provider.fromJson(json['provider'] as Map<String, dynamic>),
      service: Service.fromJson(json['service'] as Map<String, dynamic>),
      status: json['status'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$$AppointmentModelImplToJson(
        _$AppointmentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient': instance.patient,
      'provider': instance.provider,
      'service': instance.service,
      'status': instance.status,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'price': instance.price,
    };

_$PatientImpl _$$PatientImplFromJson(Map<String, dynamic> json) =>
    _$PatientImpl(
      id: json['_id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String,
    );

Map<String, dynamic> _$$PatientImplToJson(_$PatientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'email': instance.email,
      'profilePicture': instance.profilePicture,
    };

_$ProviderImpl _$$ProviderImplFromJson(Map<String, dynamic> json) =>
    _$ProviderImpl(
      id: json['_id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      specialty: json['specialty'] as String,
      rating: (json['rating'] as num).toDouble(),
      cover: json['cover'] as String,
      bioEn: json['bio_en'] as String?,
      bioFr: json['bio_fr'] as String?,
      bioAr: json['bio_ar'] as String?,
      bioSp: json['bio_sp'] as String?,
      boost: json['boost'] as String?,
      boostType: json['boostType'] as String?,
      boostExpiresAt: json['boostExpiresAt'] as String?,
    );

Map<String, dynamic> _$$ProviderImplToJson(_$ProviderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'specialty': instance.specialty,
      'rating': instance.rating,
      'cover': instance.cover,
      'bio_en': instance.bioEn,
      'bio_fr': instance.bioFr,
      'bio_ar': instance.bioAr,
      'bio_sp': instance.bioSp,
      'boost': instance.boost,
      'boostType': instance.boostType,
      'boostExpiresAt': instance.boostExpiresAt,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['_id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'email': instance.email,
      'profilePicture': instance.profilePicture,
    };

_$ServiceImpl _$$ServiceImplFromJson(Map<String, dynamic> json) =>
    _$ServiceImpl(
      name: json['name'] as String,
      provider: json['provider'] as String,
      providerType: json['providerType'] as String,
    );

Map<String, dynamic> _$$ServiceImplToJson(_$ServiceImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'provider': instance.provider,
      'providerType': instance.providerType,
    };

_$AppointmentListModelImpl _$$AppointmentListModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AppointmentListModelImpl(
      appointments: (json['appointments'] as List<dynamic>)
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AppointmentListModelImplToJson(
        _$AppointmentListModelImpl instance) =>
    <String, dynamic>{
      'appointments': instance.appointments,
      'pagination': instance.pagination,
    };
