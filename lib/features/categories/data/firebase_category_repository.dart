import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nextcart/features/categories/domain/category_repository.dart';
import 'package:nextcart/features/categories/domain/models/category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_category_repository.g.dart';

class ApiCategoryRepository implements CategoryRepository {
  final String baseUrl = 'http://192.168.1.12:8000/api';

  @override
  Stream<List<Category>> watchAll() async* {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories-mobile'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        final categories = data.map((item) => Category(
          id: item['name'] ?? '', // Menggunakan nama kategori agar langsung sinkron dengan pencarian teks
          name: item['name'] ?? '',
          image: item['image_url'] ?? (item['image'] != null ? 'http://192.168.1.12:8000/storage/${item['image']}' : null),
        )).toList();

        yield categories;
      } else {
        yield [];
      }
    } catch (e) {
      yield [];
    }
  }

  @override
  Future<List<Category>> getAll() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories-mobile'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((item) => Category(
          id: item['name'] ?? '',
          name: item['name'] ?? '',
          image: item['image_url'] ?? (item['image'] != null ? 'http://192.168.1.12:8000/storage/${item['image']}' : null),
        )).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Category?> getById(String id) async {
    final categories = await getAll();
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return ApiCategoryRepository();
}

@riverpod
Stream<List<Category>> categoriesStream(Ref ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
}