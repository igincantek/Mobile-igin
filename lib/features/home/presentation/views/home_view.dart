import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/app/routes.dart';
import 'package:nextcart/features/auth/data/firebase_auth_repository.dart';
import 'package:nextcart/features/notifications/data/firebase_notification_repository.dart';
import 'package:nextcart/features/categories/data/firebase_category_repository.dart';
import 'package:nextcart/features/categories/domain/models/category.dart';
import 'package:nextcart/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:nextcart/features/products/data/firebase_product_repository.dart';
import 'package:nextcart/features/products/domain/models/product.dart';
import 'package:nextcart/shared/widgets/empty_state.dart';
import 'package:nextcart/shared/widgets/product_card.dart';
import 'package:nextcart/shared/widgets/product_image.dart';
import 'package:nextcart/shared/widgets/skeletons.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(shuffledHomeCategoriesProvider);
    final featuredAsync = ref.watch(shuffledFeaturedProductsProvider);
    final userAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoriesStreamProvider);
            ref.invalidate(productsStreamProvider);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // HEADER SECTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            userAsync.when(
                              data: (user) {
                                final firstName =
                                    (user?.name ?? '').split(' ').first;
                                return Text(
                                  firstName.isEmpty
                                      ? 'Selamat datang kembali'
                                      : 'Hai, $firstName 👋',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                              loading: () => Text(
                                'Selamat datang kembali',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              error: (_, __) => Text(
                                'Selamat datang kembali',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Temukan kebutuhan terbaik untuk hewan peliharaanmu',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _NotificationBell(ref: ref),
                    ],
                  ),
                ),
              ),

              // SEARCH BAR
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(99),
                    onTap: () => context.push(Routes.search),
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.magnifyingGlass,
                            size: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Cari makanan, mainan, vitamin...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // BANNER CAROUSEL
              SliverToBoxAdapter(
                child: _BannerCarousel(featuredAsync: featuredAsync),
              ),

              // KATEGORI
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Kategori Populer',
                  onSeeAll: () => context.go(Routes.categories),
                ),
              ),
              categoriesAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: CategoryGridSkeleton(),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: ErrorView(message: e.toString()),
                ),
                data: (cats) => SliverToBoxAdapter(
                  child: _CategoryHorizontalList(categories: cats.toList()),
                ),
              ),

              // PRODUK UNGGULAN
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Produk Unggulan',
                  onSeeAll: () => context.push(Routes.products),
                ),
              ),
              featuredAsync.when(
                loading: () =>
                    const SliverToBoxAdapter(child: ProductGridSkeleton()),
                error: (e, _) => SliverToBoxAdapter(
                  child: ErrorView(message: e.toString()),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: EmptyState(
                        icon: FontAwesomeIcons.boxOpen,
                        title: 'Belum ada produk',
                        message:
                            'Produk akan muncul di sini setelah katalog diperbarui.',
                      ),
                    );
                  }
                  return SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => ProductCard(
                          product: products[i],
                          onTap: () => context.push(
                            Routes.productDetailPath(products[i].id),
                          ),
                        ),
                        childCount: products.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== SECTION HEADER ====================
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'Lihat semua',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CATEGORY LIST ====================
class _CategoryHorizontalList extends StatelessWidget {
  const _CategoryHorizontalList({required this.categories});
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Kategori akan muncul setelah data diperbarui.'),
      );
    }
    return SizedBox(
      height: 105,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, i) =>
            _CategoryCardItem(category: categories[i]),
      ),
    );
  }
}

class _CategoryCardItem extends StatelessWidget {
  const _CategoryCardItem({required this.category});
  final Category category;

  Color _getDynamicColor(String name, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (name.toLowerCase().trim()) {
      case 'makanan':
        return isDark ? const Color(0xFF2A3328) : const Color(0xFFE2E7DE);
      case 'perawatan & kesehatan':
      case 'perawatan & k..':
        return isDark ? const Color(0xFF1E2E22) : const Color(0xFFEAF2E8);
      case 'perlengkapan':
        return isDark ? const Color(0xFF252B22) : const Color(0xFFF4F6F0);
      case 'vitamin & kesehatan':
      case 'vitamin & k..':
        return isDark ? const Color(0xFF2E2220) : const Color(0xFFF3E1DC);
      default:
        return isDark ? const Color(0xFF1E2E22) : const Color(0xFFEAF2E8);
    }
  }

  IconData _getIconForCategory(String nameOrId) {
    final key = nameOrId.toLowerCase().trim();
    if (key.contains('food') || key.contains('makanan')) {
      return FontAwesomeIcons.bowlFood;
    }
    if (key.contains('shampoo') || key.contains('perawatan')) {
      return FontAwesomeIcons.soap;
    }
    if (key.contains('accessories') || key.contains('perlengkapan')) {
      return FontAwesomeIcons.basketShopping;
    }
    if (key.contains('vitamin') || key.contains('kesehatan')) {
      return FontAwesomeIcons.paw;
    }
    return FontAwesomeIcons.paw;
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getDynamicColor(category.name, context);
    final iconData = _getIconForCategory(
        category.name.isNotEmpty ? category.name : category.id);
    final hasImage =
        category.image != null && category.image!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: () =>
            context.push(Routes.productsByCategoryPath(category.id)),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              height: 64,
              width: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? ProductImage(url: category.image, fit: BoxFit.cover)
                  : FaIcon(iconData,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== BANNER CAROUSEL ====================
class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({required this.featuredAsync});
  final AsyncValue<List<Product>> featuredAsync;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  static const _autoplayInterval = Duration(seconds: 4);
  static const _maxItems = 5;

  final _controller = PageController(viewportFraction: 0.88);
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_autoplayInterval, _tick);
  }

  void _tick(Timer _) {
    if (!mounted || !_controller.hasClients) return;
    final count = _itemCount;
    if (count <= 1) return;
    final next = (_index + 1) % count;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  int get _itemCount =>
      (widget.featuredAsync.value?.length ?? 0).clamp(0, _maxItems);

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.featuredAsync.value ?? const <Product>[];
    final items = products.take(_maxItems).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 195,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: items.length,
            itemBuilder: (_, i) => _BannerCard(
              product: items[i],
              isActive: i == _index,
              onTap: () => context.push(
                Routes.productDetailPath(items[i].id),
              ),
            ),
          ),
          // Dot indicators — center bottom
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: _CarouselDots(count: items.length, current: _index),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== BANNER CARD ====================
class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.product,
    required this.isActive,
    required this.onTap,
  });

  final Product product;
  final bool isActive;
  final VoidCallback onTap;

  List<Color> _gradientColors() {
    final palettes = [
      [const Color(0xFF1B4332), const Color(0xFF2D6A4F)],
      [const Color(0xFF1A237E), const Color(0xFF283593)],
      [const Color(0xFF4A148C), const Color(0xFF6A1B9A)],
      [const Color(0xFF7B1900), const Color(0xFFBF360C)],
      [const Color(0xFF1B3A4B), const Color(0xFF006494)],
    ];
    final idx = product.id.hashCode.abs() % palettes.length;
    return palettes[idx];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradientColors();

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.94,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: colors[1].withValues(alpha: 0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Dekorasi lingkaran transparan
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  right: 30,
                  bottom: -40,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),

                // Gambar produk (kanan)
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 110,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 120,
                            width: 100,
                            child: ProductImage(
                              url: product.primaryImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Konten teks (kiri)
                Positioned(
                  left: 20,
                  top: 20,
                  bottom: 20,
                  right: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge
                      if (product.isOnSale)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Hemat ${product.discountPercent}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Unggulan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Judul produk
                      Text(
                        product.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tombol CTA
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Lihat',
                          style: TextStyle(
                            color: colors[1],
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== NOTIFICATION BELL ====================
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount =
        ref.watch(unreadNotificationCountProvider).maybeWhen(
              data: (c) => c,
              orElse: () => 0,
            );

    return IconButton(
      onPressed: () => context.push(Routes.notifications),
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        fixedSize: const Size(48, 48),
      ),
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text('$unreadCount'),
        backgroundColor: theme.colorScheme.error,
        child: FaIcon(
          FontAwesomeIcons.bell,
          size: 18,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

// ==================== CAROUSEL DOTS ====================
class _CarouselDots extends StatelessWidget {
  const _CarouselDots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (i) {
          final active = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 18 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}