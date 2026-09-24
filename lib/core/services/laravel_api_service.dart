import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan IP IPv4 komputermu (cek pakai ipconfig di CMD)
  // Gunakan 'http://10.0.2.2:8000/api' jika kamu testing pakai Emulator Android bawaan Android Studio
  static const String baseUrl = 'http://192.168.1.12:8000/api';
  Future<List<dynamic>> getProducts() async {
    try {
      // Memanggil endpoint /products-mobile yang ada di routes/api.php Laravel
      final response = await http.get(Uri.parse('$baseUrl/products-mobile'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Mengembalikan array 'data' yang berisi list produk Anda Petshop
        return jsonResponse['data']; 
      } else {
        throw Exception('Gagal memuat katalog produk: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }
}