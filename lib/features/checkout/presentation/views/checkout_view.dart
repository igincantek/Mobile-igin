import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nextcart/core/widgets/ios_back_button.dart';
import 'package:nextcart/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:nextcart/features/checkout/domain/models/city_model.dart';
import 'package:nextcart/features/checkout/domain/models/province_model.dart';

class CheckoutView extends ConsumerStatefulWidget {
  const CheckoutView({super.key});

  @override
  ConsumerState<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends ConsumerState<CheckoutView> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedProvince;
  CityModel? _selectedCity;
  String? _selectedCourier;

  final List<String> _couriers = ['JNE', 'POS', 'TIKI'];

  // Semua form harus terisi agar tombol aktif
  bool get _isFormValid =>
      _nameController.text.isNotEmpty &&
      _phoneController.text.isNotEmpty &&
      _addressController.text.isNotEmpty &&
      _selectedProvince != null &&
      _selectedCity != null &&
      _selectedCourier != null;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    // Validasi ulang di sisi UI sebelum submit
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua data dan detail alamat!'),
        ),
      );
      return;
    }

    // Trigger placeOrder dengan parameter provinceId dan selectedCityObj yang sesuai
    await ref.read(checkoutControllerProvider.notifier).placeOrder(
          customerName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          provinceId: _selectedProvince!,
          selectedCityObj: _selectedCity!,
          courier: _selectedCourier!,
        );
  }

  @override
  Widget build(BuildContext context) {
    // ── Listener: reaksi terhadap perubahan state checkout ──────────────────
    ref.listen(checkoutControllerProvider, (previous, next) async {
      // Hanya proses jika state benar-benar berubah
      if (previous == next) return;

      next.whenOrNull(
        // ── Sukses: buka halaman bayar Midtrans ──────────────────────────────
        data: (order) async {
          if (order == null || !mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Pesanan berhasil dibuat! Mengalihkan ke halaman pembayaran...'),
              duration: Duration(seconds: 2),
            ),
          );

          if (order.paymentUrl != null && order.paymentUrl!.isNotEmpty) {
            final uri = Uri.parse(order.paymentUrl!);
            try {
              final launched =
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!launched) {
                debugPrint(
                    'url_launcher: gagal membuka browser untuk ${order.paymentUrl}');
              }
            } catch (e) {
              debugPrint('url_launcher error: $e');
            }
          }

          if (mounted) Navigator.of(context).pop();
        },

        // ── Error: tampilkan pesan ke pengguna ────────────────────────────────
        error: (error, _) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memproses pesanan: $error'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        },
      );
    });

    // ── Data reaktif (Mengambil langsung dari MySQL Laravel API) ─────────────
    final cartAsync = ref.watch(mySQLCartItemsProvider);
    final subtotal = cartAsync.maybeWhen(
      data: (items) =>
          items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
      orElse: () => 0.0,
    );

    final citiesAsync = ref.watch(localCitiesProvider);
    final deliveryFee = ref.watch(shippingCostControllerProvider);
    final totalBayar = subtotal + deliveryFee;

    // Cek apakah sedang loading (untuk nonaktifkan tombol)
    final checkoutState = ref.watch(checkoutControllerProvider);
    final isLoading = checkoutState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: const IosBackButton(),
      ),
      body: citiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Gagal memuat data wilayah: $err')),
        data: (List<ProvinceModel> allProvinces) {
          // ── Hitung data dropdown ────────────────────────────────────────
          final daftarProvinsi = allProvinces
              .map((e) => e.provinsi)
              .where((p) => p.isNotEmpty)
              .toList();

          final provinsiTerpilih = allProvinces.firstWhere(
            (e) => e.provinsi == _selectedProvince,
            orElse: () => const ProvinceModel(provinsi: '', cities: []),
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Data Diri ───────────────────────────────────────────────
              const _SectionHeader(title: 'Data Pemesan'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: FontAwesomeIcons.user,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: 'Nomor Telepon',
                icon: FontAwesomeIcons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addressController,
                label: 'Alamat Detail (Jalan, RT/RW, No. Rumah)',
                icon: FontAwesomeIcons.locationDot,
              ),

              const Divider(height: 40),

              // ── Alamat Pengiriman ───────────────────────────────────────
              const _SectionHeader(title: 'Alamat Pengiriman'),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Provinsi',
                  prefixIcon: Icon(FontAwesomeIcons.map),
                ),
                isExpanded: true,
                hint: const Text('Pilih Provinsi'),
                value: _selectedProvince,
                items: daftarProvinsi
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _selectedProvince = val;
                    _selectedCity = null;
                  });
                  ref
                      .read(shippingCostControllerProvider.notifier)
                      .setShippingCost(null);
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<CityModel>(
                decoration: const InputDecoration(
                  labelText: 'Kota / Kabupaten',
                  prefixIcon: Icon(FontAwesomeIcons.city),
                ),
                isExpanded: true,
                hint: const Text('Pilih Kota / Kabupaten'),
                value: _selectedCity,
                items: _selectedProvince == null
                    ? null
                    : provinsiTerpilih.cities
                        .map((c) => DropdownMenuItem<CityModel>(
                              value: c,
                              child: Text(c.cityName ?? ''),
                            ))
                        .toList(),
                onChanged: _selectedProvince == null
                    ? null
                    : (val) {
                        if (val == null) return;
                        setState(() => _selectedCity = val);
                        ref
                            .read(shippingCostControllerProvider.notifier)
                            .setShippingCost(val);
                      },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kurir Pengiriman',
                  prefixIcon: Icon(FontAwesomeIcons.truckFast),
                ),
                hint: const Text('Pilih Kurir'),
                value: _selectedCourier,
                items: _couriers
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCourier = val),
              ),

              const Divider(height: 40),

              // ── Ringkasan Biaya ─────────────────────────────────────────
              const _SectionHeader(title: 'Ringkasan Pembayaran'),
              const SizedBox(height: 8),
              _CostRow(label: 'Subtotal', value: subtotal.toInt()),
              _CostRow(label: 'Ongkos Kirim', value: deliveryFee),
              const Divider(height: 20),
              _CostRow(
                label: 'Total Bayar',
                value: totalBayar.toInt(),
                isBold: true,
              ),

              // ── Informasi Metode Pembayaran ─────────────────────────────
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.creditCard,
                        color: Colors.blue.shade700, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pembayaran via Midtrans',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Transfer bank, kartu kredit, GoPay, OVO, QRIS, dan lainnya.',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Tombol Place Order ──────────────────────────────────────
              FilledButton(
                onPressed: (isLoading || !_isFormValid) ? null : _placeOrder,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.lock, size: 16),
                          SizedBox(width: 10),
                          Text(
                            'Bayar Sekarang',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}), // update _isFormValid
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

// ── Komponen kecil ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final int value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
        : const TextStyle(fontSize: 14);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            'Rp ${_formatRupiah(value)}',
            style: style,
          ),
        ],
      ),
    );
  }

  String _formatRupiah(int amount) {
    // Format ribuan: 150000 → 150.000
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }
}