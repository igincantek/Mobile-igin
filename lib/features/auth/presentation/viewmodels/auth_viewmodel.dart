import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nextcart/features/auth/data/firebase_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (!ref.mounted) return;
      state = const AsyncData(null);
    } on GoogleSignInException catch (e) {
      if (!ref.mounted) return;
      state = AsyncError(_googleMessage(e), StackTrace.current);
    } on FirebaseAuthException catch (e) {
      if (!ref.mounted) return;
      state = AsyncError(_firebaseMessage(e), StackTrace.current);
    } on SocketException catch (_) {
      if (!ref.mounted) return;
      state = AsyncError(
        'Tidak ada koneksi internet. Silakan cek jaringan Anda.',
        StackTrace.current,
      );
    } catch (e, st) {
      if (!ref.mounted) return;
      if (_isNetworkError(e)) {
        state = AsyncError(
          'Tidak ada koneksi internet. Silakan cek jaringan Anda.',
          StackTrace.current,
        );
      } else {
        state = AsyncError('Gagal masuk dengan Google. Silakan coba lagi.', st);
      }
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email, password);
      if (!ref.mounted) return;
      state = const AsyncData(null);
    } on FirebaseAuthException catch (e) {
      if (!ref.mounted) return;
      state = AsyncError(_firebaseMessage(e), StackTrace.current);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncError(
          'Gagal masuk. Silakan periksa kembali email & password Anda.', st);
    }
  }

  Future<bool> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signUpWithEmailAndPassword(email, password, name);
      if (!ref.mounted) return false;
      state = const AsyncData(null);
      return true;
    } on FirebaseAuthException catch (e) {
      if (!ref.mounted) return false;

      // Pesan error yang lebih spesifik untuk registrasi
      String errorMessage = _firebaseMessage(e);
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email ini sudah terdaftar. Silakan login atau gunakan email lain.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password terlalu lemah. Gunakan minimal 6 karakter dengan kombinasi huruf dan angka.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid.';
      }

      state = AsyncError(errorMessage, StackTrace.current);
      return false;
    } catch (e, st) {
      if (!ref.mounted) return false;
      state = AsyncError('Gagal mendaftarkan akun. Silakan coba lagi.', st);
      return false;
    }
  }

  // Google Sign In Error Message
  String _googleMessage(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Login dibatalkan.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Login terputus. Silakan coba lagi.';
      default:
        if (_isNetworkError(e)) {
          return 'Tidak ada koneksi internet. Silakan cek jaringan Anda.';
        }
        return 'Gagal masuk dengan Google. Silakan coba lagi.';
    }
  }

  // Firebase Error Message
  String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Silakan cek jaringan Anda.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan. Hubungi bantuan.';
      case 'account-exists-with-different-credential':
        return 'Akun dengan email ini sudah terdaftar menggunakan metode lain.';
      case 'invalid-credential':
        return 'Kredensial tidak valid.';
      case 'email-already-in-use':
        return 'Email ini sudah digunakan oleh akun lain.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Silakan tunggu beberapa saat.';
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  bool _isNetworkError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('timeout');
  }
}