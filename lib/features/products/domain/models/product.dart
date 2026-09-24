import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
sealed class Product with _$Product {
  const factory Product({
    required String id,
    required String title,
    required String description,
    required List<String> images,
    required double price,
    required double originalPrice,
    required int discountPercent,
    required String categoryId,
    required int stock,
    String? sourceUrl,
    DateTime? createdAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  // Penterjemah data dari API Laravel MySQL
  factory Product.fromLaravel(Map<String, dynamic> json) {
    return Product(
      id: json['id_product']?.toString() ?? '',
      title: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      // Mengubah format image_url tunggal dari Laravel menjadi bentuk List (array)
      images: json['image_url'] != null ? [json['image_url'].toString()] : [],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      originalPrice: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      discountPercent: 0, // Dikosongkan karena tidak ada diskon di Laravel
      categoryId: json['id_category']?.toString() ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  // Penterjemah data lama dari Firestore (tetap dibiarkan agar tidak error jika ada sisa kode lama)
  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data() ?? <String, dynamic>{};
    return Product(
      id: snap.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      images: List<String>.from(data['images'] as List? ?? const []),
      price: (data['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (data['originalPrice'] as num?)?.toDouble() ?? 0,
      discountPercent: (data['discountPercent'] as num?)?.toInt() ?? 0,
      categoryId: (data['categoryId'] ?? '') as String,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      sourceUrl: data['sourceUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

extension ProductX on Product {
  bool get isOnSale => discountPercent > 0 && originalPrice > price;
  bool get inStock => stock > 0;
  String? get primaryImage => images.isEmpty ? null : images.first;
}