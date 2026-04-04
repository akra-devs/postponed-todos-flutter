import 'package:flutter/material.dart';

import 'app_color_tokens.dart';

class AppSurfaceTokens extends ThemeExtension<AppSurfaceTokens> {
  const AppSurfaceTokens({
    required this.card,
    required this.cardMuted,
    required this.holdingSurface,
    required this.holdingBorder,
    required this.reasonPanel,
    required this.revisitPanel,
    required this.subtleAccent,
  });

  final Color card;
  final Color cardMuted;
  final Color holdingSurface;
  final Color holdingBorder;
  final Color reasonPanel;
  final Color revisitPanel;
  final Color subtleAccent;

  @override
  AppSurfaceTokens copyWith({
    Color? card,
    Color? cardMuted,
    Color? holdingSurface,
    Color? holdingBorder,
    Color? reasonPanel,
    Color? revisitPanel,
    Color? subtleAccent,
  }) {
    return AppSurfaceTokens(
      card: card ?? this.card,
      cardMuted: cardMuted ?? this.cardMuted,
      holdingSurface: holdingSurface ?? this.holdingSurface,
      holdingBorder: holdingBorder ?? this.holdingBorder,
      reasonPanel: reasonPanel ?? this.reasonPanel,
      revisitPanel: revisitPanel ?? this.revisitPanel,
      subtleAccent: subtleAccent ?? this.subtleAccent,
    );
  }

  @override
  AppSurfaceTokens lerp(ThemeExtension<AppSurfaceTokens>? other, double t) {
    if (other is! AppSurfaceTokens) return this;
    return AppSurfaceTokens(
      card: Color.lerp(card, other.card, t)!,
      cardMuted: Color.lerp(cardMuted, other.cardMuted, t)!,
      holdingSurface: Color.lerp(holdingSurface, other.holdingSurface, t)!,
      holdingBorder: Color.lerp(holdingBorder, other.holdingBorder, t)!,
      reasonPanel: Color.lerp(reasonPanel, other.reasonPanel, t)!,
      revisitPanel: Color.lerp(revisitPanel, other.revisitPanel, t)!,
      subtleAccent: Color.lerp(subtleAccent, other.subtleAccent, t)!,
    );
  }

  static AppSurfaceTokens fallback(ColorScheme scheme) => AppSurfaceTokens(
    card: AppColorTokens.card,
    cardMuted: scheme.surfaceContainerLow,
    holdingSurface: AppColorTokens.warmSurface,
    holdingBorder: AppColorTokens.warmBorder,
    reasonPanel: scheme.surfaceContainerLowest,
    revisitPanel: AppColorTokens.warmMuted,
    subtleAccent: AppColorTokens.warmAccent,
  );
}

class AppStatusTokens extends ThemeExtension<AppStatusTokens> {
  const AppStatusTokens({
    required this.postponingBg,
    required this.postponingFg,
    required this.shelvedBg,
    required this.shelvedFg,
    required this.doneBg,
    required this.doneFg,
    required this.droppedBg,
    required this.droppedFg,
    required this.revisitBg,
    required this.revisitFg,
    required this.mutedBg,
    required this.mutedFg,
  });

  final Color postponingBg;
  final Color postponingFg;
  final Color shelvedBg;
  final Color shelvedFg;
  final Color doneBg;
  final Color doneFg;
  final Color droppedBg;
  final Color droppedFg;
  final Color revisitBg;
  final Color revisitFg;
  final Color mutedBg;
  final Color mutedFg;

  @override
  AppStatusTokens copyWith({
    Color? postponingBg,
    Color? postponingFg,
    Color? shelvedBg,
    Color? shelvedFg,
    Color? doneBg,
    Color? doneFg,
    Color? droppedBg,
    Color? droppedFg,
    Color? revisitBg,
    Color? revisitFg,
    Color? mutedBg,
    Color? mutedFg,
  }) {
    return AppStatusTokens(
      postponingBg: postponingBg ?? this.postponingBg,
      postponingFg: postponingFg ?? this.postponingFg,
      shelvedBg: shelvedBg ?? this.shelvedBg,
      shelvedFg: shelvedFg ?? this.shelvedFg,
      doneBg: doneBg ?? this.doneBg,
      doneFg: doneFg ?? this.doneFg,
      droppedBg: droppedBg ?? this.droppedBg,
      droppedFg: droppedFg ?? this.droppedFg,
      revisitBg: revisitBg ?? this.revisitBg,
      revisitFg: revisitFg ?? this.revisitFg,
      mutedBg: mutedBg ?? this.mutedBg,
      mutedFg: mutedFg ?? this.mutedFg,
    );
  }

  @override
  AppStatusTokens lerp(ThemeExtension<AppStatusTokens>? other, double t) {
    if (other is! AppStatusTokens) return this;
    return AppStatusTokens(
      postponingBg: Color.lerp(postponingBg, other.postponingBg, t)!,
      postponingFg: Color.lerp(postponingFg, other.postponingFg, t)!,
      shelvedBg: Color.lerp(shelvedBg, other.shelvedBg, t)!,
      shelvedFg: Color.lerp(shelvedFg, other.shelvedFg, t)!,
      doneBg: Color.lerp(doneBg, other.doneBg, t)!,
      doneFg: Color.lerp(doneFg, other.doneFg, t)!,
      droppedBg: Color.lerp(droppedBg, other.droppedBg, t)!,
      droppedFg: Color.lerp(droppedFg, other.droppedFg, t)!,
      revisitBg: Color.lerp(revisitBg, other.revisitBg, t)!,
      revisitFg: Color.lerp(revisitFg, other.revisitFg, t)!,
      mutedBg: Color.lerp(mutedBg, other.mutedBg, t)!,
      mutedFg: Color.lerp(mutedFg, other.mutedFg, t)!,
    );
  }

  static AppStatusTokens fallback(ColorScheme scheme) => AppStatusTokens(
    postponingBg: scheme.primaryContainer,
    postponingFg: scheme.onPrimaryContainer,
    shelvedBg: AppColorTokens.warmMutedStrong,
    shelvedFg: const Color(0xFF6B4E1E),
    doneBg: scheme.secondaryContainer,
    doneFg: scheme.onSecondaryContainer,
    droppedBg: scheme.surfaceContainerHighest,
    droppedFg: scheme.onSurfaceVariant,
    revisitBg: AppColorTokens.revisitBg,
    revisitFg: AppColorTokens.revisitFg,
    mutedBg: AppColorTokens.warmMutedStrong,
    mutedFg: const Color(0xFF6F6557),
  );
}

extension AppThemeX on ThemeData {
  AppSurfaceTokens get appSurfaces =>
      extension<AppSurfaceTokens>() ?? AppSurfaceTokens.fallback(colorScheme);

  AppStatusTokens get appStatus =>
      extension<AppStatusTokens>() ?? AppStatusTokens.fallback(colorScheme);
}
