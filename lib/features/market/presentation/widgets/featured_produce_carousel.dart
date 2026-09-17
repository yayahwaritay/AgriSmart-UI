import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../application/market_providers.dart';
import '../../domain/entities/market_product.dart';

/// Horizontal rail of marketplace listings shown on the Home dashboard.
/// "Buy" adds straight to the cart; tapping a tile opens the Marketplace.
class FeaturedProduceCarousel extends ConsumerWidget {
  const FeaturedProduceCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final products = ref.watch(marketProductsProvider);

    return products.when(
      data: (items) {
        final featured = items.take(5).toList();
        if (featured.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _ProduceTile(product: featured[index]),
          ),
        );
      },
      loading: () => const SizedBox(height: 168, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Could not load the market', style: TextStyle(color: colors.accent)),
    );
  }
}

class _ProduceTile extends ConsumerWidget {
  const _ProduceTile({required this.product});

  final MarketProduct product;

  Future<void> _buy(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(cartProvider.notifier).add(product.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            content: Text('${product.name} added to cart'),
          ),
        );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;

    return SizedBox(
      width: 150,
      child: NeuCard(
        padding: const EdgeInsets.all(12),
        onTap: () => context.go('/market'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => ColoredBox(
                          color: colors.primary.withValues(alpha: 0.12),
                          child: Icon(Icons.eco_rounded, color: colors.primary, size: 20),
                        ),
                      )
                    : ColoredBox(
                        color: colors.primary.withValues(alpha: 0.12),
                        child: Icon(Icons.eco_rounded, color: colors.primary, size: 20),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              'per ${product.unit}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(product.priceLabel, style: AppTheme.dataReadout(colors, fontSize: 13)),
                ),
                _BuyPill(onTap: () => _buy(context, ref)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BuyPill extends StatelessWidget {
  const _BuyPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            'Buy',
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
