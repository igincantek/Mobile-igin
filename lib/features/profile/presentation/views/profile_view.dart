import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/app/routes.dart';
import 'package:nextcart/core/theme/app_theme.dart';
import 'package:nextcart/core/theme/theme_provider.dart';
import 'package:nextcart/features/auth/data/firebase_auth_repository.dart';
import 'package:nextcart/features/auth/domain/models/app_user.dart';
import 'package:nextcart/features/cart/data/firebase_cart_repository.dart';
import 'package:nextcart/features/orders/data/firebase_order_repository.dart';
import 'package:nextcart/features/wishlist/data/firebase_wishlist_repository.dart';
import 'package:nextcart/shared/widgets/skeletons.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final userAsync = ref.watch(currentAppUserProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    final ordersCount = ref
        .watch(ordersStreamProvider)
        .maybeWhen(data: (o) => o.length, orElse: () => 0);
    final cartCount = ref
        .watch(cartStreamProvider)
        .maybeWhen(
          data: (c) => c.fold<int>(0, (s, x) => s + x.quantity),
          orElse: () => 0,
        );
    final wishlistCount = ref
        .watch(wishlistStreamProvider)
        .maybeWhen(data: (w) => w.length, orElse: () => 0);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: userAsync.when(
        loading: () => const ProfileSkeleton(),
        error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Belum masuk'));
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _Hero(
                user: user,
                orders: ordersCount,
                cartItems: cartCount,
                saved: wishlistCount,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    _Section(
                      title: 'Tampilan',
                      child: _ThemeRow(
                        mode: themeMode,
                        onChanged: (m) {
                          ref
                              .read(themeModeControllerProvider.notifier)
                              .toggleTheme();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Akun',
                      padded: false,
                      child: Column(
                        children: [
                          _Tile(
                            icon: FontAwesomeIcons.receipt,
                            title: 'Pesanan Saya',
                            trailing: ordersCount == 0 ? null : Text('$ordersCount'),
                            onTap: () => context.push(Routes.orders),
                          ),
                          _Tile(
                            icon: FontAwesomeIcons.heart,
                            title: 'Wishlist Saya',
                            trailing: wishlistCount == 0 ? null : Text('$wishlistCount'),
                            onTap: () => context.push(Routes.wishlist),
                          ),
                          _Tile(
                            icon: FontAwesomeIcons.locationDot,
                            title: 'Alamat Pengiriman',
                            onTap: () => context.push(Routes.address),
                          ),
                          _Tile(
                            icon: FontAwesomeIcons.shieldHalved,
                            title: 'Kebijakan Privasi',
                            onTap: () => context.push(Routes.privacy),
                          ),
                          _Tile(
                            icon: FontAwesomeIcons.lifeRing,
                            title: 'Bantuan & Dukungan',
                            onTap: () => context.push(Routes.help),
                          ),
                          _Tile(
                            icon: FontAwesomeIcons.fileLines,
                            title: 'Syarat & Ketentuan',
                            onTap: () => context.push(Routes.terms),
                          ),
                          const Divider(height: 1),
                          _Tile(
                            icon: FontAwesomeIcons.rightFromBracket,
                            title: 'Keluar',
                            danger: true,
                            onTap: () => _confirmSignOut(context, ref),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.hasData
                            ? 'v${snapshot.data!.version}'
                            : 'v1.0.0';
                        final appName = snapshot.hasData ? snapshot.data!.appName : 'NextCart';
                        return Text(
                          '$appName · $version',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Keluar dari akun?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kamu perlu masuk lagi untuk melanjutkan belanja.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Keluar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (yes != true) return;

    try {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.go(Routes.auth);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal keluar: $e')),
      );
    }
  }
}

// ==================== WIDGETS LAINNYA (Tetap sama) ====================

class _Hero extends StatelessWidget {
  const _Hero({
    required this.user,
    required this.orders,
    required this.cartItems,
    required this.saved,
  });

  final AppUser user;
  final int orders;
  final int cartItems;
  final int saved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, Color(0xFFA2CB8B)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Profil',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Avatar(photoUrl: user.photoUrl, size: 80),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              user.email,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  _StatTile(label: 'Pesanan', value: '$orders'),
                  _Divider(),
                  _StatTile(label: 'Keranjang', value: '$cartItems'),
                  _Divider(),
                  _StatTile(label: 'Disimpan', value: '$saved'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.size});
  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: (photoUrl == null || photoUrl!.isEmpty)
            ? Container(
                color: Colors.white,
                child: const FaIcon(
                  FontAwesomeIcons.user,
                  color: AppTheme.primary,
                  size: 36,
                ),
              )
            : CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => const CircularProgressIndicator(),
                errorWidget: (_, _, _) => Container(
                  color: Colors.white,
                  child: const FaIcon(
                    FontAwesomeIcons.user,
                    color: AppTheme.primary,
                    size: 36,
                  ),
                ),
              ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 1,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.padded = true,
  });
  final String title;
  final Widget child;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, padded ? 6 : 0),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: padded
                ? const EdgeInsets.fromLTRB(16, 8, 16, 16)
                : EdgeInsets.zero,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.danger = false,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = danger ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 28,
        child: Center(child: FaIcon(icon, color: color, size: 18)),
      ),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      trailing: trailing != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                trailing!,
                const SizedBox(width: 10),
                FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            )
          : FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.mode, required this.onChanged});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        FaIcon(
          FontAwesomeIcons.circleHalfStroke,
          color: theme.colorScheme.primary,
          size: 16,
        ),
        const SizedBox(width: 12),
        const Expanded(child: Text('Tema Tampilan')),
        SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              icon: FaIcon(FontAwesomeIcons.circleHalfStroke, size: 14),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: FaIcon(FontAwesomeIcons.sun, size: 14),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: FaIcon(FontAwesomeIcons.moon, size: 14),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    );
  }
}