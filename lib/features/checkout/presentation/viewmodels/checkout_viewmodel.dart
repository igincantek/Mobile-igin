import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nextcart/features/orders/domain/models/app_order.dart';
import 'package:nextcart/features/checkout/domain/models/city_model.dart';
import 'package:nextcart/features/checkout/domain/models/province_model.dart';

part 'checkout_viewmodel.g.dart';

const String _kLaravelBaseUrl = 'http://192.168.1.12:8000/api';

class MySQLCartItem {
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String? image;

  MySQLCartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory MySQLCartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};
    return MySQLCartItem(
      productId: product['id_product']?.toString() ?? json['id_product']?.toString() ?? '',
      title: product['name']?.toString() ?? 'Produk',
      price: double.tryParse(product['price']?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      image: product['image_url']?.toString(),
    );
  }
}

// ── Menggunakan Anotasi @riverpod agar sesuai dengan Riverpod Generator ─────
@riverpod
Future<List<MySQLCartItem>> mySQLCartItems(Ref ref) async {
  try {
    const String userId = '1';
    final dio = Dio();
    final response = await dio.get('$_kLaravelBaseUrl/cart-mobile/$userId');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => MySQLCartItem.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    debugPrint('Gagal memuat keranjang dari MySQL: $e');
    return [];
  }
}

@riverpod
Future<List<ProvinceModel>> localCities(Ref ref) async {
  try {
    final String response = await rootBundle.loadString('assets/data/cities.json');
    final List<dynamic> data = json.decode(response);
    return data
        .map((e) => ProvinceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint('Gagal memuat local cities: $e');
    return [];
  }
}

@riverpod
class ShippingCostController extends _$ShippingCostController {
  @override
  int build() => 0;

  void setShippingCost(CityModel? city) {
    state = city?.ongkir ?? 0;
  }

  void reset() {
    state = 0;
  }
}

@riverpod
class CheckoutController extends _$CheckoutController {
  @override
  AsyncValue<AppOrder?> build() => const AsyncData(null);

  Future<AppOrder?> placeOrder({
    required String customerName,
    required String phone,
    required String address,
    required String provinceId,
    required CityModel selectedCityObj,
    required String courier,
  }) async {
    final List<MySQLCartItem> cartItems = await ref.read(mySQLCartItemsProvider.future);

    final subtotal = cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final deliveryFee = ref.read(shippingCostControllerProvider);
    final totalAll = subtotal + deliveryFee;

    state = const AsyncLoading();

    try {
      const String userId = '1';

      if (cartItems.isEmpty) throw StateError('Keranjang belanja kosong.');
      if (provinceId.isEmpty || selectedCityObj.cityId == null) {
        throw StateError('Silakan pilih provinsi dan kota tujuan.');
      }

      final dio = Dio();
      final response = await dio.post(
        '$_kLaravelBaseUrl/checkout-mobile',
        data: {
          'id_user': userId,
          'customer_name': customerName,
          'phone_number': phone,
          'address': address,
          'province_id': provinceId,
          'city_id': selectedCityObj.cityId,
          'courier': courier.toLowerCase(),
          'shipping_cost': deliveryFee,
          'items': cartItems.map((item) => {
                'product_id': item.productId,
                'quantity': item.quantity,
              }).toList(),
        },
      );

      final responseData = response.data;

      if (response.statusCode != 200 || responseData['success'] != true) {
        throw StateError(responseData['message'] ?? 'Gagal memproses pesanan di server.');
      }

      final orderId = responseData['order_id']?.toString() ?? '';
      final snapToken = responseData['snap_token']?.toString() ?? '';
      final paymentUrl = responseData['payment_url']?.toString() ?? '';

      if (snapToken.isEmpty || paymentUrl.isEmpty) {
        throw StateError('Gagal mendapatkan token pembayaran dari Midtrans.');
      }

      final List<OrderLine> orderLines = cartItems.map<OrderLine>((cartItem) {
        return OrderLine(
          productId: cartItem.productId,
          title: cartItem.title,
          price: cartItem.price,
          quantity: cartItem.quantity,
          image: cartItem.image ?? '',
        );
      }).toList();

      final order = AppOrder(
        id: orderId,
        createdAt: DateTime.now(),
        total: totalAll,
        subtotal: subtotal,
        deliveryFee: deliveryFee.toDouble(),
        deliveryAddress: address,
        deliveryPhone: phone,
        customerName: customerName,
        city: selectedCityObj.cityName ?? '',
        status: OrderStatus.pending,
        paymentUrl: paymentUrl,
        snapToken: snapToken,
        items: orderLines,
      );

      ref.read(shippingCostControllerProvider.notifier).reset();

      state = AsyncValue.data(order);
      return order;
    } catch (e, st) {
      String errorMessage = e.toString();

      if (e is DioException && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        }
      }

      state = AsyncValue.error(errorMessage, st);
      debugPrint('Checkout Error Detail: $e\n$st');
      return null;
    }
  }
}