import 'package:freezed_annotation/freezed_annotation.dart';

part 'city_model.freezed.dart';
part 'city_model.g.dart';

@freezed
abstract class CityModel with _$CityModel {
  const factory CityModel({
    @JsonKey(name: 'city_id') final String? cityId,
    @JsonKey(name: 'city_name') final String? cityName,
    @JsonKey(name: 'postal_code') final String? postalCode,
    final int? ongkir,
  }) = _CityModel;

  factory CityModel.fromJson(Map<String, dynamic> json) =>
      _$CityModelFromJson(json);
}