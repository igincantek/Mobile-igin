import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nextcart/core/providers/firebase_providers.dart';
import 'package:nextcart/features/cart/data/firebase_cart_repository.dart';
import 'package:nextcart/features/orders/data/firebase_order_repository.dart';
import 'package:nextcart/features/orders/domain/models/app_order.dart';
import 'package:nextcart/features/orders/domain/order_repository.dart';
import 'package:nextcart/features/profile/data/firebase_user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nextcart/features/checkout/domain/models/city_model.dart';
import 'package:nextcart/features/checkout/domain/models/province_model.dart';

part 'checkout_viewmodel.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// URL BACKEND VERCEL
// ─────────────────────────────────────────────────────────────────────────────
const String _kBackendSnapEndpoint = 'https://vercel-midtrans.vercel.app/api/checkout';

const String _kMidtransServerKey = String.fromEnvironment(
  'MIDTRANS_SERVER_KEY',
  defaultValue: '',
);

@riverpod
Future<List<ProvinceModel>> localCities(Ref ref) async {
  try {
    final String response =
        await rootBundle.loadString('assets/data/cities.json');
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
    required String provinsi,
    required String city,
    required String courier,
  }) async {
    final cartAsync = ref.read(cartStreamProvider);
    final items = cartAsync.value ?? [];

    final subtotal =
        items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final deliveryFee = ref.read(shippingCostControllerProvider);
    final totalAll = subtotal + deliveryFee;

    state = const AsyncLoading();

    try {
      // ── Validasi dasar ────────────────────────────────────────────────────
      final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
      if (uid == null) throw StateError('Pengguna belum login.');
      if (items.isEmpty) throw StateError('Keranjang belanja kosong.');
      if (provinsi.isEmpty || city.isEmpty) {
        throw StateError('Silakan pilih provinsi dan kota tujuan.');
      }

      // ── Siapkan Order ID ──────────────────────────────────────────────────
      final orderRepo =
          ref.read(orderRepositoryProvider) as FirebaseOrderRepository;
      final orderId = orderRepo.globalCol.doc().id;

      // ── Ambil Snap Token dari Midtrans ────────────────────────────────────
      final snapResult = await _fetchSnapToken(
        orderId: orderId,
        grossAmount: totalAll.toInt(),
        customerName: customerName,
        phone: phone,
        items: items,
        deliveryFee: deliveryFee,
        courier: courier,
      );

      final snapToken = snapResult['token'] as String;
      final paymentUrl = snapResult['redirect_url'] as String;

      if (snapToken.isEmpty || paymentUrl.isEmpty) {
        throw StateError(
          'Gagal mendapatkan token pembayaran dari Midtrans. '
          'Periksa koneksi internet atau hubungi dukungan.',
        );
      }

      // ── Proteksi: pastikan widget masih mounted ───────────────────────────
      if (!ref.mounted) return null;

      // ── Simpan Order ke Firestore ─────────────────────────────────────────
      final details = CheckoutDetails(
        customerName: customerName,
        phone: phone,
        address: address,
        city: city,
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee.toDouble(),
        courier: courier,
      );

      final order = await orderRepo.placeOrderWithId(
        userId: uid,
        orderId: orderId,
        details: details,
        snapToken: snapToken,
        paymentUrl: paymentUrl,
      );

      // ── Update profil & bersihkan keranjang ───────────────────────────────
      await ref.read(userRepositoryProvider).updateProfile(
            userId: uid,
            phone: phone,
            address: address,
            city: city,
          );

      final cartRepo = ref.read(cartRepositoryProvider);
      final shippingNotifier =
          ref.read(shippingCostControllerProvider.notifier);

      await cartRepo.clear(uid);
      shippingNotifier.reset();

      if (ref.mounted) {
        state = AsyncData(order);
      }
      return order;
    } catch (e, st) {
      if (ref.mounted) {
        state = AsyncError(e, st);
      }
      debugPrint('Checkout Error: $e\n$st');
      return null;
    }
  }

  // ── Helper: ambil Snap Token ────────────────────────────────────────────────
  Future<Map<String, String>> _fetchSnapToken({
    required String orderId,
    required int grossAmount,
    required String customerName,
    required String phone,
    required List<dynamic> items,
    required int deliveryFee,
    required String courier,
  }) async {
    final dio = Dio();

    // ── Mode 1: Lewat backend Vercel (PRODUKSI & AMAN) ───────────────────────
    if (_kBackendSnapEndpoint.isNotEmpty) {
      // PENYESUAIAN PENTING: Mengubah key parameter ke camelCase agar sesuai dengan Node.js di Vercel
      final response = await dio.post(
        _kBackendSnapEndpoint,
        data: {
          'orderId': orderId,
          'total': grossAmount,
          'customerName': customerName,
          'phone': phone,
        },
      );
      
      return {
        'token': response.data['snapToken'] as String? ?? '',
        'redirect_url': response.data['paymentUrl'] as String? ?? '',
      };
    }

    // ── Mode 2: Langsung ke Midtrans (SANDBOX / Fallback) ────────────────────
    final itemDetails = [
      ...items.map((item) => {
            'id': item.productId,
            'price': item.price.toInt(),
            'quantity': item.quantity,
            'name': item.title.length > 50
                ? item.title.substring(0, 50)
                : item.title,
          }),
      {
        'id': 'delivery_fee',
        'price': deliveryFee,
        'quantity': 1,
        'name': 'Ongkos Kirim ($courier)',
      },
    ];

    assert(
      _kMidtransServerKey.isNotEmpty,
      'Isi MIDTRANS_SERVER_KEY via --dart-define, atau isi _kBackendSnapEndpoint '
      'untuk pemanggilan via backend.',
    );

    final base64Auth =
        base64Encode(utf8.encode('$_kMidtransServerKey:'));

    final payload = {
      'transaction_details': {
        'order_id': orderId,
        'gross_amount': grossAmount,
      },
      'credit_card': {'secure': true},
      'customer_details': {
        'first_name': customerName,
        'phone': phone,
      },
      'item_details': itemDetails,
    };

    final response = await dio.post(
      'https://app.sandbox.midtrans.com/snap/v1/transactions',
      data: payload,
      options: Options(
        headers: {
          'Authorization': 'Basic $base64Auth',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'token': response.data['token'] as String? ?? '',
        'redirect_url': response.data['redirect_url'] as String? ?? '',
      };
    }

    throw StateError(
      'Midtrans mengembalikan status ${response.statusCode}: ${response.data}',
    );
  }
}