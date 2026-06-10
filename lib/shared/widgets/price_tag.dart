import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Menggunakan locale 'id_ID' agar format ribuan menggunakan titik (.) dan simbol otomatis Rp
final _money = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0, // Menghilangkan ,00 di belakang nominal
);

String formatPrice(num value) => _money.format(value);

class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.price,
    this.originalPrice,
    this.discountPercent = 0,
    this.dense = false,
  });

  final double price;
  final double? originalPrice;
  final int discountPercent;
  final bool dense;

  bool get _onSale =>
      discountPercent > 0 &&
      originalPrice != null &&
      originalPrice! > price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priceStyle = (dense
            ? theme.textTheme.titleSmall
            : theme.textTheme.titleMedium)
        ?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w700,
    );
    final strikeStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      decoration: TextDecoration.lineThrough,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 2,
      children: [
        Text(formatPrice(price), style: priceStyle),
        if (_onSale) Text(formatPrice(originalPrice!), style: strikeStyle),
        if (_onSale)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '-$discountPercent%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}