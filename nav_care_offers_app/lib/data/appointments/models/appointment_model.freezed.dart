// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) {
  return _AppointmentModel.fromJson(json);
}

/// @nodoc
mixin _$AppointmentModel {
  String get id => throw _privateConstructorUsedError;
  Patient get patient => throw _privateConstructorUsedError;
  Provider get provider => throw _privateConstructorUsedError;
  Service get service => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;

  /// Serializes this AppointmentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppointmentModelCopyWith<AppointmentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppointmentModelCopyWith<$Res> {
  factory $AppointmentModelCopyWith(
          AppointmentModel value, $Res Function(AppointmentModel) then) =
      _$AppointmentModelCopyWithImpl<$Res, AppointmentModel>;
  @useResult
  $Res call(
      {String id,
      Patient patient,
      Provider provider,
      Service service,
      String status,
      String startTime,
      String endTime,
      double price});

  $PatientCopyWith<$Res> get patient;
  $ProviderCopyWith<$Res> get provider;
  $ServiceCopyWith<$Res> get service;
}

/// @nodoc
class _$AppointmentModelCopyWithImpl<$Res, $Val extends AppointmentModel>
    implements $AppointmentModelCopyWith<$Res> {
  _$AppointmentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patient = null,
    Object? provider = null,
    Object? service = null,
    Object? status = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? price = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patient: null == patient
          ? _value.patient
          : patient // ignore: cast_nullable_to_non_nullable
              as Patient,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as Provider,
      service: null == service
          ? _value.service
          : service // ignore: cast_nullable_to_non_nullable
              as Service,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PatientCopyWith<$Res> get patient {
    return $PatientCopyWith<$Res>(_value.patient, (value) {
      return _then(_value.copyWith(patient: value) as $Val);
    });
  }

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProviderCopyWith<$Res> get provider {
    return $ProviderCopyWith<$Res>(_value.provider, (value) {
      return _then(_value.copyWith(provider: value) as $Val);
    });
  }

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ServiceCopyWith<$Res> get service {
    return $ServiceCopyWith<$Res>(_value.service, (value) {
      return _then(_value.copyWith(service: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppointmentModelImplCopyWith<$Res>
    implements $AppointmentModelCopyWith<$Res> {
  factory _$$AppointmentModelImplCopyWith(_$AppointmentModelImpl value,
          $Res Function(_$AppointmentModelImpl) then) =
      __$$AppointmentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      Patient patient,
      Provider provider,
      Service service,
      String status,
      String startTime,
      String endTime,
      double price});

  @override
  $PatientCopyWith<$Res> get patient;
  @override
  $ProviderCopyWith<$Res> get provider;
  @override
  $ServiceCopyWith<$Res> get service;
}

/// @nodoc
class __$$AppointmentModelImplCopyWithImpl<$Res>
    extends _$AppointmentModelCopyWithImpl<$Res, _$AppointmentModelImpl>
    implements _$$AppointmentModelImplCopyWith<$Res> {
  __$$AppointmentModelImplCopyWithImpl(_$AppointmentModelImpl _value,
      $Res Function(_$AppointmentModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patient = null,
    Object? provider = null,
    Object? service = null,
    Object? status = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? price = null,
  }) {
    return _then(_$AppointmentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patient: null == patient
          ? _value.patient
          : patient // ignore: cast_nullable_to_non_nullable
              as Patient,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as Provider,
      service: null == service
          ? _value.service
          : service // ignore: cast_nullable_to_non_nullable
              as Service,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppointmentModelImpl implements _AppointmentModel {
  const _$AppointmentModelImpl(
      {required this.id,
      required this.patient,
      required this.provider,
      required this.service,
      required this.status,
      required this.startTime,
      required this.endTime,
      required this.price});

  factory _$AppointmentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppointmentModelImplFromJson(json);

  @override
  final String id;
  @override
  final Patient patient;
  @override
  final Provider provider;
  @override
  final Service service;
  @override
  final String status;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  final double price;

  @override
  String toString() {
    return 'AppointmentModel(id: $id, patient: $patient, provider: $provider, service: $service, status: $status, startTime: $startTime, endTime: $endTime, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patient, patient) || other.patient == patient) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.service, service) || other.service == service) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, patient, provider, service,
      status, startTime, endTime, price);

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentModelImplCopyWith<_$AppointmentModelImpl> get copyWith =>
      __$$AppointmentModelImplCopyWithImpl<_$AppointmentModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppointmentModelImplToJson(
      this,
    );
  }
}

abstract class _AppointmentModel implements AppointmentModel {
  const factory _AppointmentModel(
      {required final String id,
      required final Patient patient,
      required final Provider provider,
      required final Service service,
      required final String status,
      required final String startTime,
      required final String endTime,
      required final double price}) = _$AppointmentModelImpl;

  factory _AppointmentModel.fromJson(Map<String, dynamic> json) =
      _$AppointmentModelImpl.fromJson;

  @override
  String get id;
  @override
  Patient get patient;
  @override
  Provider get provider;
  @override
  Service get service;
  @override
  String get status;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  double get price;

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppointmentModelImplCopyWith<_$AppointmentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Patient _$PatientFromJson(Map<String, dynamic> json) {
  return _Patient.fromJson(json);
}

/// @nodoc
mixin _$Patient {
  String get id => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get profilePicture => throw _privateConstructorUsedError;

  /// Serializes this Patient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientCopyWith<Patient> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientCopyWith<$Res> {
  factory $PatientCopyWith(Patient value, $Res Function(Patient) then) =
      _$PatientCopyWithImpl<$Res, Patient>;
  @useResult
  $Res call(
      {String id,
      String phone,
      String name,
      String email,
      String profilePicture});
}

/// @nodoc
class _$PatientCopyWithImpl<$Res, $Val extends Patient>
    implements $PatientCopyWith<$Res> {
  _$PatientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? name = null,
    Object? email = null,
    Object? profilePicture = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatientImplCopyWith<$Res> implements $PatientCopyWith<$Res> {
  factory _$$PatientImplCopyWith(
          _$PatientImpl value, $Res Function(_$PatientImpl) then) =
      __$$PatientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String phone,
      String name,
      String email,
      String profilePicture});
}

/// @nodoc
class __$$PatientImplCopyWithImpl<$Res>
    extends _$PatientCopyWithImpl<$Res, _$PatientImpl>
    implements _$$PatientImplCopyWith<$Res> {
  __$$PatientImplCopyWithImpl(
      _$PatientImpl _value, $Res Function(_$PatientImpl) _then)
      : super(_value, _then);

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? name = null,
    Object? email = null,
    Object? profilePicture = null,
  }) {
    return _then(_$PatientImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientImpl implements _Patient {
  const _$PatientImpl(
      {required this.id,
      required this.phone,
      required this.name,
      required this.email,
      required this.profilePicture});

  factory _$PatientImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientImplFromJson(json);

  @override
  final String id;
  @override
  final String phone;
  @override
  final String name;
  @override
  final String email;
  @override
  final String profilePicture;

  @override
  String toString() {
    return 'Patient(id: $id, phone: $phone, name: $name, email: $email, profilePicture: $profilePicture)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, phone, name, email, profilePicture);

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      __$$PatientImplCopyWithImpl<_$PatientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientImplToJson(
      this,
    );
  }
}

abstract class _Patient implements Patient {
  const factory _Patient(
      {required final String id,
      required final String phone,
      required final String name,
      required final String email,
      required final String profilePicture}) = _$PatientImpl;

  factory _Patient.fromJson(Map<String, dynamic> json) = _$PatientImpl.fromJson;

  @override
  String get id;
  @override
  String get phone;
  @override
  String get name;
  @override
  String get email;
  @override
  String get profilePicture;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Provider _$ProviderFromJson(Map<String, dynamic> json) {
  return _Provider.fromJson(json);
}

/// @nodoc
mixin _$Provider {
  String get id => throw _privateConstructorUsedError;
  User get user => throw _privateConstructorUsedError;
  String get specialty => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  String get cover => throw _privateConstructorUsedError;
  @JsonKey(name: 'bio_en')
  String? get bioEn => throw _privateConstructorUsedError;
  @JsonKey(name: 'bio_fr')
  String? get bioFr => throw _privateConstructorUsedError;
  @JsonKey(name: 'bio_ar')
  String? get bioAr => throw _privateConstructorUsedError;
  @JsonKey(name: 'bio_sp')
  String? get bioSp => throw _privateConstructorUsedError;
  String? get boost => throw _privateConstructorUsedError;
  String? get boostType => throw _privateConstructorUsedError;
  String? get boostExpiresAt => throw _privateConstructorUsedError;

  /// Serializes this Provider to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Provider
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProviderCopyWith<Provider> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProviderCopyWith<$Res> {
  factory $ProviderCopyWith(Provider value, $Res Function(Provider) then) =
      _$ProviderCopyWithImpl<$Res, Provider>;
  @useResult
  $Res call(
      {String id,
      User user,
      String specialty,
      double rating,
      String cover,
      @JsonKey(name: 'bio_en') String? bioEn,
      @JsonKey(name: 'bio_fr') String? bioFr,
      @JsonKey(name: 'bio_ar') String? bioAr,
      @JsonKey(name: 'bio_sp') String? bioSp,
      String? boost,
      String? boostType,
      String? boostExpiresAt});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$ProviderCopyWithImpl<$Res, $Val extends Provider>
    implements $ProviderCopyWith<$Res> {
  _$ProviderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Provider
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? specialty = null,
    Object? rating = null,
    Object? cover = null,
    Object? bioEn = freezed,
    Object? bioFr = freezed,
    Object? bioAr = freezed,
    Object? bioSp = freezed,
    Object? boost = freezed,
    Object? boostType = freezed,
    Object? boostExpiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      cover: null == cover
          ? _value.cover
          : cover // ignore: cast_nullable_to_non_nullable
              as String,
      bioEn: freezed == bioEn
          ? _value.bioEn
          : bioEn // ignore: cast_nullable_to_non_nullable
              as String?,
      bioFr: freezed == bioFr
          ? _value.bioFr
          : bioFr // ignore: cast_nullable_to_non_nullable
              as String?,
      bioAr: freezed == bioAr
          ? _value.bioAr
          : bioAr // ignore: cast_nullable_to_non_nullable
              as String?,
      bioSp: freezed == bioSp
          ? _value.bioSp
          : bioSp // ignore: cast_nullable_to_non_nullable
              as String?,
      boost: freezed == boost
          ? _value.boost
          : boost // ignore: cast_nullable_to_non_nullable
              as String?,
      boostType: freezed == boostType
          ? _value.boostType
          : boostType // ignore: cast_nullable_to_non_nullable
              as String?,
      boostExpiresAt: freezed == boostExpiresAt
          ? _value.boostExpiresAt
          : boostExpiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of Provider
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProviderImplCopyWith<$Res>
    implements $ProviderCopyWith<$Res> {
  factory _$$ProviderImplCopyWith(
          _$ProviderImpl value, $Res Function(_$ProviderImpl) then) =
      __$$ProviderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      User user,
      String specialty,
      double rating,
      String cover,
      @JsonKey(name: 'bio_en') String? bioEn,
      @JsonKey(name: 'bio_fr') String? bioFr,
      @JsonKey(name: 'bio_ar') String? bioAr,
      @JsonKey(name: 'bio_sp') String? bioSp,
      String? boost,
      String? boostType,
      String? boostExpiresAt});

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$ProviderImplCopyWithImpl<$Res>
    extends _$ProviderCopyWithImpl<$Res, _$ProviderImpl>
    implements _$$ProviderImplCopyWith<$Res> {
  __$$ProviderImplCopyWithImpl(
      _$ProviderImpl _value, $Res Function(_$ProviderImpl) _then)
      : super(_value, _then);

  /// Create a copy of Provider
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? specialty = null,
    Object? rating = null,
    Object? cover = null,
    Object? bioEn = freezed,
    Object? bioFr = freezed,
    Object? bioAr = freezed,
    Object? bioSp = freezed,
    Object? boost = freezed,
    Object? boostType = freezed,
    Object? boostExpiresAt = freezed,
  }) {
    return _then(_$ProviderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      specialty: null == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      cover: null == cover
          ? _value.cover
          : cover // ignore: cast_nullable_to_non_nullable
              as String,
      bioEn: freezed == bioEn
          ? _value.bioEn
          : bioEn // ignore: cast_nullable_to_non_nullable
              as String?,
      bioFr: freezed == bioFr
          ? _value.bioFr
          : bioFr // ignore: cast_nullable_to_non_nullable
              as String?,
      bioAr: freezed == bioAr
          ? _value.bioAr
          : bioAr // ignore: cast_nullable_to_non_nullable
              as String?,
      bioSp: freezed == bioSp
          ? _value.bioSp
          : bioSp // ignore: cast_nullable_to_non_nullable
              as String?,
      boost: freezed == boost
          ? _value.boost
          : boost // ignore: cast_nullable_to_non_nullable
              as String?,
      boostType: freezed == boostType
          ? _value.boostType
          : boostType // ignore: cast_nullable_to_non_nullable
              as String?,
      boostExpiresAt: freezed == boostExpiresAt
          ? _value.boostExpiresAt
          : boostExpiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProviderImpl implements _Provider {
  const _$ProviderImpl(
      {required this.id,
      required this.user,
      required this.specialty,
      required this.rating,
      required this.cover,
      @JsonKey(name: 'bio_en') this.bioEn,
      @JsonKey(name: 'bio_fr') this.bioFr,
      @JsonKey(name: 'bio_ar') this.bioAr,
      @JsonKey(name: 'bio_sp') this.bioSp,
      this.boost,
      this.boostType,
      this.boostExpiresAt});

  factory _$ProviderImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProviderImplFromJson(json);

  @override
  final String id;
  @override
  final User user;
  @override
  final String specialty;
  @override
  final double rating;
  @override
  final String cover;
  @override
  @JsonKey(name: 'bio_en')
  final String? bioEn;
  @override
  @JsonKey(name: 'bio_fr')
  final String? bioFr;
  @override
  @JsonKey(name: 'bio_ar')
  final String? bioAr;
  @override
  @JsonKey(name: 'bio_sp')
  final String? bioSp;
  @override
  final String? boost;
  @override
  final String? boostType;
  @override
  final String? boostExpiresAt;

  @override
  String toString() {
    return 'Provider(id: $id, user: $user, specialty: $specialty, rating: $rating, cover: $cover, bioEn: $bioEn, bioFr: $bioFr, bioAr: $bioAr, bioSp: $bioSp, boost: $boost, boostType: $boostType, boostExpiresAt: $boostExpiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProviderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.cover, cover) || other.cover == cover) &&
            (identical(other.bioEn, bioEn) || other.bioEn == bioEn) &&
            (identical(other.bioFr, bioFr) || other.bioFr == bioFr) &&
            (identical(other.bioAr, bioAr) || other.bioAr == bioAr) &&
            (identical(other.bioSp, bioSp) || other.bioSp == bioSp) &&
            (identical(other.boost, boost) || other.boost == boost) &&
            (identical(other.boostType, boostType) ||
                other.boostType == boostType) &&
            (identical(other.boostExpiresAt, boostExpiresAt) ||
                other.boostExpiresAt == boostExpiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, user, specialty, rating,
      cover, bioEn, bioFr, bioAr, bioSp, boost, boostType, boostExpiresAt);

  /// Create a copy of Provider
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProviderImplCopyWith<_$ProviderImpl> get copyWith =>
      __$$ProviderImplCopyWithImpl<_$ProviderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProviderImplToJson(
      this,
    );
  }
}

abstract class _Provider implements Provider {
  const factory _Provider(
      {required final String id,
      required final User user,
      required final String specialty,
      required final double rating,
      required final String cover,
      @JsonKey(name: 'bio_en') final String? bioEn,
      @JsonKey(name: 'bio_fr') final String? bioFr,
      @JsonKey(name: 'bio_ar') final String? bioAr,
      @JsonKey(name: 'bio_sp') final String? bioSp,
      final String? boost,
      final String? boostType,
      final String? boostExpiresAt}) = _$ProviderImpl;

  factory _Provider.fromJson(Map<String, dynamic> json) =
      _$ProviderImpl.fromJson;

  @override
  String get id;
  @override
  User get user;
  @override
  String get specialty;
  @override
  double get rating;
  @override
  String get cover;
  @override
  @JsonKey(name: 'bio_en')
  String? get bioEn;
  @override
  @JsonKey(name: 'bio_fr')
  String? get bioFr;
  @override
  @JsonKey(name: 'bio_ar')
  String? get bioAr;
  @override
  @JsonKey(name: 'bio_sp')
  String? get bioSp;
  @override
  String? get boost;
  @override
  String? get boostType;
  @override
  String? get boostExpiresAt;

  /// Create a copy of Provider
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProviderImplCopyWith<_$ProviderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get profilePicture => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String id,
      String phone,
      String name,
      String email,
      String profilePicture});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? name = null,
    Object? email = null,
    Object? profilePicture = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String phone,
      String name,
      String email,
      String profilePicture});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? name = null,
    Object? email = null,
    Object? profilePicture = null,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.id,
      required this.phone,
      required this.name,
      required this.email,
      required this.profilePicture});

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String phone;
  @override
  final String name;
  @override
  final String email;
  @override
  final String profilePicture;

  @override
  String toString() {
    return 'User(id: $id, phone: $phone, name: $name, email: $email, profilePicture: $profilePicture)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, phone, name, email, profilePicture);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final String id,
      required final String phone,
      required final String name,
      required final String email,
      required final String profilePicture}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get phone;
  @override
  String get name;
  @override
  String get email;
  @override
  String get profilePicture;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Service _$ServiceFromJson(Map<String, dynamic> json) {
  return _Service.fromJson(json);
}

/// @nodoc
mixin _$Service {
  String get name => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  String get providerType => throw _privateConstructorUsedError;

  /// Serializes this Service to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceCopyWith<Service> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceCopyWith<$Res> {
  factory $ServiceCopyWith(Service value, $Res Function(Service) then) =
      _$ServiceCopyWithImpl<$Res, Service>;
  @useResult
  $Res call({String name, String provider, String providerType});
}

/// @nodoc
class _$ServiceCopyWithImpl<$Res, $Val extends Service>
    implements $ServiceCopyWith<$Res> {
  _$ServiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? provider = null,
    Object? providerType = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      providerType: null == providerType
          ? _value.providerType
          : providerType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServiceImplCopyWith<$Res> implements $ServiceCopyWith<$Res> {
  factory _$$ServiceImplCopyWith(
          _$ServiceImpl value, $Res Function(_$ServiceImpl) then) =
      __$$ServiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String provider, String providerType});
}

/// @nodoc
class __$$ServiceImplCopyWithImpl<$Res>
    extends _$ServiceCopyWithImpl<$Res, _$ServiceImpl>
    implements _$$ServiceImplCopyWith<$Res> {
  __$$ServiceImplCopyWithImpl(
      _$ServiceImpl _value, $Res Function(_$ServiceImpl) _then)
      : super(_value, _then);

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? provider = null,
    Object? providerType = null,
  }) {
    return _then(_$ServiceImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      providerType: null == providerType
          ? _value.providerType
          : providerType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceImpl implements _Service {
  const _$ServiceImpl(
      {required this.name, required this.provider, required this.providerType});

  factory _$ServiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceImplFromJson(json);

  @override
  final String name;
  @override
  final String provider;
  @override
  final String providerType;

  @override
  String toString() {
    return 'Service(name: $name, provider: $provider, providerType: $providerType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.providerType, providerType) ||
                other.providerType == providerType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, provider, providerType);

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceImplCopyWith<_$ServiceImpl> get copyWith =>
      __$$ServiceImplCopyWithImpl<_$ServiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceImplToJson(
      this,
    );
  }
}

abstract class _Service implements Service {
  const factory _Service(
      {required final String name,
      required final String provider,
      required final String providerType}) = _$ServiceImpl;

  factory _Service.fromJson(Map<String, dynamic> json) = _$ServiceImpl.fromJson;

  @override
  String get name;
  @override
  String get provider;
  @override
  String get providerType;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceImplCopyWith<_$ServiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AppointmentListModel _$AppointmentListModelFromJson(Map<String, dynamic> json) {
  return _AppointmentListModel.fromJson(json);
}

/// @nodoc
mixin _$AppointmentListModel {
  List<AppointmentModel> get appointments => throw _privateConstructorUsedError;
  Pagination get pagination => throw _privateConstructorUsedError;

  /// Serializes this AppointmentListModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppointmentListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppointmentListModelCopyWith<AppointmentListModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppointmentListModelCopyWith<$Res> {
  factory $AppointmentListModelCopyWith(AppointmentListModel value,
          $Res Function(AppointmentListModel) then) =
      _$AppointmentListModelCopyWithImpl<$Res, AppointmentListModel>;
  @useResult
  $Res call({List<AppointmentModel> appointments, Pagination pagination});

  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$AppointmentListModelCopyWithImpl<$Res,
        $Val extends AppointmentListModel>
    implements $AppointmentListModelCopyWith<$Res> {
  _$AppointmentListModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppointmentListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appointments = null,
    Object? pagination = null,
  }) {
    return _then(_value.copyWith(
      appointments: null == appointments
          ? _value.appointments
          : appointments // ignore: cast_nullable_to_non_nullable
              as List<AppointmentModel>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination,
    ) as $Val);
  }

  /// Create a copy of AppointmentListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginationCopyWith<$Res> get pagination {
    return $PaginationCopyWith<$Res>(_value.pagination, (value) {
      return _then(_value.copyWith(pagination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppointmentListModelImplCopyWith<$Res>
    implements $AppointmentListModelCopyWith<$Res> {
  factory _$$AppointmentListModelImplCopyWith(_$AppointmentListModelImpl value,
          $Res Function(_$AppointmentListModelImpl) then) =
      __$$AppointmentListModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<AppointmentModel> appointments, Pagination pagination});

  @override
  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$AppointmentListModelImplCopyWithImpl<$Res>
    extends _$AppointmentListModelCopyWithImpl<$Res, _$AppointmentListModelImpl>
    implements _$$AppointmentListModelImplCopyWith<$Res> {
  __$$AppointmentListModelImplCopyWithImpl(_$AppointmentListModelImpl _value,
      $Res Function(_$AppointmentListModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppointmentListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appointments = null,
    Object? pagination = null,
  }) {
    return _then(_$AppointmentListModelImpl(
      appointments: null == appointments
          ? _value._appointments
          : appointments // ignore: cast_nullable_to_non_nullable
              as List<AppointmentModel>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppointmentListModelImpl implements _AppointmentListModel {
  const _$AppointmentListModelImpl(
      {required final List<AppointmentModel> appointments,
      required this.pagination})
      : _appointments = appointments;

  factory _$AppointmentListModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppointmentListModelImplFromJson(json);

  final List<AppointmentModel> _appointments;
  @override
  List<AppointmentModel> get appointments {
    if (_appointments is EqualUnmodifiableListView) return _appointments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_appointments);
  }

  @override
  final Pagination pagination;

  @override
  String toString() {
    return 'AppointmentListModel(appointments: $appointments, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentListModelImpl &&
            const DeepCollectionEquality()
                .equals(other._appointments, _appointments) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_appointments), pagination);

  /// Create a copy of AppointmentListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentListModelImplCopyWith<_$AppointmentListModelImpl>
      get copyWith =>
          __$$AppointmentListModelImplCopyWithImpl<_$AppointmentListModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppointmentListModelImplToJson(
      this,
    );
  }
}

abstract class _AppointmentListModel implements AppointmentListModel {
  const factory _AppointmentListModel(
      {required final List<AppointmentModel> appointments,
      required final Pagination pagination}) = _$AppointmentListModelImpl;

  factory _AppointmentListModel.fromJson(Map<String, dynamic> json) =
      _$AppointmentListModelImpl.fromJson;

  @override
  List<AppointmentModel> get appointments;
  @override
  Pagination get pagination;

  /// Create a copy of AppointmentListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppointmentListModelImplCopyWith<_$AppointmentListModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
