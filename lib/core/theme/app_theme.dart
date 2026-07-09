import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'agrismart_colors.dart';

/// Builds the light and dark [ThemeData] for AgriSmart from a single set of
/// [AgriSmartColors] tokens, so brand color changes only ever happen in one
/// place.
abstract final class AppTheme {
  static ThemeData light = _build(AgriSmartColors.light, Brightness.light);
  static ThemeData dark = _build(AgriSmartColors.dark, Brightness.dark);

  static ThemeData _build(AgriSmartColors colors, Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);

    final textTheme = _textTheme(colors, base.textTheme);

    return base.copyWith(
      brightness: brightness,
      // Screens sit on the app-wide [AmbientBackground] (installed in
      // MaterialApp.builder) so the Liquid Glass surfaces have color to blur.
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.accent,
        onSecondary: colors.onAccent,
        error: colors.accent,
        surface: colors.surface,
        onSurface: colors.textPrimary,
      ),
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: colors.divider,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        titleTextStyle: textTheme.headlineSmall,
      ),
      iconTheme: IconThemeData(color: colors.textPrimary),
      extensions: [colors],
    );
  }

  static TextTheme _textTheme(AgriSmartColors colors, TextTheme base) {
    final display = GoogleFonts.spaceGroteskTextTheme(base);
    final body = GoogleFonts.interTextTheme(base);

    return body
        .copyWith(
          displayLarge: display.displayLarge,
          displayMedium: display.displayMedium,
          displaySmall: display.displaySmall,
          headlineLarge: display.headlineLarge,
          headlineMedium: display.headlineMedium,
          headlineSmall: display.headlineSmall,
          titleLarge: display.titleLarge,
        )
        .apply(
          bodyColor: colors.textPrimary,
          displayColor: colors.textPrimary,
        );
  }

  /// Monospace style for confidence scores and other data readouts.
  static TextStyle dataReadout(AgriSmartColors colors, {double fontSize = 14}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
      letterSpacing: 0.2,
    );
  }
}
