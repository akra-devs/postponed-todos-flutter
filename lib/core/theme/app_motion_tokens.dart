import 'package:flutter/material.dart';

abstract final class AppMotionTokens {
  // Micro transitions
  static const Duration micro = Duration(milliseconds: 140);
  static const Duration quick = Duration(milliseconds: 250);
  static const Duration regular = Duration(milliseconds: 360);
  static const Duration graceful = Duration(milliseconds: 520);

  // Staging / stagger
  static const Duration staggerBase = Duration(milliseconds: 50);
  static const Duration staggerItem = Duration(milliseconds: 90);

  // Navigation and reveal
  static const Duration pageTransition = Duration(milliseconds: 360);
  static const Duration cardReveal = Duration(milliseconds: 430);
  static const Duration homeSectionReveal = Duration(milliseconds: 360);

  // Stagger tuning for home reveal cards
  static const double homeRecommendationStaggerStep = 0.065;
  static const double homeRevisitStaggerOffset = 0.14;
  static const double homeRevisitStaggerStep = 0.06;

  // Curves
  static const Curve enterCurve = Cubic(0.16, 0.84, 0.24, 1.0);
  static const Curve exitCurve = Curves.easeInOutQuad;
  // Motion distances
  static const double shellTabShift = 0.02;
  static const double sectionSwitchShift = 0.03;
  // Fractional slide offset for card-level reveals
  static const double homeCardLift = 0.05;

  static const Curve microSpring = Curves.easeOutCubic;
}
