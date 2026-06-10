// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localCities)
final localCitiesProvider = LocalCitiesProvider._();

final class LocalCitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProvinceModel>>,
          List<ProvinceModel>,
          FutureOr<List<ProvinceModel>>
        >
    with
        $FutureModifier<List<ProvinceModel>>,
        $FutureProvider<List<ProvinceModel>> {
  LocalCitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localCitiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localCitiesHash();

  @$internal
  @override
  $FutureProviderElement<List<ProvinceModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProvinceModel>> create(Ref ref) {
    return localCities(ref);
  }
}

String _$localCitiesHash() => r'30b64676a328e77a37b7b33a29963ef5cabd312e';

@ProviderFor(ShippingCostController)
final shippingCostControllerProvider = ShippingCostControllerProvider._();

final class ShippingCostControllerProvider
    extends $NotifierProvider<ShippingCostController, int> {
  ShippingCostControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shippingCostControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shippingCostControllerHash();

  @$internal
  @override
  ShippingCostController create() => ShippingCostController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$shippingCostControllerHash() =>
    r'c305674fe516d847ddf216f4ac797530dd6dc785';

abstract class _$ShippingCostController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CheckoutController)
final checkoutControllerProvider = CheckoutControllerProvider._();

final class CheckoutControllerProvider
    extends $NotifierProvider<CheckoutController, AsyncValue<AppOrder?>> {
  CheckoutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutControllerHash();

  @$internal
  @override
  CheckoutController create() => CheckoutController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AppOrder?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<AppOrder?>>(value),
    );
  }
}

String _$checkoutControllerHash() =>
    r'80bfa41798de351ab2e75a1dadb760d42b4b8278';

abstract class _$CheckoutController extends $Notifier<AsyncValue<AppOrder?>> {
  AsyncValue<AppOrder?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppOrder?>, AsyncValue<AppOrder?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppOrder?>, AsyncValue<AppOrder?>>,
              AsyncValue<AppOrder?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
