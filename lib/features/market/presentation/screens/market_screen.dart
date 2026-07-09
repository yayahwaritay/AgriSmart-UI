import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../application/market_providers.dart';
import '../../domain/entities/market_product.dart';
import '../widgets/cart_sheet.dart';
import '../widgets/product_card.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  void _addToCart(BuildContext context, WidgetRef ref, MarketProduct product) {
    ref.read(cartProvider.notifier).add(product.id);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          content: Text('${product.name} added to cart'),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final products = ref.watch(filteredProductsProvider);
    final filter = ref.watch(marketFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Marketplace', style: context.textTheme.headlineSmall),
                        const SizedBox(height: 2),
                        Text(
                          'Seeds, fertilizer & fresh harvests',
                          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const _CartButton(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: filter == null,
                    onTap: () => ref.read(marketFilterProvider.notifier).select(null),
                  ),
                  for (final category in ProductCategory.values)
                    _CategoryChip(
                      label: category.label,
                      selected: filter == category,
                      onTap: () => ref.read(marketFilterProvider.notifier).select(category),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: products.when(
                data: (items) => items.isEmpty
                    ? Center(
                        child: Text(
                          'No products in this category yet.',
                          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) => ProductCard(
                          product: items[index],
                          onAdd: () => _addToCart(context, ref, items[index]),
                        ),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Could not load the market', style: TextStyle(color: colors.accent)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartButton extends ConsumerWidget {
  const _CartButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final count = ref.watch(cartCountProvider);

    return Material(
      color: colors.primary.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => showCartSheet(context),
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            backgroundColor: colors.accent,
            child: Icon(Icons.shopping_cart_rounded, color: colors.primary, size: 22),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: colors.primary,
        backgroundColor: colors.surface.withValues(alpha: 0.6),
        labelStyle: context.textTheme.labelMedium?.copyWith(
          color: selected ? colors.onPrimary : colors.textPrimary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? Colors.transparent : colors.divider),
        ),
      ),
    );
  }
}
