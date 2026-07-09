import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';

enum AgriBadgeVariant { primary, alert, neutral }

/// Small pill used for status/severity labels (e.g. "Healthy", "High risk").
class AgriBadge extends StatelessWidget {
  const AgriBadge({
    super.key,
    required this.label,
    this.variant = AgriBadgeVariant.primary,
    this.icon,
  });

  final String label;
  final AgriBadgeVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final (Color bg, Color fg) = switch (variant) {
      AgriBadgeVariant.primary => (
          colors.primary.withValues(alpha: 0.14),
          colors.primary,
        ),
      AgriBadgeVariant.alert => (
          colors.accent.withValues(alpha: 0.14),
          colors.accent,
        ),
      AgriBadgeVariant.neutral => (
          colors.textSecondary.withValues(alpha: 0.12),
          colors.textSecondary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
