import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nextcart/core/widgets/ios_back_button.dart';
import 'package:nextcart/app/routes.dart';
import 'package:nextcart/features/orders/data/firebase_order_repository.dart';
import 'package:nextcart/features/orders/domain/models/app_order.dart';
import 'package:nextcart/shared/widgets/empty_state.dart';
import 'package:nextcart/shared/widgets/product_image.dart';
import 'package:nextcart/shared/widgets/skeletons.dart';

final _moneyFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatPrice(num value) => _moneyFormatter.format(value);

class OrderDetailView extends ConsumerWidget {
  const OrderDetailView({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        leading: const IosBackButton(),
      ),
      body: orderAsync.when(
        loading: () => const OrderDetailSkeleton(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (order) {
          if (order == null) {
            return const EmptyState(
              icon: FontAwesomeIcons.fileCircleQuestion,
              title: 'Pesanan tidak ditemukan',
              message: 'Pesanan ini mungkin sudah tidak ada atau dihapus.',
            );
          }

          final isMidtrans = order.paymentMethod == 'midtrans';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.gift,
                      color: theme.colorScheme.primary,
                      size: 26,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terima kasih atas pesanan Anda!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isMidtrans
                                ? 'Pembayaran Anda sebesar ${formatPrice(order.total)} telah kami terima.'
                                : 'Silakan siapkan uang tunai sebesar ${formatPrice(order.total)} saat kurir mengantar pesanan.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'Status Pesanan',
                child: _Timeline(status: order.status),
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'Alamat Pengiriman',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 4),
                    Text(order.deliveryPhone),
                    const SizedBox(height: 4),
                    Text('${order.deliveryAddress}, ${order.city}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'Produk yang Dibeli',
                child: Column(
                  children: [
                    for (final item in order.items) ...[
                      Row(
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: ProductImage(
                              url: item.image,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.quantity} × ${formatPrice(item.price)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatPrice(item.lineTotal),
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                    ],
                    Row(
                      children: [
                        const Text('Total Harga Produk'),
                        const Spacer(),
                        Text(formatPrice(order.subtotal)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Ongkos Kirim'),
                        const Spacer(),
                        Text(formatPrice(order.deliveryFee)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatPrice(order.total),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FaIcon(
                          isMidtrans
                              ? FontAwesomeIcons.creditCard
                              : FontAwesomeIcons.moneyBillWave,
                          color: theme.colorScheme.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isMidtrans ? 'Pembayaran Midtrans' : 'Bayar di Tempat (COD)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(Routes.home),
                  child: const Text('Lanjut Belanja'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});
  final OrderStatus status;

  static const _track = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (status == OrderStatus.cancelled) {
      return Row(
        children: [
          FaIcon(
            FontAwesomeIcons.circleXmark,
            size: 18,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            'Dibatalkan',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    final currentIdx = _track.indexOf(status);
    return Row(
      children: List.generate(_track.length * 2 - 1, (i) {
        if (i.isOdd) {
          final segDone = (i ~/ 2) < currentIdx;
          return Expanded(
            child: Container(
              height: 2,
              color: segDone
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final done = stepIdx <= currentIdx;
        
        // Menerjemahkan label status timeline ke Bahasa Indonesia
        String labelIndo;
        switch (_track[stepIdx]) {
          case OrderStatus.pending:
            labelIndo = 'Menunggu';
            break;
          case OrderStatus.confirmed:
            labelIndo = 'Dikonfirmasi';
            break;
          case OrderStatus.shipped:
            labelIndo = 'Dikirim';
            break;
          case OrderStatus.delivered:
            labelIndo = 'Selesai';
            break;
          default:
            labelIndo = _track[stepIdx].label;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: done
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: done
                  ? Center(
                      child: FaIcon(
                        FontAwesomeIcons.check,
                        size: 10,
                        color: theme.colorScheme.onPrimary,
                      )
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              labelIndo,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        );
      }),
    );
  }
}