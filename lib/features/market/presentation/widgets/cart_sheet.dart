import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/market_providers.dart';
import '../../domain/entities/market_product.dart';

/// Opens the cart as a floating Liquid Glass bottom sheet with quantity
/// steppers, the order total, and checkout.
Future<void> showCartSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: CartSheet(),
    ),
  );
}

class CartSheet extends ConsumerWidget {
  const CartSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final items = ref.watch(cartItemsProvider);
    final total = ref.watch(cartTotalProvider);

    return SafeArea(
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Your cart', style: context.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Nothing here yet — add some products.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              )
            else ...[
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => Divider(color: colors.divider, height: 16),
                  itemBuilder: (context, index) => _CartLine(item: items[index]),
                ),
              ),
              Divider(color: colors.divider, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: context.textTheme.titleMedium),
                  Text(formatNaira(total), style: AppTheme.dataReadout(colors, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Checkout',
                icon: Icons.shopping_bag_rounded,
                onPressed: () {
                  ref.read(cartProvider.notifier).clear();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('Order placed 🎉 The seller will contact you to arrange delivery.'),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartLine extends ConsumerWidget {
  const _CartLine({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final cart = ref.read(cartProvider.notifier);

    return Row(
      children: [
        Text(item.product.emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.titleSmall),
              Text(
                '${item.product.priceLabel} per ${item.product.unit}',
                style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        _StepperButton(icon: Icons.remove_rounded, onTap: () => cart.removeOne(item.product.id)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('${item.quantity}', style: AppTheme.dataReadout(colors, fontSize: 14)),
        ),
        _StepperButton(icon: Icons.add_rounded, onTap: () => cart.add(item.product.id)),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return Material(
      color: colors.primary.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: colors.primary),
        ),
      ),
    );
  }
}
