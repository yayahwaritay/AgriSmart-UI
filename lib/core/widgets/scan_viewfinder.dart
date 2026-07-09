import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';

/// Organic, continuously-morphing blob viewfinder used to frame the camera
/// preview on the Scan screen. When [scanning] is true, an animated
/// scan-line sweeps through the clipped area.
class ScanViewfinder extends StatefulWidget {
  const ScanViewfinder({
    super.key,
    required this.child,
    this.size = 300,
    this.scanning = false,
  });

  final Widget child;
  final double size;
  final bool scanning;

  @override
  State<ScanViewfinder> createState() => _ScanViewfinderState();
}

class _ScanViewfinderState extends State<ScanViewfinder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _morphController;
  final List<double> _phases = List.generate(8, (i) => i * 0.9);

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return AnimatedBuilder(
      animation: _morphController,
      builder: (context, _) {
        final clipper = _BlobClipper(t: _morphController.value, phases: _phases);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.28),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipPath(clipper: clipper, child: widget.child),
              ),
              if (widget.scanning)
                ClipPath(clipper: clipper, child: const _ScanSweep()),
              CustomPaint(
                painter: _BlobBorderPainter(path: clipper.blobPath(widget.size), color: colors.primary),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Builds a smoothly-interpolated closed blob path from 8 anchor points
/// wobbling around a circle, connected with quadratic beziers through their
/// midpoints (a cheap Catmull-Rom substitute that stays visually organic).
class _BlobClipper extends CustomClipper<Path> {
  _BlobClipper({required this.t, required this.phases});

  final double t;
  final List<double> phases;

  Path blobPath(double size) => _buildPath(Size.square(size));

  Path _buildPath(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2 * 0.92;
    final n = phases.length;

    final points = List.generate(n, (i) {
      final angle = 2 * math.pi * i / n;
      final wobble = 0.12 * math.sin(2 * math.pi * t + phases[i]) +
          0.05 * math.sin(4 * math.pi * t + phases[i] * 1.7);
      final r = baseRadius * (1 + wobble);
      return center + Offset(math.cos(angle), math.sin(angle)) * r;
    });

    Offset mid(Offset a, Offset b) => Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);

    final start = mid(points[n - 1], points[0]);
    final path = Path()..moveTo(start.dx, start.dy);
    for (var i = 0; i < n; i++) {
      final next = points[(i + 1) % n];
      final m = mid(points[i], next);
      path.quadraticBezierTo(points[i].dx, points[i].dy, m.dx, m.dy);
    }
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) => _buildPath(size);

  @override
  bool shouldReclip(covariant _BlobClipper oldClipper) => oldClipper.t != t;
}

class _BlobBorderPainter extends CustomPainter {
  _BlobBorderPainter({required this.path, required this.color});

  final Path path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.2), color, color.withValues(alpha: 0.2)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobBorderPainter oldDelegate) =>
      oldDelegate.path != path || oldDelegate.color != color;
}

/// Gradient bar that sweeps top-to-bottom while a scan is in progress.
class _ScanSweep extends StatefulWidget {
  const _ScanSweep();

  @override
  State<_ScanSweep> createState() => _ScanSweepState();
}

class _ScanSweepState extends State<_ScanSweep> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final y = _controller.value * constraints.maxHeight;
            return Stack(
              children: [
                Positioned(
                  top: y - 28,
                  left: 0,
                  right: 0,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.primary.withValues(alpha: 0),
                          colors.primary.withValues(alpha: 0.45),
                          colors.primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
