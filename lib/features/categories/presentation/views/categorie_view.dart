import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/app/routes.dart';
import 'package:nextcart/features/categories/data/firebase_category_repository.dart';
import 'package:nextcart/features/categories/domain/models/category.dart';
import 'package:nextcart/shared/widgets/empty_state.dart';
import 'package:nextcart/shared/widgets/product_image.dart';
import 'package:nextcart/shared/widgets/skeletons.dart';

class CategorieView extends ConsumerWidget {
  const CategorieView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori Produk',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jelajahi koleksi kebutuhan Anda Petshop',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
                loading: () => const CategoryListSkeleton(),
                error: (e, _) => ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(categoriesStreamProvider),
                ),
                data: (cats) {
                  if (cats.isEmpty) {
                    return const EmptyState(
                      icon: FontAwesomeIcons.tableCellsLarge,
                      title: 'Kategori Belum Ada',
                      message: 'Periksa data kategori dari server Anda.',
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.86,
                    ),
                    itemCount: cats.length,
                    itemBuilder: (_, i) => _CategoryTile(category: cats[i], index: i),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.index});
  final Category category;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Warna unik per index agar variatif
    final colorOptions = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
    ];
    final cardColor = colorOptions[index % colorOptions.length];

    bool hasImage = (category.image ?? '').isNotEmpty;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        // Menggunakan category.id agar rute produk berdasarkan kategori akurat
        onTap: () => context.push(Routes.productsByCategoryPath(category.id)),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: hasImage
                      ? ProductImage(url: category.image, fit: BoxFit.cover)
                      : Container(
                          alignment: Alignment.center,
                          color: cardColor.withValues(alpha: 0.15),
                          child: FaIcon(
                            _getIconForName(category.name),
                            size: 28,
                            color: cardColor,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Deteksi ikon otomatis berdasarkan nama kategori
  IconData _getIconForName(String name) {
    final key = name.toLowerCase().trim();
    if (key.contains('food') || key.contains('makanan')) {
      return FontAwesomeIcons.bowlFood;
    }
    if (key.contains('shampoo') || key.contains('perawatan') || key.contains('grooming')) {
      return FontAwesomeIcons.soap;
    }
    if (key.contains('accessories') || key.contains('perlengkapan') || key.contains('aksesoris')) {
      return FontAwesomeIcons.basketShopping;
    }
    if (key.contains('vitamin') || key.contains('kesehatan')) {
      return FontAwesomeIcons.paw;
    }
    return FontAwesomeIcons.paw;
  }
}
