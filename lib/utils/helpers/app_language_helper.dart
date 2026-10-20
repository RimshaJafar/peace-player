import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:ecommerce_app/utils/local_storage/storage_utility.dart';

class AppLanguageHelper {
  AppLanguageHelper._();

  static String titleLanguageCode({PLocalStorage? storage}) {
    final store = storage ?? PLocalStorage();
    final stored =
        store.readData<String>(AppSettingsKeys.overallTitleLanguageCode);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    final legacy = store.readData<String>(AppSettingsKeys.appLanguageCode);
    if (legacy != null && legacy.isNotEmpty) {
      return legacy;
    }
    return AppSettingsDefaults.overallTitleLanguageCode;
  }

  static String textLanguageCode({PLocalStorage? storage}) {
    final store = storage ?? PLocalStorage();
    final stored =
        store.readData<String>(AppSettingsKeys.overallTextLanguageCode);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    return AppSettingsDefaults.overallTextLanguageCode;
  }

  static String referenceAyahHadithLanguageCode({PLocalStorage? storage}) {
    final store = storage ?? PLocalStorage();
    final stored =
        store.readData<String>(AppSettingsKeys.referenceAyahHadithLanguageCode);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    final overallText =
        store.readData<String>(AppSettingsKeys.overallTextLanguageCode);
    if (overallText != null && overallText.isNotEmpty) {
      return overallText;
    }
    final legacy = store.readData<String>(AppSettingsKeys.appLanguageCode);
    if (legacy != null && legacy.isNotEmpty) {
      return legacy;
    }
    return AppSettingsDefaults.referenceAyahHadithLanguageCode;
  }

  static String pickText(Map<String, dynamic> values, String languageCode) {
    final urValue = values['ur'] ?? values['urdu'];
    final enValue = values['en'] ?? values['english'];
    if (languageCode == 'ur') {
      return (urValue as String?) ?? (enValue as String?) ?? '';
    }
    return (enValue as String?) ?? (urValue as String?) ?? '';
  }
}
