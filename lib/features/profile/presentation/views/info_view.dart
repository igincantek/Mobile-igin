import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nextcart/core/widgets/ios_back_button.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Halaman konten statis untuk Privasi, Bantuan, dan Syarat & Ketentuan.
class InfoView extends StatelessWidget {
  const InfoView({super.key, required this.kind});

  final InfoKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spec = _specs[kind]!;
    return Scaffold(
      appBar: AppBar(
        title: Text(spec.title),
        leading: const IosBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                FaIcon(spec.icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    spec.tagline,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final section in spec.sections) ...[
            Text(
              section.heading,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              section.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 18),
          ],
          const SizedBox(height: 8),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.hasData
                  ? 'v${snapshot.data!.version}'
                  : 'v1.0.0';
              return Center(
                child: Text(
                  'Petshop Jinx · $version',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

enum InfoKind { privacy, help, terms }

class _Section {
  const _Section(this.heading, this.body);
  final String heading;
  final String body;
}

class _Spec {
  const _Spec({
    required this.title,
    required this.tagline,
    required this.icon,
    required this.sections,
  });
  final String title;
  final String tagline;
  final IconData icon;
  final List<_Section> sections;
}

const _specs = <InfoKind, _Spec>{
  InfoKind.privacy: _Spec(
    title: 'Kebijakan Privasi',
    tagline: 'Data kamu tetap milikmu. Berikut yang kami kumpulkan dan alasannya.',
    icon: FontAwesomeIcons.shieldHalved,
    sections: [
      _Section(
        'Apa yang kami kumpulkan',
        'Kami hanya mengumpulkan data yang diperlukan untuk mengirimkan pesananmu: nama, email, nomor telepon, alamat, dan riwayat pesanan. Kami tidak menjual datamu.',
      ),
      _Section(
        'Cara kami menggunakannya',
        'Informasi akun digunakan untuk autentikasi dan pengiriman pesanan. Sinyal penggunaan anonim membantu kami memperbaiki bug dan meningkatkan aplikasi.',
      ),
      _Section(
        'Pihak ketiga',
        'Kami menggunakan Firebase (Google) untuk autentikasi, database, dan penyimpanan. Tidak ada pelacak pemasaran yang tertanam di aplikasi ini.',
      ),
      _Section(
        'Hak kamu',
        'Kamu dapat meminta salinan datamu atau menghapus akun kapan saja. Hubungi kami melalui menu Bantuan & Dukungan.',
      ),
    ],
  ),
  InfoKind.help: _Spec(
    title: 'Bantuan & Dukungan',
    tagline: 'Butuh bantuan? Kami merespons dalam satu hari kerja.',
    icon: FontAwesomeIcons.lifeRing,
    sections: [
      _Section(
        'Masalah pesanan',
        'Untuk produk yang salah, hilang, atau rusak, buka pesanan dari menu Pesanan Saya dan ketuk "Laporkan masalah". Kami akan segera menanganinya.',
      ),
      _Section(
        'Pertanyaan pengiriman',
        'Sebagian besar pesanan dikirim dalam 24 jam dan tiba dalam 2–4 hari kerja. Pembayaran di tempat (COD) tersedia untuk semua pesanan standar.',
      ),
      _Section(
        'Akun & pembayaran',
        'Kamu bisa masuk menggunakan akun Google. Perbarui nomor telepon dan alamat pengiriman dari Profil › Alamat.',
      ),
      _Section(
        'Hubungi kami',
        'Email: support@petshopjinx.app · Jam operasional: Senin–Jumat, 09.00–18.00 WIB.',
      ),
    ],
  ),
  InfoKind.terms: _Spec(
    title: 'Syarat & Ketentuan',
    tagline: 'Perjanjian antara kamu dan Petshop Jinx.',
    icon: FontAwesomeIcons.fileLines,
    sections: [
      _Section(
        'Penggunaan layanan',
        'Kamu setuju menggunakan Petshop Jinx hanya untuk kegiatan belanja yang sah. Kamu bertanggung jawab atas keakuratan informasi yang kamu berikan.',
      ),
      _Section(
        'Pesanan & pembayaran',
        'Harga dan stok dapat berubah sewaktu-waktu. Kami berhak membatalkan pesanan jika produk salah harga atau tidak tersedia.',
      ),
      _Section(
        'Pengembalian produk',
        'Produk dapat dikembalikan dalam 7 hari setelah pengiriman dalam kondisi asli. Beberapa kategori tidak dapat dikembalikan.',
      ),
      _Section(
        'Tanggung jawab',
        'Petshop Jinx disediakan "sebagaimana adanya". Kami tidak bertanggung jawab atas kerugian tidak langsung yang timbul dari penggunaan aplikasi.',
      ),
    ],
  ),
};