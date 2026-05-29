import 'package:flutter/material.dart';

// CDS light color scheme — sourced from centraldigital/cds-flutter @ 02fb3a0
const cdsLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFF50A3C),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFF7F6F5),
  onPrimaryContainer: Color(0xFF000000),
  secondary: Color(0xFF000000),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFEDEDED),
  onSecondaryContainer: Color(0xFF000000),
  tertiary: Color(0xFF006874),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF99F0FF),
  onTertiaryContainer: Color(0xFF001F24),
  error: Color(0xFFFF0000),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF212121),
  surfaceContainer: Color(0xFFF4F0EF),
  surfaceContainerHighest: Color(0xFFF4F0EF),
  onSurfaceVariant: Color(0xFF4B463E),
  outline: Color(0xFFBCBCBC),
  outlineVariant: Color(0xFFD0D0D0),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFF50A3C),
  inverseSurface: Color(0xFF34302A),
  onInverseSurface: Color(0xFFF8EFE7),
  inversePrimary: Color(0xFFFF90A1),
  scrim: Color(0xFF000000),
  surfaceDim: Color(0xFFE6E2E0),
);

// Semantic color aliases for common use cases
class CdsColors {
  CdsColors._();

  static const Color brandRed = Color(0xFFF50A3C);
  static const Color success = Color(0xFF499128);
  static const Color warning = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFFF0000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F0EF);
  static const Color onSurface = Color(0xFF212121);
  static const Color outline = Color(0xFFBCBCBC);
  static const Color disabled = Color(0xFFD9DBE9);
}
