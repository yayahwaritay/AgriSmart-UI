import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';

/// The core iOS-26-style Liquid Glass surface: a saturating backdrop blur, a
/// translucent tint gradient, a specular rim that catches the light on the
/// top-left and bottom-right edges, and a top sheen — so the panel reads as a
/// curved lens sitting over the content behind it.
///
/// [GlassCard] and [NeuCard] both render through this widget; use it directly
/// only for one-off surfaces that need a custom [tint] or [lift].
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
    this.blurSigma = 24,
    this.tint,
    this.lift = true,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;

  /// Color wash over the glass. Defaults to the neutral
  /// `AgriSmartColors.glassTint`; pass a translucent brand color for tinted
  /// chips and pills.
  final Color? tint;

  /// Whether the surface casts the soft ambient shadow that floats it above
  /// the backdrop. Disable for recessed or inline surfaces.
  final bool lift;

  final VoidCallback? onTap;

  /// 5x4 color matrix boosting saturation ~1.6x so the blurred backdrop glows
  /// through the glass instead of washing out to grey.
  static const List<double> _saturationBoost = [
    1.47244, -0.42912, -0.04332, 0, 0, //
    -0.12756, 1.17088, -0.04332, 0, 0, //
    -0.12756, -0.42912, 1.55668, 0, 0, //
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);
    final baseTint = tint ?? colors.glassTint;
    final tintAlpha = baseTint.a;

    return Container(
      decoration: lift
          ? BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                  spreadRadius: -6,
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.compose(
            outer: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            inner: const ColorFilter.matrix(_saturationBoost),
          ),
          child: CustomPaint(
            foregroundPainter: _SpecularRimPainter(
              cornerRadius: borderRadius,
              isDark: isDark,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                // Slightly brighter toward the light source (top-left) so the
                // tint reads as depth in the glass, not a flat wash.
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    baseTint.withValues(alpha: (tintAlpha * 1.3).clamp(0, 1)),
                    baseTint.withValues(alpha: tintAlpha * 0.6),
                  ],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: radius,
                  child: Stack(
                    children: [
                      // Top sheen — the diffuse reflection along the upper
                      // curve of the "lens".
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: radius,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0, 0.45],
                                colors: [
                                  Colors.white.withValues(alpha: isDark ? 0.07 : 0.35),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: padding, child: child),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Strokes the hairline rim with a gradient so the edge is bright where it
/// faces the light (top-left), fades mid-way, and picks up a fainter
/// catch-light on the bottom-right — the signature Liquid Glass edge.
class _SpecularRimPainter extends CustomPainter {
  const _SpecularRimPainter({required this.cornerRadius, required this.isDark});

  final double cornerRadius;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.75),
      Radius.circular(cornerRadius - 0.75),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0, 0.5, 1],
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.40 : 0.85),
          Colors.white.withValues(alpha: isDark ? 0.06 : 0.15),
          Colors.white.withValues(alpha: isDark ? 0.18 : 0.50),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_SpecularRimPainter oldDelegate) =>
      oldDelegate.cornerRadius != cornerRadius || oldDelegate.isDark != isDark;
}
