import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/market_providers.dart';
import '../../domain/entities/cart.dart';

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

class CartSheet extends ConsumerStatefulWidget {
  const CartSheet({super.key});

  @override
  ConsumerState<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends ConsumerState<CartSheet> {
  bool _checkingOut = false;

  Future<void> _checkout() async {
    setState(() => _checkingOut = true);
    try {
      final order = await ref.read(cartProvider.notifier).checkout();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Order placed 🎉 ${order.totalLabel} · ${order.status.name}'),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final cartState = ref.watch(cartProvider);

    return SafeArea(
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Your cart', style: context.textTheme.titleLarge),
            const SizedBox(height: 12),
            cartState.when(
              data: (cart) => cart.items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Nothing here yet — add some products.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: cart.items.length,
                            separatorBuilder: (_, _) => Divider(color: colors.divider, height: 16),
                            itemBuilder: (context, index) => _CartLine(item: cart.items[index]),
                          ),
                        ),
                        Divider(color: colors.divider, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: context.textTheme.titleMedium),
                            Text(cart.totalLabel, style: AppTheme.dataReadout(colors, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _checkingOut
                            ? const Center(child: CircularProgressIndicator())
                            : PrimaryButton(
                                label: 'Checkout',
                                icon: Icons.shopping_bag_rounded,
                                onPressed: _checkout,
                              ),
                      ],
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  e is ApiException ? e.message : 'Could not load your cart',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartLine extends ConsumerWidget {
  const _CartLine({required this.item});

  final CartLine item;

  Future<void> _adjust(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final cart = ref.read(cartProvider.notifier);

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 32,
            height: 32,
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => ColoredBox(color: colors.primary.withValues(alpha: 0.12)),
                  )
                : ColoredBox(
                    color: colors.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.eco_rounded, size: 16, color: colors.primary),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.titleSmall),
              Text(
                '${item.unitPriceLabel} per ${item.unit}',
                style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        _StepperButton(
          icon: Icons.remove_rounded,
          onTap: () => _adjust(context, ref, () => cart.removeOne(item.productId)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('${item.quantity}', style: AppTheme.dataReadout(colors, fontSize: 14)),
        ),
        _StepperButton(
          icon: Icons.add_rounded,
          onTap: () => _adjust(context, ref, () => cart.add(item.productId)),
        ),
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
