import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
sealed class Category with _$Category {
  // OKE: Baris 'const Category._();' sudah dihapus untuk menghilangkan error linter Dart terbaru

  const factory Category({
    required String id,
    required String name,
    String? icon,
    String? image,
    @Default(0) int order,
  }) = _Category;

  // Konversi JSON Manual
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] ?? '') as String,
      name: (json['Name'] ?? json['name'] ?? '') as String,
      icon: json['icon'] as String?,
      image: (json['Image'] ?? json['image']) as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  // Konversi Firestore Snapshot Manual
  factory Category.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data() ?? <String, dynamic>{};
    return Category(
      id: snap.id,
      name: (data['Name'] ?? data['name'] ?? '') as String,
      icon: data['icon'] as String?,
      image: (data['Image'] ?? data['image']) as String?,
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }
}