import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/build_context_x.dart';
import 'neu_card.dart';

/// Compact dashboard tile showing an icon, a large monospaced value, and a
/// label — e.g. "12" scans this week.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accentColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final tint = accentColor ?? colors.primary;

    return NeuCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: 0.28),
                  tint.withValues(alpha: 0.10),
                ],
              ),
              border: Border.all(color: tint.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(height: 14),
          Text(value, style: AppTheme.dataReadout(colors, fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
