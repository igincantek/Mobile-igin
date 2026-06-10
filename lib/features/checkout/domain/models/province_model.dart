import 'package:freezed_annotation/freezed_annotation.dart';
import 'city_model.dart';

part 'province_model.freezed.dart';
part 'province_model.g.dart';

@freezed
abstract class ProvinceModel with _$ProvinceModel {
  const factory ProvinceModel({
    required String provinsi,
    required List<CityModel> cities,
  }) = _ProvinceModel;

  factory ProvinceModel.fromJson(Map<String, dynamic> json) =>
      _$ProvinceModelFromJson(json);
}