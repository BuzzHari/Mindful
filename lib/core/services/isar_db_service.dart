import 'package:isar/isar.dart';
import 'package:mindful/models/isar/bedtime_settings.dart';
import 'package:mindful/models/isar/focus_settings.dart';
import 'package:mindful/models/isar/wellbeing_settings.dart';
import 'package:mindful/models/isar/app_settings.dart';
import 'package:path_provider/path_provider.dart';

// Generator =>  dart run build_runner build
class IsarDbService {
  static final IsarDbService instance = IsarDbService._();
  IsarDbService._();

  /// Isar instance
  late Isar _isar;

  /// Method to initialize isar database service.
  /// It should be called in main method
  Future<void> init() async {
    /// Get app's directory
    final appDirectory = await getApplicationDocumentsDirectory();

    /// initialize isar instance
    _isar = await Isar.open(
      [
        AppSettingsSchema,
        BedtimeSettingsSchema,
        FocusSettingsSchema,
        WellbeingSettingsSchema,
      ],
      directory: appDirectory.path,
    );
  }

  Future<void> saveFocusSettings(List<FocusSettings> focusItems) async =>
      _isar.writeTxn(
        () => _isar.focusSettings.putAllByAppPackage(focusItems),
      );

  Future<List<FocusSettings>> loadFocusSettings() async =>
      _isar.focusSettings.where().sortByAppPackage().findAll();

  Future<void> saveBedtimeSettings(BedtimeSettings bedtimeSettings) async =>
      _isar.writeTxn(
        () => _isar.bedtimeSettings.put(bedtimeSettings),
      );

  Future<BedtimeSettings> loadBedtimeSettings() async =>
      await _isar.bedtimeSettings.where().findFirst() ??
      const BedtimeSettings();

  Future<void> saveWellbeingSettings(
          WellbeingSettings wellbeingSettings) async =>
      _isar.writeTxn(
        () => _isar.wellbeingSettings.put(wellbeingSettings),
      );

  Future<WellbeingSettings> loadWellbeingSettings() async =>
      await _isar.wellbeingSettings.where().findFirst() ??
      const WellbeingSettings();

  Future<void> saveAppSettings(AppSettings appSettings) async => _isar.writeTxn(
        () => _isar.appSettings.put(appSettings),
      );
  Future<AppSettings> loadAppSettings() async =>
      await _isar.appSettings.where().findFirst() ?? const AppSettings();
}
