import 'package:flutter/material.dart';

/// App-level icon palette for consistent UI language.
///
/// Using a single, limited icon set keeps the interface calm and visually
/// coherent, which is important for low-pressure products.
abstract final class AppIconTokens {
  static const IconData quickEntryPostponing = Icons.schedule;
  static const IconData quickEntryShelved = Icons.inventory_2_outlined;
  static const IconData shellPostponing = Icons.schedule;
  static const IconData shellShelved = Icons.inventory_2;
  static const IconData listChevron = Icons.chevron_right_rounded;
  static const IconData actionPrimary = Icons.arrow_forward_rounded;
}
