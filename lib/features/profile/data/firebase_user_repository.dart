import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nextcart/core/providers/firebase_providers.dart';
import 'package:nextcart/features/auth/domain/models/app_user.dart';
import 'package:nextcart/features/profile/domain/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_user_repository.g.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String userId) =>
      _firestore.collection('users').doc(userId);

  @override
  Future<AppUser?> getUser(String userId) async {
    final snap = await _doc(userId).get();
    if (!snap.exists) return null;
    return AppUser.fromFirestore(snap);
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? phone,
    String? address,
    String? city,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;
      if (city != null) updates['city'] = city;
      if (updates.isEmpty) return;

      // AMAN: Menggunakan .set dengan SetOptions(merge: true)
      // Jika dokumen 'users/uid' belum ada, Firestore akan membuatnya baru secara otomatis.
      // Jika sudah ada, data lama (seperti nama/email) tidak akan hilang atau tertimpa.
      await _doc(userId).set(updates, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Gagal memperbarui profil: $e');
      throw Exception('Gagal memperbarui profil di database: $e');
    }
  }
}

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return FirebaseUserRepository(ref.watch(firestoreProvider));
}