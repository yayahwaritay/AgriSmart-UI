import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';
import 'glass_card.dart';

/// Frosted, secondary-emphasis action button — used over imagery (e.g. the
/// scan preview) where a solid [PrimaryButton] would feel too heavy.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      blurSigma: 12,
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: colors.textPrimary),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: context.textTheme.titleSmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
