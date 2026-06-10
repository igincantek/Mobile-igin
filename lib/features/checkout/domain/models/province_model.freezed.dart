// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'province_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProvinceModel {

 String get provinsi; List<CityModel> get cities;
/// Create a copy of ProvinceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProvinceModelCopyWith<ProvinceModel> get copyWith => _$ProvinceModelCopyWithImpl<ProvinceModel>(this as ProvinceModel, _$identity);

  /// Serializes this ProvinceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProvinceModel&&(identical(other.provinsi, provinsi) || other.provinsi == provinsi)&&const DeepCollectionEquality().equals(other.cities, cities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provinsi,const DeepCollectionEquality().hash(cities));

@override
String toString() {
  return 'ProvinceModel(provinsi: $provinsi, cities: $cities)';
}


}

/// @nodoc
abstract mixin class $ProvinceModelCopyWith<$Res>  {
  factory $ProvinceModelCopyWith(ProvinceModel value, $Res Function(ProvinceModel) _then) = _$ProvinceModelCopyWithImpl;
@useResult
$Res call({
 String provinsi, List<CityModel> cities
});




}
/// @nodoc
class _$ProvinceModelCopyWithImpl<$Res>
    implements $ProvinceModelCopyWith<$Res> {
  _$ProvinceModelCopyWithImpl(this._self, this._then);

  final ProvinceModel _self;
  final $Res Function(ProvinceModel) _then;

/// Create a copy of ProvinceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provinsi = null,Object? cities = null,}) {
  return _then(_self.copyWith(
provinsi: null == provinsi ? _self.provinsi : provinsi // ignore: cast_nullable_to_non_nullable
as String,cities: null == cities ? _self.cities : cities // ignore: cast_nullable_to_non_nullable
as List<CityModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProvinceModel].
extension ProvinceModelPatterns on ProvinceModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProvinceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProvinceModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProvinceModel value)  $default,){
final _that = this;
switch (_that) {
case _ProvinceModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProvinceModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProvinceModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String provinsi,  List<CityModel> cities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProvinceModel() when $default != null:
return $default(_that.provinsi,_that.cities);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String provinsi,  List<CityModel> cities)  $default,) {final _that = this;
switch (_that) {
case _ProvinceModel():
return $default(_that.provinsi,_that.cities);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String provinsi,  List<CityModel> cities)?  $default,) {final _that = this;
switch (_that) {
case _ProvinceModel() when $default != null:
return $default(_that.provinsi,_that.cities);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProvinceModel implements ProvinceModel {
  const _ProvinceModel({required this.provinsi, required final  List<CityModel> cities}): _cities = cities;
  factory _ProvinceModel.fromJson(Map<String, dynamic> json) => _$ProvinceModelFromJson(json);

@override final  String provinsi;
 final  List<CityModel> _cities;
@override List<CityModel> get cities {
  if (_cities is EqualUnmodifiableListView) return _cities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cities);
}


/// Create a copy of ProvinceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProvinceModelCopyWith<_ProvinceModel> get copyWith => __$ProvinceModelCopyWithImpl<_ProvinceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProvinceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProvinceModel&&(identical(other.provinsi, provinsi) || other.provinsi == provinsi)&&const DeepCollectionEquality().equals(other._cities, _cities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provinsi,const DeepCollectionEquality().hash(_cities));

@override
String toString() {
  return 'ProvinceModel(provinsi: $provinsi, cities: $cities)';
}


}

/// @nodoc
abstract mixin class _$ProvinceModelCopyWith<$Res> implements $ProvinceModelCopyWith<$Res> {
  factory _$ProvinceModelCopyWith(_ProvinceModel value, $Res Function(_ProvinceModel) _then) = __$ProvinceModelCopyWithImpl;
@override @useResult
$Res call({
 String provinsi, List<CityModel> cities
});




}
/// @nodoc
class __$ProvinceModelCopyWithImpl<$Res>
    implements _$ProvinceModelCopyWith<$Res> {
  __$ProvinceModelCopyWithImpl(this._self, this._then);

  final _ProvinceModel _self;
  final $Res Function(_ProvinceModel) _then;

/// Create a copy of ProvinceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provinsi = null,Object? cities = null,}) {
  return _then(_ProvinceModel(
provinsi: null == provinsi ? _self.provinsi : provinsi // ignore: cast_nullable_to_non_nullable
as String,cities: null == cities ? _self._cities : cities // ignore: cast_nullable_to_non_nullable
as List<CityModel>,
  ));
}


}

// dart format on
