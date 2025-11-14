import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'advertising_model.freezed.dart';
part 'advertising_model.g.dart';

@freezed
class Advertising with _$Advertising {
  const factory Advertising({
    required String id,
    required String owner,
    required String image,
    required String link,
    required String position,
    required bool isActive,
    required DateTime expiresAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Advertising;

  factory Advertising.fromJson(Map<String, dynamic> json) =>
      _$AdvertisingFromJson(json);
}
