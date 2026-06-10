import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nextcart/app/routes.dart';
import 'package:nextcart/features/cart/data/firebase_cart_repository.dart';
import 'package:nextcart/features/cart/domain/models/cart_item.dart';
import 'package:nextcart/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:nextcart/shared/widgets/empty_state.dart';
import 'package:nextcart/shared/widgets/price_tag.dart';
import 'package:nextcart/shared/widgets/product_image.dart';
import 'package:nextcart/shared/widgets/quantity_stepper.dart';
import 'package:nextcart/shared/widgets/skeletons.dart';

final _moneyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class CartView extends ConsumerWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartAsync = ref.watch(cartStreamProvider);
    final subtotal = ref.watch(cartSubtotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          if ((cartAsync.value ?? const []).isNotEmpty)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.trashCan, size: 16),
              onPressed: () => ref.read(cartControllerProvider.notifier).clear(),
            ),
        ],
      ),
      body: cartAsync.when(
        loading: () => const ListSkeleton(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: FontAwesomeIcons.cartShopping,
              title: 'Keranjangmu masih kosong',
              message: 'Yuk, cari produk yang kamu suka.',
              actionLabel: 'Mulai belanja',
              onAction: () => context.go(Routes.home),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 220),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _CartTile(item: items[i]),
          );
        },
      ),
      bottomSheet: (cartAsync.value ?? const []).isEmpty ? null : SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, 
            border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [const Text('Subtotal'), const Spacer(), Text(_moneyFormatter.format(subtotal))]),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                const Spacer(), 
                Text(_moneyFormatter.format(subtotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, 
                child: FilledButton(
                  onPressed: () => context.push(Routes.checkout), 
                  child: const Text('Lanjut ke Pembayaran')
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartTile extends ConsumerWidget {
  const _CartTile({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    bool isAsset = item.image.startsWith('assets/');

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(16)),
        child: FaIcon(FontAwesomeIcons.trashCan, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => ref.read(cartControllerProvider.notifier).remove(item.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72, height: 72,
                child: isAsset 
                    ? Image.asset(item.image, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image))
                    : ProductImage(url: item.image),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  PriceTag(price: item.price, dense: true),
                  const SizedBox(height: 8),
                  QuantityStepper(
                    value: item.quantity,
                    onChanged: (q) => ref.read(cartControllerProvider.notifier).setQuantity(item.id, q),
                    dense: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}