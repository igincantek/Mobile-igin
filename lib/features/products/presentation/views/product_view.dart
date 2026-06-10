import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/app/routes.dart';
import 'package:nextcart/core/widgets/ios_back_button.dart';
import 'package:nextcart/features/categories/data/firebase_category_repository.dart';
import 'package:nextcart/features/products/data/firebase_product_repository.dart';
import 'package:nextcart/features/products/domain/product_repository.dart';
import 'package:nextcart/features/products/presentation/viewmodels/product_viewmodel.dart';
import 'package:nextcart/shared/widgets/empty_state.dart';
import 'package:nextcart/shared/widgets/product_card.dart';
import 'package:nextcart/shared/widgets/skeletons.dart';

class ProductView extends ConsumerWidget {
  const ProductView({super.key, this.categoryId});
  final String? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(productSortControllerProvider);
    final categoryAsync = ref.watch(categoriesStreamProvider);

    final title = categoryAsync.when(
      data: (categories) {
        if (categoryId == null) return 'Semua Produk';
        // FIX: try/catch menggantikan null as dynamic + ?. operator
        try {
          final category = categories.firstWhere((c) => c.id == categoryId);
          return (category.name as String?) ?? 'Produk';
        } catch (_) {
          return 'Produk';
        }
      },
      loading: () => 'Memuat...',
      error: (_, _) => 'Produk',
    );

    final productsAsync = categoryId == null
        ? ref.watch(productsStreamProvider(sort: sort))
        : ref.watch(productsByCategoryStreamProvider(categoryId!, sort: sort));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: const IosBackButton(),
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.search),
            icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SortBar(
              current: sort,
              onChanged: (s) =>
                  ref.read(productSortControllerProvider.notifier).set(s),
            ),
          ),
        ),
      ),
      body: productsAsync.when(
        loading: () => const ProductGridSkeleton(),
        error: (e, stack) => ErrorView(
          message: "Gagal memuat produk.",
          onRetry: () => ref.invalidate(categoryId == null
              ? productsStreamProvider(sort: sort)
              : productsByCategoryStreamProvider(categoryId!, sort: sort)),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const EmptyState(
              icon: FontAwesomeIcons.boxOpen,
              title: 'Produk Belum Tersedia',
              message: 'Belum ada produk untuk kategori ini.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // FIX: Dinaikkan dari 0.65 → 0.72 agar card cukup tinggi
              // untuk menampung gambar + nama produk 2 baris + harga coret
              childAspectRatio: 0.72,
            ),
            itemCount: products.length,
            itemBuilder: (_, i) => ProductCard(
              product: products[i],
              onTap: () =>
                  context.push(Routes.productDetailPath(products[i].id)),
            ),
          );
        },
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  const _SortBar({required this.current, required this.onChanged});
  final ProductSort current;
  final ValueChanged<ProductSort> onChanged;

  String _label(ProductSort s) => switch (s) {
        ProductSort.newest => 'Terbaru',
        ProductSort.priceAsc => 'Harga: Murah → Mahal',
        ProductSort.priceDesc => 'Harga: Mahal → Murah',
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ProductSort.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final s = ProductSort.values[index];
          return ChoiceChip(
            label: Text(_label(s)),
            selected: current == s,
            onSelected: (_) => onChanged(s),
          );
        },
      ),
    );
  }
}