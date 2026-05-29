// CDS design tokens vendored from centraldigital/cds-flutter @ 02fb3a0e6e7a7e0f
// Source: https://github.com/centraldigital/cds-flutter (read-only reference)
// Board decision: vendor snapshot for v0.1; revisit subtree/path-dep in v0.2.

import 'package:flutter/material.dart';
import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

ThemeData buildCdsTheme() {
  final base = ThemeData(
    colorScheme: cdsLightColorScheme,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
  );

  final textTheme = buildCdsTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: cdsLightColorScheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CdsRadius.button),
        ),
        backgroundColor: cdsLightColorScheme.onPrimaryContainer,
        foregroundColor: cdsLightColorScheme.primaryContainer,
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(0, CdsButton.height),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CdsRadius.button),
        ),
        backgroundColor: cdsLightColorScheme.secondary,
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(0, CdsButton.height),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CdsRadius.button),
        ),
        foregroundColor: cdsLightColorScheme.onSurface,
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(0, CdsButton.height),
        disabledForegroundColor: CdsColors.disabled,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: CdsElevation.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CdsRadius.card),
      ),
      color: cdsLightColorScheme.surface,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.all(CdsSpacing.sm),
    ),
  );
}
