import 'package:flutter/material.dart';

// CDS typography scale — sourced from centraldigital/cds-flutter @ 02fb3a0
// Font family: CPN (Central Pattana font). Falls back to system sans-serif
// if the asset is not bundled in this project.
const String cdsFontFamily = 'CPN';

TextTheme buildCdsTextTheme(TextTheme base) {
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(fontSize: 40),
    displayMedium: base.displayMedium?.copyWith(fontSize: 36),
    displaySmall: base.displaySmall?.copyWith(fontSize: 32),
    headlineLarge: base.headlineLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: base.bodyLarge?.copyWith(fontSize: 16),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: 14),
    bodySmall: base.bodySmall?.copyWith(fontSize: 12),
    labelLarge: base.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: base.labelMedium?.copyWith(fontSize: 12),
    labelSmall: base.labelSmall?.copyWith(fontSize: 10),
  );
}
