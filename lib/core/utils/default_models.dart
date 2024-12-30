import 'package:mindful/core/database/adapters/time_of_day_adapter.dart';
import 'package:mindful/core/database/app_database.dart';
import 'package:mindful/core/enums/default_home_tab.dart';
import 'package:mindful/core/enums/session_type.dart';
import 'package:mindful/core/utils/app_constants.dart';

final defaultMindfulSettingsModel = MindfulSettings(
  id: 0,
  defaultHomeTab: DefaultHomeTab.dashboard,
  themeMode: AppConstants.defaultThemeMode,
  accentColor: AppConstants.defaultMaterialColor,
  username: AppConstants.defaultUsername,
  localeCode: AppConstants.defaultLocale,
  dataResetTime: const TimeOfDayAdapter.zero(),
  useBottomNavigation: false,
  useAmoledDark: false,
  useDynamicColors: false,
  leftEmergencyPasses: 3,
  lastEmergencyUsed: DateTime(0),
  isOnboardingDone: false,
  protectedAccess: false,
  uninstallWindowTime: const TimeOfDayAdapter.zero(),
);

const defaultSharedUniqueDataModel = SharedUniqueData(
  id: 0,
  excludedApps: [],
  notificationBatchedApps: [],
);

const defaultInvincibleModeModel = InvincibleMode(
  id: 0,
  isInvincibleModeOn: false,
  includeAppsTimer: true,
  includeAppsLaunchLimit: false,
  includeAppsActivePeriod: false,
  includeGroupsTimer: false,
  includeGroupsActivePeriod: false,
  includeShortsTimer: false,
  includeBedtimeSchedule: false,
);

const defaultWellbeingModel = Wellbeing(
  id: 0,
  allowedShortsTimeSec: 30 * 60,
  blockInstaReels: false,
  blockYtShorts: false,
  blockSnapSpotlight: false,
  blockFbReels: false,
  blockRedditShorts: false,
  blockNsfwSites: false,
  blockedWebsites: [],
);

const defaultBedtimeScheduleModel = BedtimeSchedule(
  id: 0,
  scheduleStartTime: TimeOfDayAdapter.zero(),
  scheduleEndTime: TimeOfDayAdapter.zero(),
  scheduleDurationInMins: 0,
  scheduleDays: [false, true, true, true, true, true, false],
  isScheduleOn: false,
  shouldStartDnd: false,
  distractingApps: [],
);

const defaultAppRestrictionModel = AppRestriction(
  appPackage: "",
  timerSec: 0,
  launchLimit: 0,
  activePeriodStart: TimeOfDayAdapter.zero(),
  activePeriodEnd: TimeOfDayAdapter.zero(),
  periodDurationInMins: 0,
  canAccessInternet: true,
  alertInterval: 15 * 60, // Every 15 minutes
  alertByDialog: false,
);

final defaultFocusModeModel = FocusMode(
  id: 0,
  sessionType: SessionType.study,
  longestStreak: 0,
  currentStreak: 0,
  lastTimeStreakUpdated: DateTime(0),
);

const defaultFocusProfileModel = FocusProfile(
  sessionType: SessionType.study,
  sessionDuration: 0,
  shouldStartDnd: false,
  distractingApps: [],
);
