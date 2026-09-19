import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/agrismart_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/market_providers.dart';
import '../../domain/entities/checkout_session.dart';

/// Path 1 of README.mobile.md's "Checkout — three ways to pay": starts a
/// Monime checkout session against the caller's cart and opens the hosted
/// payment page (redirect) — the entire payment experience — polling for
/// completion so the sheet reflects payment without an admin having to
/// reconcile it first.
Future<void> showMonimeCheckoutSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: SafeArea(child: _MonimeCheckoutSheet()),
    ),
  );
}

class _MonimeCheckoutSheet extends ConsumerWidget {
  const _MonimeCheckoutSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final sessionState = ref.watch(checkoutSessionControllerProvider);

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Pay with Monime', style: context.textTheme.titleLarge)),
              IconButton(
                icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          sessionState.when(
            data: (session) => _SessionView(session: session),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => _ErrorView(message: e is ApiException ? e.message : 'Could not start this payment.'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: colors.accent)),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Close', onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

class _SessionView extends StatelessWidget {
  const _SessionView({required this.session});

  final CheckoutSession session;

  Future<void> _openRedirect(BuildContext context) async {
    final uri = Uri.parse(session.redirectUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the payment page.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final expiry = session.status == CheckoutSessionStatus.pending ? session.expireTime : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Amount', style: context.textTheme.titleMedium),
            Text(
              '${session.currency} ${session.amount.toStringAsFixed(0)}',
              style: AppTheme.dataReadout(colors, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _StatusBadge(status: session.status),
        const SizedBox(height: 20),
        if (session.status == CheckoutSessionStatus.pending) ...[
          PrimaryButton(
            label: 'Open payment page',
            icon: Icons.open_in_new_rounded,
            onPressed: () => _openRedirect(context),
          ),
          if (expiry != null) ...[
            const SizedBox(height: 12),
            Text(
              'This offer expires at ${TimeOfDay.fromDateTime(expiry.toLocal()).format(context)}',
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            "We'll update this automatically once payment goes through — you can also close this and check your order later.",
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
          ),
        ] else ...[
          const SizedBox(height: 8),
          PrimaryButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CheckoutSessionStatus status;

  (String, Color) _presentation(AgriSmartColors colors) {
    switch (status) {
      case CheckoutSessionStatus.pending:
        return ('Waiting for payment…', colors.textSecondary);
      case CheckoutSessionStatus.completed:
        return ('Payment received 🎉', colors.success);
      case CheckoutSessionStatus.cancelled:
        return ('Payment cancelled', colors.accent);
      case CheckoutSessionStatus.expired:
        return ('This payment session expired', colors.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final (label, color) = _presentation(colors);
    return Row(
      children: [
        if (status == CheckoutSessionStatus.pending)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        else
          Icon(
            status == CheckoutSessionStatus.completed ? Icons.check_circle_rounded : Icons.error_rounded,
            size: 16,
            color: color,
          ),
        const SizedBox(width: 8),
        Text(label, style: context.textTheme.bodyMedium?.copyWith(color: color)),
      ],
    );
  }
}
