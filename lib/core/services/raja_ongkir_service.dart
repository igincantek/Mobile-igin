import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class RajaOngkirService {
  late final Dio _dio;

  RajaOngkirService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.komerce.id/v1/shipping',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  Future<List<dynamic>> getShippingCosts({
    required String origin,
    required String destination,
    required int weight,
    required String courier,
  }) async {
    try {
      debugPrint("Mencoba mengambil data ongkir untuk: $courier...");
      
      // Mengirim API Key langsung di header pada setiap request
      final response = await _dio.post(
        '/cost', 
        data: {
          'origin': origin,
          'destination': destination,
          'weight': weight,
          'courier': courier,
        },
        options: Options(
          headers: {
            'Api-Key': 'xjbPo2BNdef64409db9ed493h1QrR9Ek',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint("RESPONS LENGKAP: ${response.data}");

      // Penanganan struktur respons Komerce
      if (response.data != null) {
        final body = response.data;
        
        // Cek jika data ada di dalam field 'data'
        if (body['data'] != null) {
          final data = body['data'];
          
          // Beberapa API Komerce mengembalikan list langsung di field 'costs'
          if (data is List) return data;
          if (data['costs'] != null) return data['costs'] as List<dynamic>;
          if (data['results'] != null) return data['results'] as List<dynamic>;
        }
      }
      
      debugPrint("API Warning: Tidak ada data kurir ditemukan.");
      return [];

    } on DioException catch (e) {
      // Jika terjadi error, kita tampilkan respons error dari server
      if (e.response != null) {
        debugPrint("DIO ERROR STATUS: ${e.response?.statusCode}");
        debugPrint("DIO ERROR DATA: ${e.response?.data}");
      } else {
        debugPrint("DIO ERROR MESSAGE: ${e.message}");
      }
      return [];
    } catch (e) {
      debugPrint("GENERAL ERROR: $e");
      return [];
    }
  }
}