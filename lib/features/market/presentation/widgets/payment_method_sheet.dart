import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/payment_method.dart';

/// Lets the buyer pick one of the three ways to pay — see
/// README.mobile.md's "Checkout — three ways to pay". Returns the chosen
/// [PaymentMethod], or `null` if dismissed without choosing.
Future<PaymentMethod?> showPaymentMethodSheet(BuildContext context) {
  return showModalBottomSheet<PaymentMethod>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: SafeArea(child: _PaymentMethodSheet()),
    ),
  );
}

class _PaymentMethodSheet extends StatelessWidget {
  const _PaymentMethodSheet();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('How would you like to pay?', style: context.textTheme.titleLarge),
          const SizedBox(height: 16),
          _PaymentOptionTile(
            icon: Icons.credit_card_rounded,
            title: 'Pay online now',
            subtitle: 'Card, bank, or mobile money (incl. Orange Money) via Monime',
            onTap: () => Navigator.of(context).pop(PaymentMethod.monimeOnline),
          ),
          const SizedBox(height: 10),
          _PaymentOptionTile(
            icon: Icons.storefront_rounded,
            title: 'Cash on pickup',
            subtitle: 'Pay in person when you collect your order',
            onTap: () => Navigator.of(context).pop(PaymentMethod.cashOnPickup),
          ),
          const SizedBox(height: 10),
          _PaymentOptionTile(
            icon: Icons.schedule_rounded,
            title: 'Pay later',
            subtitle: 'Place the order now, unpaid — held for 24 hours only',
            onTap: () => Navigator.of(context).pop(PaymentMethod.unpaidHold),
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return Material(
      color: colors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
