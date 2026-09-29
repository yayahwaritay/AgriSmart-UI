import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/widgets/app_logo.dart';

/// Shown while the stored session is being restored.
///
/// Picks up where the native launch screen leaves off: the logo starts at the
/// native splash size and centre, settles into an orbiting loader, and the
/// wordmark rises beneath it. When auth resolves, the logo hero-flies into
/// the login screen (or the app simply opens for a signed-in user).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const _logoSize = 120.0;

  // flutter_native_splash renders splash_logo.png at 192dp.
  static const _nativeLogoScale = 192 / _logoSize;

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  late final Animation<double> _logoScale = Tween(begin: _nativeLogoScale, end: 1.0).animate(
    CurvedAnimation(parent: _intro, curve: const Interval(0, 0.65, curve: Curves.easeOutBack)),
  );
  late final Animation<double> _ringReveal = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
  );
  late final Animation<double> _textReveal = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.4, 1, curve: Curves.easeOutCubic),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
    } else if (_intro.isDismissed) {
      _intro.forward();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Center(
            child: AppLogoLoader(
              size: _logoSize,
              heroTag: appLogoHeroTag,
              logoScale: _logoScale,
              ringOpacity: _ringReveal,
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.42),
            child: FadeTransition(
              opacity: _textReveal,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(_textReveal),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AgriSmart',
                      style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Healthier crops, smarter harvests',
                      style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
