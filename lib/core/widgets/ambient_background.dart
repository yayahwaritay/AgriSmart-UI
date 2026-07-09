import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';

/// App-wide backdrop: the base background color with large, soft color blobs
/// drifting behind every screen. Gives the Liquid Glass surfaces something to
/// blur and refract — over a flat color the glass would read as a plain card.
///
/// Installed once via `MaterialApp.builder`; screens keep transparent
/// scaffolds so it shows through everywhere.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glow = isDark ? 0.30 : 0.38;

    return ColoredBox(
      color: colors.background,
      child: Stack(
        children: [
          Positioned(top: -140, left: -100, child: _Blob(color: colors.primary.withValues(alpha: glow), size: 380)),
          Positioned(top: 160, right: -140, child: _Blob(color: colors.accent.withValues(alpha: glow * 0.8), size: 320)),
          Positioned(bottom: -160, left: -60, child: _Blob(color: colors.success.withValues(alpha: glow * 0.9), size: 360)),
          Positioned(bottom: 120, right: -80, child: _Blob(color: colors.warning.withValues(alpha: glow * 0.5), size: 240)),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
