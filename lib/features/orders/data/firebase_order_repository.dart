import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nextcart/core/providers/firebase_providers.dart';
import 'package:nextcart/features/orders/domain/models/app_order.dart';
import 'package:nextcart/features/orders/domain/order_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_order_repository.g.dart';

class FirebaseOrderRepository implements OrderRepository {
  FirebaseOrderRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userCol(String userId) =>
      _firestore.collection('users').doc(userId).collection('orders');

  CollectionReference<Map<String, dynamic>> get globalCol =>
      _firestore.collection('orders');

  @override
  Stream<List<AppOrder>> watchOrders(String userId) {
    return _userCol(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AppOrder.fromFirestore).toList());
  }

  @override
  Future<AppOrder?> getById(String userId, String orderId) async {
    final snap = await _userCol(userId).doc(orderId).get();
    if (!snap.exists) return null;
    return AppOrder.fromFirestore(snap);
  }

  @override
  Future<void> updateStatus(
      String userId, String orderId, OrderStatus status) async {
    final update = <String, dynamic>{
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await Future.wait([
      _userCol(userId).doc(orderId).update(update),
      globalCol.doc(orderId).update(update),
    ]);
  }

  @override
  Future<AppOrder> placeOrder(String userId, CheckoutDetails details) async {
    final dummyId = globalCol.doc().id;
    return placeOrderWithId(
      userId: userId,
      orderId: dummyId,
      details: details,
      snapToken: '',
      paymentUrl: '',
    );
  }

  @override
  Future<AppOrder> placeOrderWithId({
    required String userId,
    required String orderId,
    required CheckoutDetails details,
    required String snapToken,
    required String paymentUrl,
  }) async {
    final userRef = _userCol(userId).doc(orderId);
    final globalRef = globalCol.doc(orderId);

    final items = details.items
        .map((c) => OrderLine(
              productId: c.productId,
              title: c.title,
              image: c.image,
              price: c.price,
              quantity: c.quantity,
            ))
        .toList(growable: false);

    final data = <String, dynamic>{
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': details.subtotal,
      'deliveryFee': details.deliveryFee,
      'total': details.total,
      'deliveryAddress': details.address,
      'deliveryPhone': details.phone,
      'customerName': details.customerName,
      'city': details.city,
      'courier': details.courier ?? 'Unknown',
      'paymentMethod': snapToken.isNotEmpty ? 'midtrans' : 'cash_on_delivery',
      'status': OrderStatus.pending.name,
      'snapToken': snapToken.isNotEmpty ? snapToken : null,
      'paymentUrl': paymentUrl.isNotEmpty ? paymentUrl : null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final globalData = <String, dynamic>{...data, 'userId': userId};

    final batch = _firestore.batch();
    batch.set(userRef, data);
    batch.set(globalRef, globalData);
    await batch.commit();

    return AppOrder(
      id: orderId,
      items: items,
      subtotal: details.subtotal,
      deliveryFee: details.deliveryFee,
      total: details.total,
      deliveryAddress: details.address,
      deliveryPhone: details.phone,
      customerName: details.customerName,
      city: details.city,
      paymentMethod: snapToken.isNotEmpty ? 'midtrans' : 'cash_on_delivery',
      snapToken: snapToken.isNotEmpty ? snapToken : null,
      paymentUrl: paymentUrl.isNotEmpty ? paymentUrl : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

@Riverpod(keepAlive: true)
OrderRepository orderRepository(Ref ref) {
  return FirebaseOrderRepository(ref.watch(firestoreProvider));
}

@riverpod
Stream<List<AppOrder>> ordersStream(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final user = auth.currentUser;
  if (user == null) return Stream.value(const <AppOrder>[]);
  return ref.watch(orderRepositoryProvider).watchOrders(user.uid);
}

@riverpod
Future<AppOrder?> orderById(Ref ref, String orderId) {
  final auth = ref.watch(firebaseAuthProvider);
  final user = auth.currentUser;
  if (user == null) return Future.value(null);
  return ref.watch(orderRepositoryProvider).getById(user.uid, orderId);
}