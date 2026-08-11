import 'package:flutter/material.dart';

import 'app_color_tokens.dart';
import 'app_radius_tokens.dart';
import 'app_text_role_tokens.dart';
import 'app_theme_ext.dart';
import 'app_typography.dart';
import 'reentry_atlas_tokens.dart';

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final seededScheme = ColorScheme.fromSeed(
    seedColor: AppColorTokens.seed,
    brightness: brightness,
  );
  final isDark = brightness == Brightness.dark;
  final atlas = ReentryAtlasTokens.midnightPalette;
  final colorScheme = isDark
      ? seededScheme.copyWith(
          primary: atlas.periwinkle,
          onPrimary: atlas.midnightDeep,
          primaryContainer: atlas.midnightSoft,
          onPrimaryContainer: atlas.periwinkleSoft,
          secondary: atlas.mint,
          onSecondary: atlas.midnightDeep,
          secondaryContainer: const Color(0xFF203D3D),
          onSecondaryContainer: atlas.mint,
          surface: atlas.midnight,
          onSurface: atlas.onMidnight,
          surfaceDim: atlas.midnightDeep,
          surfaceBright: atlas.midnightSoft,
          surfaceContainerLowest: atlas.midnightDeep,
          surfaceContainerLow: atlas.midnightRaised,
          surfaceContainer: const Color(0xFF1C2940),
          surfaceContainerHigh: atlas.midnightSoft,
          surfaceContainerHighest: const Color(0xFF2B3950),
          onSurfaceVariant: atlas.onMidnightMuted,
          outline: const Color(0xFF728097),
          outlineVariant: const Color(0xFF334159),
          inverseSurface: atlas.porcelain,
          onInverseSurface: atlas.ink,
          inversePrimary: atlas.periwinkleDeep,
          shadow: Colors.black,
        )
      : seededScheme;
  final textTheme = buildAppTextTheme(
    ThemeData(brightness: brightness, useMaterial3: true).textTheme,
  );
  final card = isDark ? atlas.midnightRaised : AppColorTokens.card;
  final scaffold = isDark ? atlas.midnight : AppColorTokens.scaffold;
  final holdingSurface = isDark
      ? atlas.midnightRaised
      : AppColorTokens.warmSurface;
  final holdingBorder = isDark
      ? colorScheme.outlineVariant
      : AppColorTokens.warmBorder;
  final holdingHeroSurface = isDark
      ? atlas.midnightSoft
      : AppColorTokens.holdingHeroSurface;
  final holdingHeroHighlight = isDark
      ? const Color(0xFF24344D)
      : AppColorTokens.holdingHeroHighlight;
  final holdingHeroBackground = isDark
      ? atlas.midnightDeep
      : AppColorTokens.holdingHeroBackground;
  final holdingHeroBody = isDark
      ? atlas.onMidnight
      : AppColorTokens.holdingHeroBody;
  final warmMuted = isDark ? atlas.midnightSoft : AppColorTokens.warmMuted;
  final warmMutedStrong = isDark
      ? const Color(0xFF2B3950)
      : AppColorTokens.warmMutedStrong;

  return ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: scaffold,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
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
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
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
      fillColor: isDark ? colorScheme.surfaceContainerHigh : card,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.82),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: isDark ? atlas.midnightDeep : colorScheme.surface,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelMedium?.copyWith(
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        );
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: isDark ? atlas.midnightDeep : colorScheme.surface,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
      selectedIconTheme: IconThemeData(color: colorScheme.primary),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: const CircleBorder(),
      elevation: 7,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isDark ? atlas.midnightRaised : colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: colorScheme.outline,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: isDark ? atlas.midnightRaised : colorScheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? atlas.porcelain : colorScheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: isDark ? atlas.ink : colorScheme.onInverseSurface,
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[
      atlas,
      AppSurfaceTokens(
        card: card,
        cardMuted: colorScheme.surfaceContainerLow,
        holdingSurface: holdingSurface,
        holdingBorder: holdingBorder,
        holdingHeroSurface: holdingHeroSurface,
        holdingHeroHighlight: holdingHeroHighlight,
        holdingHeroBackground: holdingHeroBackground,
        holdingHeroIconSurface: isDark
            ? atlas.periwinkle.withValues(alpha: 0.16)
            : AppColorTokens.holdingHeroIconSurface,
        holdingHeroBody: holdingHeroBody,
        reasonPanel: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerLowest,
        revisitPanel: warmMuted,
        subtleAccent: isDark
            ? const Color(0xFF4B4337)
            : AppColorTokens.warmAccent,
      ),
      AppStatusTokens(
        postponingBg: isDark
            ? atlas.periwinkle.withValues(alpha: 0.18)
            : colorScheme.primaryContainer,
        postponingFg: isDark
            ? atlas.periwinkleSoft
            : colorScheme.onPrimaryContainer,
        shelvedBg: warmMutedStrong,
        shelvedFg: isDark ? atlas.mint : const Color(0xFF6B4E1E),
        doneBg: colorScheme.secondaryContainer,
        doneFg: colorScheme.onSecondaryContainer,
        droppedBg: colorScheme.surfaceContainerHighest,
        droppedFg: colorScheme.onSurfaceVariant,
        revisitBg: isDark
            ? atlas.mint.withValues(alpha: 0.16)
            : AppColorTokens.revisitBg,
        revisitFg: isDark ? atlas.mint : AppColorTokens.revisitFg,
        mutedBg: warmMutedStrong,
        mutedFg: isDark ? atlas.onMidnightMuted : const Color(0xFF6F6557),
      ),
      AppTextRoleTokens.fromTextTheme(textTheme),
    ],
  );
}
