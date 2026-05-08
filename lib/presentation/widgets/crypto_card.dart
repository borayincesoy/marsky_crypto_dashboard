import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/crypto_entity.dart';

class CryptoCard extends StatelessWidget {
  final CryptoEntity crypto;
  final int displayIndex;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const CryptoCard({
    super.key,
    required this.crypto,
    required this.displayIndex,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    final volumeFormat = NumberFormat.compactCurrency(symbol: r'$');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    displayIndex.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crypto.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          crypto.symbol,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MCap: ${volumeFormat.format(crypto.marketCap)}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(crypto.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        crypto.priceChange >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: crypto.priceChange >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${crypto.priceChange.abs().toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: crypto.priceChange >= 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  crypto.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: crypto.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: onFavoriteTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
