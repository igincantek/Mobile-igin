import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextcart/features/auth/domain/models/app_user.dart';

abstract class AuthRepository {
  Stream<User?> authState();
  User? get currentUser;
  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> signInWithEmailAndPassword(String email, String password);
  Future<AppUser?> signUpWithEmailAndPassword(String email, String password, String name);
  Future<void> signOut();
  Future<AppUser?> ensureUserDocument(User firebaseUser);
}