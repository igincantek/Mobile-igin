import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nextcart/core/providers/firebase_providers.dart';
import 'package:nextcart/features/auth/domain/auth_repository.dart';
import 'package:nextcart/features/auth/domain/models/app_user.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_auth_repository.g.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final _logger = Logger();

  static final _googleSignIn = GoogleSignIn.instance;

  @override
  Stream<User?> authState() => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Paksa pilih akun

      final googleUser = await _googleSignIn.authenticate();

      if (googleUser.authentication.idToken == null) {
        throw Exception('ID Token is null');
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      return ensureUserDocument(firebaseUser);
    } on GoogleSignInException catch (e) {
      _logger.e("Google Sign-In Exception: ${e.code}");
      rethrow;
    } catch (e) {
      _logger.e("Google Sign-In Error: $e");
      rethrow;
    }
  }

  @override
  Future<AppUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      return ensureUserDocument(firebaseUser);
    } catch (e) {
      _logger.e("Email Login Error: $e");
      rethrow;
    }
  }

  @override
  Future<AppUser?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Update display name
      if (name.isNotEmpty) {
        await firebaseUser.updateDisplayName(name);
        // Refresh user data agar displayName ter-update
        await firebaseUser.reload();
      }

      return ensureUserDocument(firebaseUser);
    } catch (e) {
      _logger.e("Email Register Error: $e");
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      _logger.e("Sign-Out Error: $e");
      rethrow;
    }
  }

  @override
  Future<AppUser?> ensureUserDocument(User firebaseUser) async {
    try {
      final ref = _firestore.collection('users').doc(firebaseUser.uid);
      final snap = await ref.get();

      if (!snap.exists) {
        final data = <String, dynamic>{
          'name': firebaseUser.displayName?.trim() ?? '',
          'email': firebaseUser.email ?? '',
          'photoUrl': firebaseUser.photoURL,
          'phone': firebaseUser.phoneNumber,
          'address': null,
          'city': null,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await ref.set(data);
      } else {
        await ref.update({
          'name': firebaseUser.displayName?.trim() ?? '',
          'email': firebaseUser.email ?? '',
          'photoUrl': firebaseUser.photoURL,
        });
      }

      final freshSnap = await ref.get();
      return AppUser.fromFirestore(freshSnap);
    } catch (e) {
      _logger.e("Ensure User Document Error: $e");
      rethrow;
    }
  }
}

// ==================== PROVIDERS ====================

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return FirebaseAuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
}

@riverpod
Stream<AppUser?> currentAppUser(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);

  return auth.authStateChanges().asyncMap((user) async {
    if (user == null) return null;

    try {
      final snap = await firestore.collection('users').doc(user.uid).get();
      if (!snap.exists) {
        await ref.read(authRepositoryProvider).ensureUserDocument(user);
        final fresh = await firestore.collection('users').doc(user.uid).get();
        return AppUser.fromFirestore(fresh);
      }
      return AppUser.fromFirestore(snap);
    } catch (e) {
      // Jika gagal mengambil data user, return null agar tidak crash
      return null;
    }
  });
}