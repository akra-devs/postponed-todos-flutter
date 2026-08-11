import 'package:flutter/material.dart';

import 'app_color_tokens.dart';

@immutable
class ReentryAtlasTokens extends ThemeExtension<ReentryAtlasTokens> {
  const ReentryAtlasTokens({
    required this.midnight,
    required this.midnightDeep,
    required this.midnightRaised,
    required this.midnightSoft,
    required this.porcelain,
    required this.porcelainLow,
    required this.ink,
    required this.inkMuted,
    required this.periwinkle,
    required this.periwinkleDeep,
    required this.periwinkleSoft,
    required this.mint,
    required this.route,
    required this.onMidnight,
    required this.onMidnightMuted,
  });

  static const midnightPalette = ReentryAtlasTokens(
    midnight: AppColorTokens.atlasMidnight,
    midnightDeep: AppColorTokens.atlasMidnightDeep,
    midnightRaised: AppColorTokens.atlasMidnightRaised,
    midnightSoft: AppColorTokens.atlasMidnightSoft,
    porcelain: AppColorTokens.atlasPorcelain,
    porcelainLow: AppColorTokens.atlasPorcelainLow,
    ink: AppColorTokens.atlasInk,
    inkMuted: AppColorTokens.atlasInkMuted,
    periwinkle: AppColorTokens.atlasPeriwinkle,
    periwinkleDeep: AppColorTokens.atlasPeriwinkleDeep,
    periwinkleSoft: AppColorTokens.atlasPeriwinkleSoft,
    mint: AppColorTokens.atlasMint,
    route: AppColorTokens.atlasRoute,
    onMidnight: AppColorTokens.atlasOnMidnight,
    onMidnightMuted: AppColorTokens.atlasOnMidnightMuted,
  );

  final Color midnight;
  final Color midnightDeep;
  final Color midnightRaised;
  final Color midnightSoft;
  final Color porcelain;
  final Color porcelainLow;
  final Color ink;
  final Color inkMuted;
  final Color periwinkle;
  final Color periwinkleDeep;
  final Color periwinkleSoft;
  final Color mint;
  final Color route;
  final Color onMidnight;
  final Color onMidnightMuted;

  @override
  ReentryAtlasTokens copyWith({
    Color? midnight,
    Color? midnightDeep,
    Color? midnightRaised,
    Color? midnightSoft,
    Color? porcelain,
    Color? porcelainLow,
    Color? ink,
    Color? inkMuted,
    Color? periwinkle,
    Color? periwinkleDeep,
    Color? periwinkleSoft,
    Color? mint,
    Color? route,
    Color? onMidnight,
    Color? onMidnightMuted,
  }) {
    return ReentryAtlasTokens(
      midnight: midnight ?? this.midnight,
      midnightDeep: midnightDeep ?? this.midnightDeep,
      midnightRaised: midnightRaised ?? this.midnightRaised,
      midnightSoft: midnightSoft ?? this.midnightSoft,
      porcelain: porcelain ?? this.porcelain,
      porcelainLow: porcelainLow ?? this.porcelainLow,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      periwinkle: periwinkle ?? this.periwinkle,
      periwinkleDeep: periwinkleDeep ?? this.periwinkleDeep,
      periwinkleSoft: periwinkleSoft ?? this.periwinkleSoft,
      mint: mint ?? this.mint,
      route: route ?? this.route,
      onMidnight: onMidnight ?? this.onMidnight,
      onMidnightMuted: onMidnightMuted ?? this.onMidnightMuted,
    );
  }

  @override
  ReentryAtlasTokens lerp(ThemeExtension<ReentryAtlasTokens>? other, double t) {
    if (other is! ReentryAtlasTokens) return this;
    return ReentryAtlasTokens(
      midnight: Color.lerp(midnight, other.midnight, t)!,
      midnightDeep: Color.lerp(midnightDeep, other.midnightDeep, t)!,
      midnightRaised: Color.lerp(midnightRaised, other.midnightRaised, t)!,
      midnightSoft: Color.lerp(midnightSoft, other.midnightSoft, t)!,
      porcelain: Color.lerp(porcelain, other.porcelain, t)!,
      porcelainLow: Color.lerp(porcelainLow, other.porcelainLow, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      periwinkle: Color.lerp(periwinkle, other.periwinkle, t)!,
      periwinkleDeep: Color.lerp(periwinkleDeep, other.periwinkleDeep, t)!,
      periwinkleSoft: Color.lerp(periwinkleSoft, other.periwinkleSoft, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      route: Color.lerp(route, other.route, t)!,
      onMidnight: Color.lerp(onMidnight, other.onMidnight, t)!,
      onMidnightMuted: Color.lerp(onMidnightMuted, other.onMidnightMuted, t)!,
    );
  }
}

extension ReentryAtlasThemeX on ThemeData {
  ReentryAtlasTokens get reentryAtlas =>
      extension<ReentryAtlasTokens>() ?? ReentryAtlasTokens.midnightPalette;
}
