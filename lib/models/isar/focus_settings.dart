import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'focus_settings.g.dart';

/// Focus info model used in mapping app package to its focus settings like
/// [timer], [emergencyCounter] and [lastEmergencyTime]
@immutable
@collection
class FocusSettings {
  /// ID for isar database
  Id get id => Isar.autoIncrement;

  /// Package name of the app this model and settings corresponds to
  @Index(unique: true)
  final String appPackage;

  /// App timer in seconds
  final int timer;

  /// Flag denoting if this app's can access internet or not
  final bool internetAccess;

  /// Focus settings for each installed app
  const FocusSettings({
    required this.appPackage,
    this.timer = 0,
    this.internetAccess = true,
  });

  FocusSettings copyWith({
    String? appPackage,
    int? timer,
    bool? internetAccess,
  }) {
    return FocusSettings(
      appPackage: appPackage ?? this.appPackage,
      timer: timer ?? this.timer,
      internetAccess: internetAccess ?? this.internetAccess,
    );
  }
}
