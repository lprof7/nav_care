// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinic_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClinicModel _$ClinicModelFromJson(Map<String, dynamic> json) {
  return _ClinicModel.fromJson(json);
}

/// @nodoc
mixin _$ClinicModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  List<String> get phones => throw _privateConstructorUsedError;

  /// Serializes this ClinicModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClinicModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClinicModelCopyWith<ClinicModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClinicModelCopyWith<$Res> {
  factory $ClinicModelCopyWith(
          ClinicModel value, $Res Function(ClinicModel) then) =
      _$ClinicModelCopyWithImpl<$Res, ClinicModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      List<String> images,
      String? description,
      String? address,
      List<String> phones});
}

/// @nodoc
class _$ClinicModelCopyWithImpl<$Res, $Val extends ClinicModel>
    implements $ClinicModelCopyWith<$Res> {
  _$ClinicModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClinicModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? images = null,
    Object? description = freezed,
    Object? address = freezed,
    Object? phones = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      phones: null == phones
          ? _value.phones
          : phones // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClinicModelImplCopyWith<$Res>
    implements $ClinicModelCopyWith<$Res> {
  factory _$$ClinicModelImplCopyWith(
          _$ClinicModelImpl value, $Res Function(_$ClinicModelImpl) then) =
      __$$ClinicModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      List<String> images,
      String? description,
      String? address,
      List<String> phones});
}

/// @nodoc
class __$$ClinicModelImplCopyWithImpl<$Res>
    extends _$ClinicModelCopyWithImpl<$Res, _$ClinicModelImpl>
    implements _$$ClinicModelImplCopyWith<$Res> {
  __$$ClinicModelImplCopyWithImpl(
      _$ClinicModelImpl _value, $Res Function(_$ClinicModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClinicModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? images = null,
    Object? description = freezed,
    Object? address = freezed,
    Object? phones = null,
  }) {
    return _then(_$ClinicModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      phones: null == phones
          ? _value._phones
          : phones // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClinicModelImpl implements _ClinicModel {
  const _$ClinicModelImpl(
      {required this.id,
      required this.name,
      final List<String> images = const [],
      this.description,
      this.address,
      final List<String> phones = const []})
      : _images = images,
        _phones = phones;

  factory _$ClinicModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClinicModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String? description;
  @override
  final String? address;
  final List<String> _phones;
  @override
  @JsonKey()
  List<String> get phones {
    if (_phones is EqualUnmodifiableListView) return _phones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_phones);
  }

  @override
  String toString() {
    return 'ClinicModel(id: $id, name: $name, images: $images, description: $description, address: $address, phones: $phones)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClinicModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.address, address) || other.address == address) &&
            const DeepCollectionEquality().equals(other._phones, _phones));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_images),
      description,
      address,
      const DeepCollectionEquality().hash(_phones));

  /// Create a copy of ClinicModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClinicModelImplCopyWith<_$ClinicModelImpl> get copyWith =>
      __$$ClinicModelImplCopyWithImpl<_$ClinicModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClinicModelImplToJson(
      this,
    );
  }
}

abstract class _ClinicModel implements ClinicModel {
  const factory _ClinicModel(
      {required final String id,
      required final String name,
      final List<String> images,
      final String? description,
      final String? address,
      final List<String> phones}) = _$ClinicModelImpl;

  factory _ClinicModel.fromJson(Map<String, dynamic> json) =
      _$ClinicModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<String> get images;
  @override
  String? get description;
  @override
  String? get address;
  @override
  List<String> get phones;

  /// Create a copy of ClinicModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClinicModelImplCopyWith<_$ClinicModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClinicListModel _$ClinicListModelFromJson(Map<String, dynamic> json) {
  return _ClinicListModel.fromJson(json);
}

/// @nodoc
mixin _$ClinicListModel {
  List<ClinicModel> get data => throw _privateConstructorUsedError;
  Pagination get pagination => throw _privateConstructorUsedError;

  /// Serializes this ClinicListModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClinicListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClinicListModelCopyWith<ClinicListModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClinicListModelCopyWith<$Res> {
  factory $ClinicListModelCopyWith(
          ClinicListModel value, $Res Function(ClinicListModel) then) =
      _$ClinicListModelCopyWithImpl<$Res, ClinicListModel>;
  @useResult
  $Res call({List<ClinicModel> data, Pagination pagination});

  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$ClinicListModelCopyWithImpl<$Res, $Val extends ClinicListModel>
    implements $ClinicListModelCopyWith<$Res> {
  _$ClinicListModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClinicListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? pagination = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<ClinicModel>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination,
    ) as $Val);
  }

  /// Create a copy of ClinicListModel
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
abstract class _$$ClinicListModelImplCopyWith<$Res>
    implements $ClinicListModelCopyWith<$Res> {
  factory _$$ClinicListModelImplCopyWith(_$ClinicListModelImpl value,
          $Res Function(_$ClinicListModelImpl) then) =
      __$$ClinicListModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ClinicModel> data, Pagination pagination});

  @override
  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$ClinicListModelImplCopyWithImpl<$Res>
    extends _$ClinicListModelCopyWithImpl<$Res, _$ClinicListModelImpl>
    implements _$$ClinicListModelImplCopyWith<$Res> {
  __$$ClinicListModelImplCopyWithImpl(
      _$ClinicListModelImpl _value, $Res Function(_$ClinicListModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClinicListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? pagination = null,
  }) {
    return _then(_$ClinicListModelImpl(
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<ClinicModel>,
      pagination: null == pagination
          ? _value.pagination
          : pagination // ignore: cast_nullable_to_non_nullable
              as Pagination,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClinicListModelImpl implements _ClinicListModel {
  const _$ClinicListModelImpl(
      {required final List<ClinicModel> data, required this.pagination})
      : _data = data;

  factory _$ClinicListModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClinicListModelImplFromJson(json);

  final List<ClinicModel> _data;
  @override
  List<ClinicModel> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  final Pagination pagination;

  @override
  String toString() {
    return 'ClinicListModel(data: $data, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClinicListModelImpl &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_data), pagination);

  /// Create a copy of ClinicListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClinicListModelImplCopyWith<_$ClinicListModelImpl> get copyWith =>
      __$$ClinicListModelImplCopyWithImpl<_$ClinicListModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClinicListModelImplToJson(
      this,
    );
  }
}

abstract class _ClinicListModel implements ClinicListModel {
  const factory _ClinicListModel(
      {required final List<ClinicModel> data,
      required final Pagination pagination}) = _$ClinicListModelImpl;

  factory _ClinicListModel.fromJson(Map<String, dynamic> json) =
      _$ClinicListModelImpl.fromJson;

  @override
  List<ClinicModel> get data;
  @override
  Pagination get pagination;

  /// Create a copy of ClinicListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClinicListModelImplCopyWith<_$ClinicListModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
