import 'package:flutter/material.dart';

import 'app_color_tokens.dart';
import 'app_radius_tokens.dart';
import 'app_text_role_tokens.dart';
import 'app_theme_ext.dart';
import 'app_typography.dart';

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColorTokens.seed,
    brightness: brightness,
  );
  final isDark = brightness == Brightness.dark;
  final textTheme = buildAppTextTheme(
    ThemeData(brightness: brightness, useMaterial3: true).textTheme,
  );
  final card = isDark ? colorScheme.surfaceContainerLow : AppColorTokens.card;
  final scaffold = isDark ? colorScheme.surface : AppColorTokens.scaffold;
  final holdingSurface = isDark
      ? const Color(0xFF211F1A)
      : AppColorTokens.warmSurface;
  final holdingBorder = isDark
      ? const Color(0xFF5C5448)
      : AppColorTokens.warmBorder;
  final holdingHeroSurface = isDark
      ? const Color(0xFF312D25)
      : AppColorTokens.holdingHeroSurface;
  final holdingHeroHighlight = isDark
      ? const Color(0xFF29261F)
      : AppColorTokens.holdingHeroHighlight;
  final holdingHeroBackground = isDark
      ? const Color(0xFF201E19)
      : AppColorTokens.holdingHeroBackground;
  final holdingHeroBody = isDark
      ? const Color(0xFFF0E8DB)
      : AppColorTokens.holdingHeroBody;
  final warmMuted = isDark ? const Color(0xFF3A342B) : AppColorTokens.warmMuted;
  final warmMutedStrong = isDark
      ? const Color(0xFF4A4136)
      : AppColorTokens.warmMutedStrong;

  return ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: scaffold,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: scaffold,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: card,
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
      fillColor: card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[
      AppSurfaceTokens(
        card: card,
        cardMuted: colorScheme.surfaceContainerLow,
        holdingSurface: holdingSurface,
        holdingBorder: holdingBorder,
        holdingHeroSurface: holdingHeroSurface,
        holdingHeroHighlight: holdingHeroHighlight,
        holdingHeroBackground: holdingHeroBackground,
        holdingHeroIconSurface: isDark
            ? const Color(0x1AFFFFFF)
            : AppColorTokens.holdingHeroIconSurface,
        holdingHeroBody: holdingHeroBody,
        reasonPanel: colorScheme.surfaceContainerLowest,
        revisitPanel: warmMuted,
        subtleAccent: isDark
            ? const Color(0xFF4B4337)
            : AppColorTokens.warmAccent,
      ),
      AppStatusTokens(
        postponingBg: colorScheme.primaryContainer,
        postponingFg: colorScheme.onPrimaryContainer,
        shelvedBg: warmMutedStrong,
        shelvedFg: isDark ? const Color(0xFFFFDC9B) : const Color(0xFF6B4E1E),
        doneBg: colorScheme.secondaryContainer,
        doneFg: colorScheme.onSecondaryContainer,
        droppedBg: colorScheme.surfaceContainerHighest,
        droppedFg: colorScheme.onSurfaceVariant,
        revisitBg: isDark ? const Color(0xFF5B3A14) : AppColorTokens.revisitBg,
        revisitFg: isDark ? const Color(0xFFFFDC9B) : AppColorTokens.revisitFg,
        mutedBg: warmMutedStrong,
        mutedFg: isDark ? const Color(0xFFE6DCCF) : const Color(0xFF6F6557),
      ),
      AppTextRoleTokens.fromTextTheme(textTheme),
    ],
  );
}
