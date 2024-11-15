/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

class HeroTags {
  /// Tag used to identify the beta warning container
  static const betaWarningTag = "mindful.appbar.betaWarning";

  /// Tag used to identify the FAB for adding a distracting website.
  static const editUsernameTag = "home.dashboard.editUsername";

  /// Tag used to identify the invincible mode tile.
  static const invincibleModeTileTag = "home.dashboard.invincibleModeTile";

  /// Generates a tag for an application tile based on the provided package name.
  static String applicationTileTag(String package) =>
      "home.statistics.applicationTile.$package";

  /// Tag used to identify the schedule start time picker.
  static const scheduleStartTimePickerTag = "schedule.startTimePicker";

  /// Tag used to identify the schedule end time picker.
  static const scheduleEndTimePickerTag = "schedule.endTimePicker";

  /// Tag used to identify the short content timer picker.
  static const shortContentTimerPickerTag = "home.wellBeing.shortsTimerPicker";

  /// Tag used to identify the block NSFW sites tile in wellbeing tab.
  static const blockNsfwTileTag = "home.wellBeing.blockNsfwTile";

  /// Tag used to identify the FAB for adding a distracting website.
  static const addDistractingSiteFABTag =
      "home.wellBeing.addDistractingWebsite";

  /// Generates a tag for a website tile based on the provided host name.
  static String websiteTileTag(String host) =>
      "home.wellBeing.websiteTile.$host";

  /// Tag used to identify the emergency tile in app dashboard screen.
  static const emergencyTileTag = "appDashboard.useEmergencyTile";

  /// Generates a tag for an app timer tile based on the provided package name.
  static String appTimerTileTag(String package) =>
      "appDashboard.timerTile.$package";

  /// Generates a tag for an app launch limit tile based on the provided package name.
  static String appLaunchLimitTileTag(String package) =>
      "appDashboard.launchLimitTile.$package";

  /// Generates a tag for an app alert interval tile based on the provided package name.
  static String appAlertIntervalTileTag(String package) =>
      "appDashboard.alertIntervalTile.$package";

  /// Tag used to identify in focus mode.
  static const focusModeFABTag = "focus.focusModeFab";

  /// Tag used to identify the tile for timer picker in focus mode.
  static const focusModeTimerTileTag = "focus.focusSessionTimerTile";

  /// Tag used to identify the button for give up or finish session in active session screen.
  static const giveUpOrFinishFocusSessionTag = "activeSession.giveUpOrFinish";

  /// Tag used to identify the tile for data reset time in settings.
  static const dataResetTimeTileTag = "settings.general.dataResetTime";
  
  /// Tag used to identify the tile for clearing crash log in settings.
  static const clearCrashLogsTileTag = "settings.advance.clearCrashLogs";

  /// Tag used to identify the remove button in a restriction group card based on the group ID.
  static String removeRestrictionGroupTag(int groupId) =>
      "restrictionGroupScreen.restrictionGroup.$groupId";
}
