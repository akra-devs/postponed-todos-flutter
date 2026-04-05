import 'package:flutter/material.dart';

/// App-level icon palette for consistent UI language.
///
/// Using a single, limited icon set keeps the interface calm and visually
/// coherent, which is important for low-pressure products.
abstract final class AppIconTokens {
  // Navigation / section-level markers
  static const IconData quickEntryPostponing = Icons.schedule;
  static const IconData quickEntryShelved = Icons.inventory_2_outlined;
  static const IconData listChevron = Icons.chevron_right_rounded;

  // Status icons
  static const IconData statusPostponing = Icons.schedule_outlined;
  static const IconData statusShelved = Icons.inventory_2_outlined;
  static const IconData statusDone = Icons.task_alt_rounded;
  static const IconData statusDropped = Icons.block_rounded;
  static const IconData statusRevisit = Icons.refresh_rounded;

  // Action icons
  static const IconData actionPrimary = Icons.arrow_forward_rounded;
  static const IconData actionOpen = Icons.open_in_new_rounded;
  static const IconData actionSnooze = Icons.nights_stay_rounded;
  static const IconData actionHold = Icons.archive_outlined;
  static const IconData actionRestore = Icons.replay_rounded;
  static const IconData actionDone = Icons.check_circle_outline_rounded;
  static const IconData actionDrop = Icons.close_rounded;
  static const IconData actionDefer = Icons.arrow_back_rounded;
}
