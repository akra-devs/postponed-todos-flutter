import 'package:flutter/material.dart';

import 'app_color_tokens.dart';
import 'app_radius_tokens.dart';
import 'app_theme_ext.dart';
import 'app_typography.dart';

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColorTokens.seed,
    brightness: Brightness.light,
  );
  final textTheme = buildAppTextTheme(
    ThemeData.light(useMaterial3: true).textTheme,
  );

  return ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColorTokens.scaffold,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorTokens.scaffold,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColorTokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorTokens.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[
      AppSurfaceTokens(
        card: AppColorTokens.card,
        cardMuted: colorScheme.surfaceContainerLow,
        holdingSurface: AppColorTokens.warmSurface,
        holdingBorder: AppColorTokens.warmBorder,
        holdingHeroSurface: AppColorTokens.holdingHeroSurface,
        holdingHeroHighlight: AppColorTokens.holdingHeroHighlight,
        holdingHeroBackground: AppColorTokens.holdingHeroBackground,
        holdingHeroIconSurface: AppColorTokens.holdingHeroIconSurface,
        holdingHeroBody: AppColorTokens.holdingHeroBody,
        reasonPanel: colorScheme.surfaceContainerLowest,
        revisitPanel: AppColorTokens.warmMuted,
        subtleAccent: AppColorTokens.warmAccent,
      ),
      AppStatusTokens(
        postponingBg: colorScheme.primaryContainer,
        postponingFg: colorScheme.onPrimaryContainer,
        shelvedBg: AppColorTokens.warmMutedStrong,
        shelvedFg: const Color(0xFF6B4E1E),
        doneBg: colorScheme.secondaryContainer,
        doneFg: colorScheme.onSecondaryContainer,
        droppedBg: colorScheme.surfaceContainerHighest,
        droppedFg: colorScheme.onSurfaceVariant,
        revisitBg: AppColorTokens.revisitBg,
        revisitFg: AppColorTokens.revisitFg,
        mutedBg: AppColorTokens.warmMutedStrong,
        mutedFg: const Color(0xFF6F6557),
      ),
    ],
  );
}
