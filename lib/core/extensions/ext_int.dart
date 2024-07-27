import 'package:flutter/material.dart';
import 'package:mindful/core/utils/strings.dart';
import 'package:mindful/core/utils/utils.dart';

extension ExtInt on int {
  /// Converts KB to MB
  int get mb => this ~/ 1024;

  /// Converts KB to GB
  double get gb => this / 1048576;

  /// Converts Seconds to Minutes
  int get inMinutes => this ~/ 60;

  /// Converts Seconds to Hours
  double get inHours => this / 3600;

  /// Converts minutes to [TimeOfDay]
  TimeOfDay get toTimeOfDay => TimeOfDay(hour: this ~/ 60, minute: this % 60);

  /// Generates day's date string based on the current day of week
  String dateFromDoW() {
    if (toInt() == now.weekday) {
      return "Today";
    } else if (toInt() == now.weekday - 1) {
      return "Yesterday";
    } else {
      final dt = DateTime.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch -
              ((now.weekday - toInt()) * 24 * 60 * 60000));
      return "${AppStrings.daysFull[toInt()]}, ${dt.day} ${AppStrings.monthsShort[dt.month - 1]}";
    }
  }

  /// Generates data usage string from data in KBs like 356 KB, 456 MB, 2.56 GB
  String toData() {
    if (toInt() < 1024) {
      return "${toInt()} KB";
    } else if (toInt().mb >= 1024) {
      return "${toInt().gb.toStringAsFixed(2)} GB";
    } else {
      return "${toInt().mb} MB";
    }
  }
}
