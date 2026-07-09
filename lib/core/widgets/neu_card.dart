import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';
import 'liquid_glass.dart';

/// The base card surface used throughout AgriSmart, rendered as Liquid Glass.
///
/// Historically a neumorphic extrusion (hence the name); the API is kept so
/// existing call sites work unchanged: [inset] now renders a recessed,
/// more transparent pane with no lift shadow instead of a pressed extrusion.
class NeuCard extends StatelessWidget {
  const NeuCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.inset = false,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  /// When true, renders a recessed pane (fainter tint, no lift shadow) —
  /// used for the scan viewfinder well and active toggle states.
  final bool inset;

  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    final tint = color != null
        // Callers pass opaque surface colors; keep the hue but let the
        // backdrop glow through.
        ? color!.withValues(alpha: 0.45)
        : inset
            ? colors.glassTint.withValues(alpha: colors.glassTint.a * 0.5)
            : null;

    return LiquidGlass(
      padding: padding,
      borderRadius: borderRadius,
      tint: tint,
      lift: !inset,
      onTap: onTap,
      child: child,
    );
  }
}
