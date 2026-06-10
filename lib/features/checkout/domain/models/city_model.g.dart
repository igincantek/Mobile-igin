// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CityModel _$CityModelFromJson(Map<String, dynamic> json) => _CityModel(
  cityId: json['city_id'] as String?,
  cityName: json['city_name'] as String?,
  postalCode: json['postal_code'] as String?,
  ongkir: (json['ongkir'] as num?)?.toInt(),
);

Map<String, dynamic> _$CityModelToJson(_CityModel instance) =>
    <String, dynamic>{
      'city_id': instance.cityId,
      'city_name': instance.cityName,
      'postal_code': instance.postalCode,
      'ongkir': instance.ongkir,
    };
