<div align="center">

# Petshop Jinx - Flutter E-Commerce App

**Aplikasi mobile e-commerce petshop siap pakai, dibangun dengan Flutter & Firebase**

*Aplikasi belanja hewan peliharaan dengan keranjang, wishlist, checkout, lacak pesanan, pembayaran Midtrans & notifikasi*

*Clean Architecture | Riverpod | Firestore | Material Design 3*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-State_Management-0553B1?style=flat-square&logo=riverpod&logoColor=white)](https://riverpod.dev)
[![Midtrans](https://img.shields.io/badge/Midtrans-Payment_Gateway-003366?style=flat-square&logo=stripe&logoColor=white)](https://midtrans.com)
[![License](https://img.shields.io/badge/License-Private-red?style=flat-square)]()
[![Platform](https://img.shields.io/badge/Platform-Android_|_iOS_|_Web-green?style=flat-square)]()

[![Download APK](https://img.shields.io/badge/Download_APK-v1.0.0-brightgreen?style=for-the-badge&logo=android&logoColor=white)](assets/apk/petshop-jinx-v1.0.0.apk)

</div>

---

## Overview

Petshop Jinx adalah aplikasi e-commerce petshop untuk Android, iOS, dan Web. Menyediakan pengalaman belanja online lengkap mulai dari menjelajahi produk, pencarian, keranjang belanja, wishlist, checkout dengan pembayaran via Midtrans (Transfer Bank, QRIS, e-Wallet), pelacakan pesanan secara real-time, hingga notifikasi push. Dibangun dengan clean architecture dan didukung Firebase untuk autentikasi, database, dan penyimpanan.

---

## Tech Stack

- **Flutter** (Dart 3.8+) — cross-platform (Android, iOS, Web)
- **Firebase** — Auth, Firestore, Cloud Storage, Cloud Messaging
- **Midtrans Snap.js** — payment gateway (Transfer Bank, QRIS, GoPay, OVO, dll)
- **Riverpod** — state management (dengan code generation)
- **GoRouter** — declarative routing dengan auth guards (StatefulShellRoute)
- **Freezed** — immutable data models
- **Dio** — HTTP networking
- **GNav** — modern bottom navigation bar
- **Local Notifications** — push notification untuk update status pesanan
- **Material Design 3** — UI bertema hijau dengan responsive layout (ScreenUtil)

## Fitur

- Google Sign-In & Firebase Authentication
- Katalog produk dengan filter kategori
- Pencarian produk full-text
- Keranjang belanja (tambah, hapus, ubah jumlah)
- Wishlist (simpan produk favorit)
- Checkout dengan detail pengiriman
- **Pembayaran via Midtrans** (Transfer Bank, QRIS, GoPay, OVO, Dana, Kartu Kredit)
- Riwayat pesanan dengan pelacakan status real-time (pending, dikonfirmasi, dikirim, diterima)
- Notifikasi push saat status pesanan berubah
- Pusat notifikasi in-app dengan badge belum dibaca
- Profil pengguna & manajemen alamat pengiriman
- Mode gelap / terang / mengikuti sistem
- Alur onboarding untuk pengguna baru
- UI responsif untuk Android, iOS & Web

## Struktur Proyek

```
lib/
├── app/                # Router, routes, navigation shell
├── core/               # DI providers, theme, storage, utils, shared widgets
├── features/           # Modul fitur (Clean Architecture)
│   ├── auth/           #   Autentikasi
│   ├── home/           #   Halaman utama
│   ├── categories/     #   Kategori produk
│   ├── products/       #   Daftar produk
│   ├── product_detail/ #   Detail produk
│   ├── cart/           #   Keranjang belanja
│   ├── checkout/       #   Proses checkout & pembayaran
│   ├── orders/         #   Manajemen pesanan
│   ├── notifications/  #   Notifikasi push & in-app
│   ├── wishlist/       #   Wishlist
│   ├── profile/        #   Profil pengguna
│   └── search/         #   Pencarian produk
└── shared/             # Widget bersama seluruh aplikasi
```

Setiap fitur mengikuti pemisahan layer **data / domain / presentation**.

## Memulai

### Prasyarat

- Flutter SDK (stable channel)
- Dart 3.8+
- Android Studio / Xcode (untuk emulator)
- Proyek Firebase (lihat [dokumentasi setup Firebase](https://firebase.google.com/docs/flutter/setup))
- Akun Midtrans (lihat [Midtrans Dashboard](https://dashboard.midtrans.com))

### Setup

```bash
# Clone repo
git clone https://github.com/igincantek/MOBIKEIGIN.git
cd MOBIKEIGIN

# Install dependensi
flutter pub get

# Jalankan code generation (Freezed, Riverpod, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Jalankan aplikasi
flutter run
```

### Konfigurasi Environment

Buat file `.env` di root project:

```env
MIDTRANS_CLIENT_KEY=SB-Mid-client-xxxxxxxxxxxx
MIDTRANS_SERVER_KEY=SB-Mid-server-xxxxxxxxxxxx
MIDTRANS_IS_PRODUCTION=false
```

> Gunakan key **Sandbox** untuk development dan testing. Ganti ke key **Production** saat live.

### Perintah Berguna

```bash
# Mode watch untuk code generation (otomatis re-run saat file berubah)
dart run build_runner watch --delete-conflicting-outputs

# Jalankan linter
flutter analyze

# Jalankan test
flutter test

# Build release APK
flutter build apk

# Build untuk iOS
flutter build ios

# Build untuk web
flutter build web
```

## Setup Firebase

Aplikasi menggunakan layanan Firebase berikut:

| Layanan | Kegunaan |
|---------|---------|
| Firebase Auth | Autentikasi pengguna (email, Google Sign-In) |
| Cloud Firestore | Katalog produk, pesanan, keranjang, notifikasi, data pengguna |
| Cloud Storage | Gambar produk dan aset |
| Cloud Messaging | Izin notifikasi push dan manajemen token |

Aturan keamanan Firestore mengizinkan pembacaan publik untuk produk/kategori dan penulisan terbatas per pengguna untuk keranjang, pesanan, dan notifikasi. Lihat [firestore.rules](firestore.rules) dan [storage.rules](storage.rules).

## Setup Midtrans

Aplikasi menggunakan **Midtrans Snap** sebagai payment gateway.

### Alur Pembayaran

1. User melakukan checkout dan memilih metode pembayaran
2. Aplikasi mengirim request ke backend untuk membuat transaksi Midtrans
3. Backend mengembalikan `snap_token`
4. Aplikasi membuka Midtrans Snap UI via `snap_token`
5. User menyelesaikan pembayaran (Transfer Bank, QRIS, e-Wallet, dll)
6. Callback Snap menangkap hasil pembayaran dan memperbarui status pesanan

### Metode Pembayaran yang Didukung

| Metode | Keterangan |
|--------|-----------|
| Transfer Bank | BCA, BNI, BRI, Mandiri, Permata |
| QRIS | Semua aplikasi yang mendukung QRIS |
| GoPay | Dompet digital Gojek |
| OVO | Dompet digital OVO |
| Dana | Dompet digital Dana |
| Kartu Kredit/Debit | Visa, Mastercard |
| Indomaret / Alfamart | Pembayaran tunai di minimarket |

### Konfigurasi di Aplikasi

```dart
// core/config/midtrans_config.dart
class MidtransConfig {
  static const String clientKey = String.fromEnvironment('MIDTRANS_CLIENT_KEY');
  static const bool isProduction = bool.fromEnvironment('MIDTRANS_IS_PRODUCTION');

  static String get snapUrl => isProduction
      ? 'https://app.midtrans.com/snap/snap.js'
      : 'https://app.sandbox.midtrans.com/snap/snap.js';
}
```

> **Catatan:** Karena keterbatasan webhook di localhost, status pembayaran ditangani melalui callback Snap.js sisi client.

### Notifikasi

Ketika status pesanan berubah di Firestore, aplikasi akan:
1. Mendeteksi perubahan melalui listener stream pesanan real-time
2. Menulis dokumen notifikasi ke `users/{uid}/notifications/`
3. Menampilkan notifikasi push lokal di perangkat
4. Mengetuk notifikasi akan membuka halaman detail pesanan

## Arsitektur

Aplikasi mengikuti **Clean Architecture** dengan tiga layer per fitur:

1. **Data** — implementasi repository (Firebase, API calls, Midtrans)
2. **Domain** — model (kelas Freezed), antarmuka repository
3. **Presentation** — widget UI, ViewModel (Riverpod providers)

Dependency injection ditangani via Riverpod providers di `core/di/`.

## Lisensi

Proyek ini bersifat privat dan tidak dilisensikan untuk redistribusi.

---

<div align="center">

**Dibuat oleh Made Igin · Dibangun dengan Flutter, Firebase & Midtrans**

`petshop` `flutter-ecommerce` `flutter-shopping-app` `shopping-cart` `online-store` `flutter-app` `flutter` `dart` `firebase` `firestore` `riverpod` `clean-architecture` `material-design-3` `go-router` `freezed` `midtrans` `payment-gateway` `push-notifications` `wishlist` `order-tracking` `google-sign-in` `cross-platform`

</div>
