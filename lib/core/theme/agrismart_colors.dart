import 'package:flutter/material.dart';

/// Brand + surface tokens that aren't part of Material's [ColorScheme] —
/// neumorphic shadow pairs, glass tints, and semantic status colors.
///
/// Registered on [ThemeData.extensions] and read via
/// `Theme.of(context).extension<AgriSmartColors>()!`.
@immutable
class AgriSmartColors extends ThemeExtension<AgriSmartColors> {
  const AgriSmartColors({
    required this.background,
    required this.surface,
    required this.neuHighlight,
    required this.neuShadow,
    required this.glassTint,
    required this.glassBorder,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.divider,
  });

  final Color background;
  final Color surface;

  /// Lit edge of a neumorphic extrusion (light source side).
  final Color neuHighlight;

  /// Recessed edge of a neumorphic extrusion (shadow side).
  final Color neuShadow;

  final Color glassTint;
  final Color glassBorder;

  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;

  final Color textPrimary;
  final Color textSecondary;

  final Color success;
  final Color warning;
  final Color divider;

  static const light = AgriSmartColors(
    background: Color(0xFFEAF0E9),
    surface: Color(0xFFF4F8F3),
    neuHighlight: Color(0xFFFFFFFF),
    neuShadow: Color(0xFFC5D0C3),
    glassTint: Color(0x66FFFFFF),
    glassBorder: Color(0xB3FFFFFF),
    primary: Color(0xFF2FAE7B),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFFF7A45),
    onAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1B2B22),
    textSecondary: Color(0xFF5B6B60),
    success: Color(0xFF2FAE7B),
    warning: Color(0xFFE0A83E),
    divider: Color(0x1F1B2B22),
  );

  static const dark = AgriSmartColors(
    background: Color(0xFF12211A),
    surface: Color(0xFF17281F),
    neuHighlight: Color(0xFF20372A),
    neuShadow: Color(0xFF091510),
    glassTint: Color(0x21FFFFFF),
    glassBorder: Color(0x40FFFFFF),
    primary: Color(0xFF3EE39A),
    onPrimary: Color(0xFF06291B),
    accent: Color(0xFFFF9466),
    onAccent: Color(0xFF2E1305),
    textPrimary: Color(0xFFEAF3EC),
    textSecondary: Color(0xFF8FA598),
    success: Color(0xFF3EE39A),
    warning: Color(0xFFF0C36B),
    divider: Color(0x24EAF3EC),
  );

  @override
  AgriSmartColors copyWith({
    Color? background,
    Color? surface,
    Color? neuHighlight,
    Color? neuShadow,
    Color? glassTint,
    Color? glassBorder,
    Color? primary,
    Color? onPrimary,
    Color? accent,
    Color? onAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? divider,
  }) {
    return AgriSmartColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      neuHighlight: neuHighlight ?? this.neuHighlight,
      neuShadow: neuShadow ?? this.neuShadow,
      glassTint: glassTint ?? this.glassTint,
      glassBorder: glassBorder ?? this.glassBorder,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      divider: divider ?? this.divider,
    );
  }

  @override
  AgriSmartColors lerp(ThemeExtension<AgriSmartColors>? other, double t) {
    if (other is! AgriSmartColors) return this;
    return AgriSmartColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      neuHighlight: Color.lerp(neuHighlight, other.neuHighlight, t)!,
      neuShadow: Color.lerp(neuShadow, other.neuShadow, t)!,
      glassTint: Color.lerp(glassTint, other.glassTint, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
