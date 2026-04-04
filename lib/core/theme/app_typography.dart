import 'package:flutter/material.dart';

TextTheme buildAppTextTheme(TextTheme base) {
  return base.copyWith(
    headlineSmall: base.headlineSmall?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.4,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.2,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: 15, height: 1.5),
    bodySmall: base.bodySmall?.copyWith(fontSize: 13, height: 1.45),
    labelLarge: base.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.2,
    ),
    labelMedium: base.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
  );
}
