import 'package:flutter/material.dart';

import 'liquid_glass.dart';

/// A Liquid Glass panel: saturating backdrop blur, translucent tint, and a
/// specular rim. Sits on top of imagery or the ambient gradient backdrop
/// (e.g. the scan preview, the floating nav bar).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
    this.blurSigma = 24,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      padding: padding,
      borderRadius: borderRadius,
      blurSigma: blurSigma,
      onTap: onTap,
      child: child,
    );
  }
}
