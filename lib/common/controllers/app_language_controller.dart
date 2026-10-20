import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:ecommerce_app/utils/local_storage/storage_utility.dart';
import 'package:get/get.dart';

class AppLanguageController extends GetxController {
  final PLocalStorage _storage = PLocalStorage();

  final RxString titleLanguageCode =
      AppSettingsDefaults.overallTitleLanguageCode.obs;
  final RxString textLanguageCode =
      AppSettingsDefaults.overallTextLanguageCode.obs;
  final RxString referenceLanguageCode =
      AppSettingsDefaults.referenceAyahHadithLanguageCode.obs;

  @override
  void onInit() {
    super.onInit();
    refreshFromStorage();
  }

  void refreshFromStorage() {
    final storedTitle =
        _storage.readData<String>(AppSettingsKeys.overallTitleLanguageCode);
    final legacy = _storage.readData<String>(AppSettingsKeys.appLanguageCode);
    titleLanguageCode.value =
        storedTitle ?? legacy ?? AppSettingsDefaults.overallTitleLanguageCode;

    final storedText =
        _storage.readData<String>(AppSettingsKeys.overallTextLanguageCode);
    textLanguageCode.value =
        storedText ?? legacy ?? AppSettingsDefaults.overallTextLanguageCode;

    final storedReference = _storage
        .readData<String>(AppSettingsKeys.referenceAyahHadithLanguageCode);
    referenceLanguageCode.value = storedReference ??
        storedText ??
        legacy ??
        AppSettingsDefaults.referenceAyahHadithLanguageCode;
  }

  void setTitleLanguageCode(String code, {bool updateLegacy = true}) {
    titleLanguageCode.value = code;
    _storage.saveData(AppSettingsKeys.overallTitleLanguageCode, code);
    if (updateLegacy) {
      _storage.saveData(AppSettingsKeys.appLanguageCode, code);
    }
  }

  void setTextLanguageCode(String code, {bool updateReferenceIfUnset = true}) {
    textLanguageCode.value = code;
    _storage.saveData(AppSettingsKeys.overallTextLanguageCode, code);

    if (updateReferenceIfUnset) {
      final override = _storage
          .readData<String>(AppSettingsKeys.referenceAyahHadithLanguageCode);
      if (override == null) {
        referenceLanguageCode.value = code;
      }
    }
  }

  void setReferenceLanguageCode(String code) {
    referenceLanguageCode.value = code;
    _storage.saveData(AppSettingsKeys.referenceAyahHadithLanguageCode, code);
  }
}
