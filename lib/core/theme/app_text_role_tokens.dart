import 'package:flutter/material.dart';

class AppTextRoleTokens extends ThemeExtension<AppTextRoleTokens> {
  const AppTextRoleTokens({
    required this.heroTitle,
    required this.sectionTitle,
    required this.cardTitle,
    required this.panelTitle,
    required this.body,
    required this.supportingBody,
    required this.emphasisLabel,
    required this.eyebrow,
    required this.metricValue,
  });

  final TextStyle heroTitle;
  final TextStyle sectionTitle;
  final TextStyle cardTitle;
  final TextStyle panelTitle;
  final TextStyle body;
  final TextStyle supportingBody;
  final TextStyle emphasisLabel;
  final TextStyle eyebrow;
  final TextStyle metricValue;

  @override
  AppTextRoleTokens copyWith({
    TextStyle? heroTitle,
    TextStyle? sectionTitle,
    TextStyle? cardTitle,
    TextStyle? panelTitle,
    TextStyle? body,
    TextStyle? supportingBody,
    TextStyle? emphasisLabel,
    TextStyle? eyebrow,
    TextStyle? metricValue,
  }) {
    return AppTextRoleTokens(
      heroTitle: heroTitle ?? this.heroTitle,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      cardTitle: cardTitle ?? this.cardTitle,
      panelTitle: panelTitle ?? this.panelTitle,
      body: body ?? this.body,
      supportingBody: supportingBody ?? this.supportingBody,
      emphasisLabel: emphasisLabel ?? this.emphasisLabel,
      eyebrow: eyebrow ?? this.eyebrow,
      metricValue: metricValue ?? this.metricValue,
    );
  }

  @override
  AppTextRoleTokens lerp(ThemeExtension<AppTextRoleTokens>? other, double t) {
    if (other is! AppTextRoleTokens) return this;
    return AppTextRoleTokens(
      heroTitle: TextStyle.lerp(heroTitle, other.heroTitle, t)!,
      sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      panelTitle: TextStyle.lerp(panelTitle, other.panelTitle, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      supportingBody: TextStyle.lerp(supportingBody, other.supportingBody, t)!,
      emphasisLabel: TextStyle.lerp(emphasisLabel, other.emphasisLabel, t)!,
      eyebrow: TextStyle.lerp(eyebrow, other.eyebrow, t)!,
      metricValue: TextStyle.lerp(metricValue, other.metricValue, t)!,
    );
  }

  static AppTextRoleTokens fromTextTheme(TextTheme textTheme) {
    return AppTextRoleTokens(
      heroTitle: textTheme.headlineSmall!,
      sectionTitle: textTheme.titleLarge!,
      cardTitle: textTheme.titleMedium!,
      panelTitle: textTheme.titleSmall!,
      body: textTheme.bodyMedium!,
      supportingBody: textTheme.bodySmall!,
      emphasisLabel: textTheme.labelLarge!,
      eyebrow: textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w700),
      metricValue: textTheme.headlineSmall!,
    );
  }
}
