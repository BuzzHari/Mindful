import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/core/services/isar_db_service.dart';
import 'package:mindful/core/services/method_channel_service.dart';
import 'package:mindful/models/isar/wellbeing_settings.dart';

/// A Riverpod state notifier provider that manages well-being related settings.
final wellBeingProvider = StateNotifierProvider<WellBeingNotifier, WellBeingSettings>((ref) {
  return WellBeingNotifier();
});

/// This class manages the state of well-being settings.
class WellBeingNotifier extends StateNotifier<WellBeingSettings> {
  WellBeingNotifier() : super(const WellBeingSettings()) {
    _init();
  }

  /// Initializes the well-being settings by loading them from the database and setting up a listener to save changes.
  void _init() async {
    state = await IsarDbService.instance.loadWellBeingSettings();

    /// Listen to provider and save changes to Isar database and platform service
    addListener((state) async {
      await IsarDbService.instance.saveWellBeingSettings(state);
      await MethodChannelService.instance.updateWellBeingSettings(state);
    });
  }

  /// Toggles the block status for Instagram Reels.
  void switchBlockInstaReels() =>
      state = state.copyWith(blockInstaReels: !state.blockInstaReels);

  /// Toggles the block status for YouTube Shorts.
  void switchBlockYtShorts() =>
      state = state.copyWith(blockYtShorts: !state.blockYtShorts);

  /// Toggles the block status for Snapchat Spotlight.
  void switchBlockSnapSpotlight() =>
      state = state.copyWith(blockSnapSpotlight: !state.blockSnapSpotlight);

  /// Toggles the block status for Facebook Reels.
  void switchBlockFbReels() =>
      state = state.copyWith(blockFbReels: !state.blockFbReels);

  /// Toggles the block status for NSFW websites.
  void switchBlockNsfwSites() =>
      state = state.copyWith(blockNsfwSites: !state.blockNsfwSites);

  /// Adds or removes a website host to the blocked websites list.
  void insertRemoveBlockedSite(String websiteHost, bool shouldInsert) async =>
      state = state.copyWith(
        blockedWebsites: shouldInsert
            ? [...state.blockedWebsites, websiteHost]
            : [...state.blockedWebsites.where((e) => e != websiteHost)],
      );

  /// Sets the allowed time limit for short content consumption.
  void setAllowedShortContentTime(int timeSec) =>
      state = state.copyWith(allowedShortContentTimeSec: timeSec);
}
