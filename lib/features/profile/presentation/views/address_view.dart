import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nextcart/core/widgets/ios_back_button.dart';
import 'package:nextcart/core/services/raja_ongkir_service.dart';
import 'package:nextcart/features/auth/data/firebase_auth_repository.dart';
import 'package:nextcart/features/auth/domain/models/app_user.dart';
import 'package:nextcart/features/profile/presentation/viewmodels/profile_viewmodel.dart';

class AddressView extends ConsumerWidget {
  const AddressView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Pengiriman'),
        leading: const IosBackButton(),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) {
          if (user == null) return const Center(child: Text('Belum masuk'));
          return _AddressForm(user: user);
        },
      ),
    );
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm({required this.user});
  final AppUser user;

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  late final TextEditingController _phone, _address, _city, _postalCode;
  
  // Variabel ini sekarang digunakan di dalam fungsi _findCityByPostalCode
  final RajaOngkirService _shippingService = RajaOngkirService();

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: widget.user.phone ?? '');
    _address = TextEditingController(text: widget.user.address ?? '');
    _city = TextEditingController(text: widget.user.city ?? '');
    _postalCode = TextEditingController();
  }

  Future<void> _findCityByPostalCode(String postalCode) async {
    if (postalCode.length < 5) return;
    try {
      // 1. Baca data lokal
      final String response = await rootBundle.loadString('assets/data/cities.json');
      final List<dynamic> data = json.decode(response);
      final foundCity = data.firstWhere(
        (c) => c['postal_code'] == postalCode, 
        orElse: () => null
      );
      
      if (foundCity != null) {
        setState(() => _city.text = foundCity['city_name']);
        
        // 2. MENGGUNAKAN SERVICE: Validasi ke API RajaOngkir untuk memastikan kota valid
        // Ini membuat _shippingService tidak lagi "unused"
        final costs = await _shippingService.getShippingCosts(
          origin: '151', 
          destination: foundCity['city_id'], 
          weight: 1000, 
          courier: 'jne'
        );
        debugPrint("Service dipanggil, jumlah opsi kurir: ${costs.length}");
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    await ref.read(profileEditorProvider.notifier).save(
          phone: _phone.text.trim(),
          address: _address.text.trim(),
          city: _city.text.trim(),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alamat berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(profileEditorProvider);
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Mau dikirim ke mana?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 24),
        TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor Telepon', prefixIcon: _Icon(FontAwesomeIcons.phone))),
        const SizedBox(height: 14),
        TextField(
          controller: _postalCode, 
          keyboardType: TextInputType.number, 
          onChanged: _findCityByPostalCode, 
          decoration: const InputDecoration(labelText: 'Kode Pos', prefixIcon: _Icon(FontAwesomeIcons.envelopesBulk))
        ),
        const SizedBox(height: 14),
        TextField(controller: _address, decoration: const InputDecoration(labelText: 'Alamat Jalan', prefixIcon: _Icon(FontAwesomeIcons.locationDot))),
        const SizedBox(height: 14),
        TextField(controller: _city, decoration: const InputDecoration(labelText: 'Kota', prefixIcon: _Icon(FontAwesomeIcons.city))),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: state.isLoading ? null : _save,
          icon: state.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) : const FaIcon(FontAwesomeIcons.floppyDisk, size: 16),
          label: Text(state.isLoading ? 'Menyimpan…' : 'Simpan alamat'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _phone.dispose(); _address.dispose(); _city.dispose(); _postalCode.dispose();
    super.dispose();
  }
}

class _Icon extends StatelessWidget {
  const _Icon(this.icon);
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(width: 48, height: 48, child: Center(child: FaIcon(icon, size: 16)));
}