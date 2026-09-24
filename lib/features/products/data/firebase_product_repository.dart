import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nextcart/features/products/domain/models/product.dart';
import 'package:nextcart/features/products/domain/product_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_product_repository.g.dart';

class ApiProductRepository implements ProductRepository {
  final String baseUrl = 'http://192.168.1.12:8000/api';

  Future<List<Product>> _fetchProductsFromLaravel() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products-mobile'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        
        return data.map((item) => Product.fromLaravel(item)).toList();
      } else {
        throw Exception('Gagal memuat produk dari server');
      }
    } catch (e) {
      throw Exception('Error koneksi API: $e');
    }
  }

  void _sortInPlace(List<Product> products, ProductSort sort) {
    switch (sort) {
      case ProductSort.newest:
        products.sort((a, b) {
          final ad = a.createdAt;
          final bd = b.createdAt;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        });
        break;
      case ProductSort.priceAsc:
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSort.priceDesc:
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
  }

  @override
  Stream<List<Product>> watchAll({ProductSort sort = ProductSort.newest}) async* {
    final products = await _fetchProductsFromLaravel();
    _sortInPlace(products, sort);
    yield products;
  }

  @override
  Stream<List<Product>> watchByCategory(
    String categoryIdentifier, {
    ProductSort sort = ProductSort.newest,
  }) async* {
    try {
      final encodedId = Uri.encodeComponent(categoryIdentifier);
      final response = await http.get(Uri.parse('$baseUrl/products-mobile/category/$encodedId'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        
        final products = data.map((item) => Product.fromLaravel(item)).toList();
        _sort_in_place_safe(products, sort);
        yield products;
      } else {
        yield [];
      }
    } catch (e) {
      yield [];
    }
  }

  void _sort_in_place_safe(List<Product> products, ProductSort sort) => _sortInPlace(products, sort);

  @override
  Future<List<Product>> getAll() async {
    final products = await _fetchProductsFromLaravel();
    _sortInPlace(products, ProductSort.newest);
    return products;
  }

  @override
  Future<Product?> getById(String id) async {
    final products = await _fetchProductsFromLaravel();
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) {
  return ApiProductRepository();
}

@riverpod
Stream<List<Product>> productsStream(
  Ref ref, {
  ProductSort sort = ProductSort.newest,
}) {
  return ref.watch(productRepositoryProvider).watchAll(sort: sort);
}

@riverpod
Stream<List<Product>> productsByCategoryStream(
  Ref ref,
  String categoryId, {
  ProductSort sort = ProductSort.newest,
}) {
  return ref
      .watch(productRepositoryProvider)
      .watchByCategory(categoryId, sort: sort);
}

@riverpod
Future<Product?> productById(Ref ref, String id) {
  return ref.watch(productRepositoryProvider).getById(id);
}