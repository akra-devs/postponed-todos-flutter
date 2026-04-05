import 'package:flutter/material.dart';

abstract final class AppMotionTokens {
  // Micro transitions
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration quick = Duration(milliseconds: 220);
  static const Duration regular = Duration(milliseconds: 320);
  static const Duration graceful = Duration(milliseconds: 420);

  // Staging / stagger
  static const Duration staggerBase = Duration(milliseconds: 60);
  static const Duration staggerItem = Duration(milliseconds: 80);

  // Navigation and reveal
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration cardReveal = Duration(milliseconds: 360);

  // Curves
  static const Curve enterCurve = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve exitCurve = Curves.easeInOutCubic;
  static const Curve microSpring = Curves.easeOutBack;
}
