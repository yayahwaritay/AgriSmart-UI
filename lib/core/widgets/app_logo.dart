import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';

/// Hero tag shared by the logo on splash → login → register, so the emblem
/// glides between the auth screens instead of popping in on each one.
const appLogoHeroTag = 'agrismart-logo';

/// The AgriSmart emblem (globe, leaves and farmer) on its white disc.
///
/// The artwork is a white disc so it reads the same on light and dark
/// backgrounds; [elevated] adds a soft brand-tinted shadow to lift it off
/// the ambient backdrop. Pass [heroTag] only where the logo should fly
/// between routes — two heroes with one tag on the same route assert.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 48, this.elevated = true, this.heroTag});

  static const asset = 'assets/branding/logo_mark.png';

  final double size;
  final bool elevated;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    final logo = Semantics(
      label: 'AgriSmart logo',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isDark ? Border.all(color: colors.glassBorder, width: size > 64 ? 2 : 1) : null,
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: isDark ? 0.28 : 0.22),
                    blurRadius: size * 0.35,
                    offset: Offset(0, size * 0.08),
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: Image.asset(
            asset,
            width: size,
            height: size,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            // Decode at display size — the source is 512px and this is used
            // at 36–140px in lists and headers.
            cacheWidth: (size * dpr).round(),
          ),
        ),
      ),
    );

    if (heroTag == null) return logo;
    return Hero(tag: heroTag!, child: logo);
  }
}

/// [AppLogo] that gently floats and breathes — a living "growing" feel for
/// the auth screens. Falls back to a still logo when the OS asks for reduced
/// motion.
class FloatingAppLogo extends StatefulWidget {
  const FloatingAppLogo({super.key, this.size = 96, this.heroTag = appLogoHeroTag});

  final double size;
  final Object? heroTag;

  @override
  State<FloatingAppLogo> createState() => _FloatingAppLogoState();
}

class _FloatingAppLogoState extends State<FloatingAppLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = AppLogo(size: widget.size, heroTag: widget.heroTag);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOutSine.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -widget.size * 0.05 * t),
          child: Transform.scale(scale: 1 + 0.025 * t, child: child),
        );
      },
      child: logo,
    );
  }
}

/// Branded loading indicator: the logo inside an orbiting arc, like a
/// satellite circling the globe in the emblem. Use for full-screen waits
/// (app start, long network calls) where a bare spinner feels generic.
///
/// [logoScale] and [ringOpacity] let an intro animation drive the two parts
/// separately (see SplashScreen).
class AppLogoLoader extends StatefulWidget {
  const AppLogoLoader({super.key, this.size = 120, this.heroTag, this.logoScale, this.ringOpacity});

  final double size;
  final Object? heroTag;
  final Animation<double>? logoScale;
  final Animation<double>? ringOpacity;

  @override
  State<AppLogoLoader> createState() => _AppLogoLoaderState();
}

class _AppLogoLoaderState extends State<AppLogoLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    final ringSize = widget.size * 1.28;

    return Semantics(
      label: 'Loading',
      child: SizedBox.square(
        dimension: ringSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FadeTransition(
              opacity: widget.ringOpacity ?? kAlwaysCompleteAnimation,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size.square(ringSize),
                  painter: _OrbitPainter(
                    progress: _orbit,
                    color: colors.primary,
                    track: colors.primary.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
            ScaleTransition(
              scale: widget.logoScale ?? kAlwaysCompleteAnimation,
              child: AppLogo(size: widget.size, heroTag: widget.heroTag),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.progress, required this.color, required this.track}) : super(repaint: progress);

  final Animation<double> progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.028;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke);

    canvas.drawCircle(rect.center, arcRect.width / 2, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track);

    final start = progress.value * 2 * math.pi - math.pi / 2;
    const sweep = math.pi * 0.7;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: sweep,
        colors: [color.withValues(alpha: 0), color],
        transform: GradientRotation(start),
      ).createShader(arcRect);
    canvas.drawArc(arcRect, start, sweep, false, arc);

    // The "satellite" leading the arc.
    final head = start + sweep;
    final r = arcRect.width / 2;
    canvas.drawCircle(
      rect.center + Offset(math.cos(head) * r, math.sin(head) * r),
      stroke * 1.1,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.color != color || old.track != track;
}
