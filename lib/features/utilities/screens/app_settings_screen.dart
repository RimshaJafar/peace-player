import 'package:ecommerce_app/common/controllers/app_language_controller.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/responsive/max_width_wrapper.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/common/widgets/bottom_sheets/hadith_option_picker.dart';
import 'package:ecommerce_app/common/widgets/bottom_sheets/quran_option_picker.dart';
import 'package:ecommerce_app/features/islamic_prayer/controllers/prayer_times_controller.dart';
import 'package:ecommerce_app/features/quran_hadith/controllers/quran_hadith_controller.dart';
import 'package:ecommerce_app/features/quran_hadith/models/audio_url_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/tafseer_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/translation_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/local_storage/storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design tokens from the "Serene Path" design system ───
class _DS {
  static const Color primary = Color(0xFF00694D);
  static const Color secondary = Color(0xFF006A63);
  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF2F4F5);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF3E4943);
  static const Color outline = Color(0xFF6E7A73);
  static const Color outlineVariant = Color(0xFFBEC9C2);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1D6E54), Color(0xFF2D8B6B)],
  );

  static BoxShadow softShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.04),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  static TextStyle body(double size,
          {FontWeight weight = FontWeight.w500, Color? color}) =>
      GoogleFonts.plusJakartaSans(
          fontSize: size, fontWeight: weight, color: color ?? onSurface);

  static TextStyle label({Color? color}) => GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: color ?? outline);
}

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final userController = Get.find<UserController>();
  final AppLanguageController languageController =
      Get.isRegistered<AppLanguageController>()
          ? Get.find<AppLanguageController>()
          : Get.put(AppLanguageController());
  final QuranHadithController quranHadithController =
      Get.isRegistered<QuranHadithController>()
          ? Get.find<QuranHadithController>()
          : Get.put(QuranHadithController());
  final PLocalStorage _storage = PLocalStorage();

  bool _quranExpanded = true;
  bool _hadithExpanded = true;
  bool _prayerExpanded = true;

  // Selection state
  late String _selectedTranslationLanguage;
  late String _selectedTranslator;
  String? _selectedTafseerLanguage;
  String? _selectedTafseerWriter;
  late String _selectedReciterLanguage;
  late String _selectedReciter;
  late String _selectedHadithLang;
  late String _selectedPrayerMadhab;
  late String _overallTitleLanguageCode;
  late String _overallTextLanguageCode;
  late String _referenceAyahHadithLanguageCode;

  @override
  void initState() {
    super.initState();
    _loadDefaultsFromStorage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      quranHadithController.fetchTranslations();
      quranHadithController.fetchTafseers();
      quranHadithController.fetchAudioUrls();
      quranHadithController.fetchHadithTranslationLanguages();
    });
  }

  void _loadDefaultsFromStorage() {
    _selectedTranslationLanguage = _storage
            .readData<String>(QuranHadithSettingsKeys.translationLanguage) ??
        QuranHadithDefaults.surahsAyahsTilesDefaultTranslationLanguage;
    _selectedTranslator = _storage
            .readData<String>(QuranHadithSettingsKeys.translationTranslator) ??
        QuranHadithDefaults
            .surahsAyahsTilesDefaultTranslationLanguageTranslator;
    _selectedReciterLanguage =
        _storage.readData<String>(QuranHadithSettingsKeys.reciterLanguage) ??
            QuranHadithDefaults.surahsAyahsTilesDefaultRecitationLanguage;
    _selectedReciter = _storage
            .readData<String>(QuranHadithSettingsKeys.reciterName) ??
        QuranHadithDefaults.surahsAyahsTilesDefaultRecitationLanguageReciter;
    _selectedHadithLang =
        _storage.readData<String>(QuranHadithSettingsKeys.hadithLanguage) ??
            QuranHadithDefaults
                .hadithBooksChaptersHadithsDefaultTranslationLanguage;
    _selectedPrayerMadhab = _normalizePrayerMadhab(
      _storage.readData<String>(PrayerTimesSettingsKeys.asrMadhab),
    );
    _selectedTafseerLanguage =
        _storage.readData<String>(QuranHadithSettingsKeys.tafseerLanguage);
    _selectedTafseerWriter =
        _storage.readData<String>(QuranHadithSettingsKeys.tafseerWriter);
    final storedTitleLanguage =
        _storage.readData<String>(AppSettingsKeys.overallTitleLanguageCode);
    final legacyLanguage =
        _storage.readData<String>(AppSettingsKeys.appLanguageCode);
    _overallTitleLanguageCode = storedTitleLanguage ??
        legacyLanguage ??
        AppSettingsDefaults.overallTitleLanguageCode;
    final storedTextLanguage =
        _storage.readData<String>(AppSettingsKeys.overallTextLanguageCode);
    _overallTextLanguageCode = storedTextLanguage ??
        legacyLanguage ??
        AppSettingsDefaults.overallTextLanguageCode;
    _referenceAyahHadithLanguageCode = _storage.readData<String>(
            AppSettingsKeys.referenceAyahHadithLanguageCode) ??
        _overallTextLanguageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      backgroundColor: _DS.background,
      body: Column(
        children: [
          // ─── Scrollable Content ───
          Expanded(
            child: MaxWidthWrapper(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildHeroProfile(),
                  const SizedBox(height: 16),
                  _buildQuranSettings(),
                  const SizedBox(height: 16),
                  _buildHadithSettings(),
                  const SizedBox(height: 16),
                  _buildPrayerTimesSettings(),
                  const SizedBox(height: 16),
                  _buildAppLanguage(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // HERO PROFILE
  // ═══════════════════════════════════════════════════
  Widget _buildHeroProfile() {
    return Obx(() {
      final user = userController.user.value;
      return Container(
        decoration: BoxDecoration(
          gradient: _DS.heroGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: user.profilePicture.isNotEmpty
                    ? Image.network(
                        user.profilePicture,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            PImages.userPlaceholder,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        PImages.userPlaceholder,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user.fullName.isNotEmpty ? user.fullName : 'Peace Player',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user.email.isNotEmpty ? user.email : 'Not logged in',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════
  // OTHER FEATURES
  // ═══════════════════════════════════════════════════
  Widget _buildPrayerTimesSettings() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _prayerExpanded = !_prayerExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: _DS.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text('PRAYER TIMES', style: _DS.label()),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _prayerExpanded ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_less, color: _DS.primary),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: _DS.outlineVariant.withValues(alpha: 0.2)),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _settingsSubSection(
              icon: Icons.cloud,
              title: 'Asar Time Calculation',
              child: Row(
                children: [
                  _prayerMadhabChip(
                    label: 'SHAFI',
                    madhab: 'standard',
                  ),
                  const SizedBox(width: 8),
                  _prayerMadhabChip(
                    label: 'HANAFI',
                    madhab: 'hanafi',
                  ),
                ],
              ),
            ),
            crossFadeState: _prayerExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _prayerMadhabChip({
    required String label,
    required String madhab,
  }) {
    final normalizedMadhab = _normalizePrayerMadhab(madhab);
    final selected = _selectedPrayerMadhab == normalizedMadhab;

    return Expanded(
      child: GestureDetector(
        onTap: () => _setPrayerMadhab(normalizedMadhab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _DS.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: selected
                ? Border.all(color: _DS.primary.withValues(alpha: 0.1))
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: _DS.body(
                16,
                color: selected ? _DS.primary : _DS.onSurfaceVariant,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setPrayerMadhab(String madhab) async {
    final normalizedMadhab = _normalizePrayerMadhab(madhab);
    setState(() => _selectedPrayerMadhab = normalizedMadhab);
    await _storage.saveData(
      PrayerTimesSettingsKeys.asrMadhab,
      normalizedMadhab,
    );

    if (Get.isRegistered<PrayerTimesController>()) {
      Get.find<PrayerTimesController>().applyDefaultMadhab();
    }
  }

  String _normalizePrayerMadhab(String? madhab) {
    final normalizedMadhab = madhab?.trim().toLowerCase();
    if (normalizedMadhab == 'hanafi') return 'hanafi';
    if (normalizedMadhab == 'shafi' ||
        normalizedMadhab == 'shafii' ||
        normalizedMadhab == 'standard') {
      return 'standard';
    }

    return PrayerTimesDefaults.asrMadhab;
  }

  Widget _buildAppLanguage() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text('OTHER FEATURES', style: _DS.label()),
          ),
          Text('Title language', style: _DS.label(color: _DS.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              _langChip(
                label: 'English',
                code: 'en',
                selectedCode: _overallTitleLanguageCode,
                onTap: () {
                  setState(() => _overallTitleLanguageCode = 'en');
                  languageController.setTitleLanguageCode('en');
                },
              ),
              const SizedBox(width: 8),
              _langChip(
                label: 'اردو',
                code: 'ur',
                selectedCode: _overallTitleLanguageCode,
                onTap: () {
                  setState(() => _overallTitleLanguageCode = 'ur');
                  languageController.setTitleLanguageCode('ur');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Text language', style: _DS.label(color: _DS.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              _langChip(
                label: 'English',
                code: 'en',
                selectedCode: _overallTextLanguageCode,
                onTap: () {
                  final hasReferenceOverride = _storage.readData<String>(
                          AppSettingsKeys.referenceAyahHadithLanguageCode) !=
                      null;
                  setState(() {
                    _overallTextLanguageCode = 'en';
                    if (!hasReferenceOverride) {
                      _referenceAyahHadithLanguageCode = 'en';
                    }
                  });
                  languageController.setTextLanguageCode(
                    'en',
                    updateReferenceIfUnset: !hasReferenceOverride,
                  );
                },
              ),
              const SizedBox(width: 8),
              _langChip(
                label: 'اردو',
                code: 'ur',
                selectedCode: _overallTextLanguageCode,
                onTap: () {
                  final hasReferenceOverride = _storage.readData<String>(
                          AppSettingsKeys.referenceAyahHadithLanguageCode) !=
                      null;
                  setState(() {
                    _overallTextLanguageCode = 'ur';
                    if (!hasReferenceOverride) {
                      _referenceAyahHadithLanguageCode = 'ur';
                    }
                  });
                  languageController.setTextLanguageCode(
                    'ur',
                    updateReferenceIfUnset: !hasReferenceOverride,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Reference ayah & hadith',
              style: _DS.label(color: _DS.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              _langChip(
                label: 'Arabic',
                code: 'ar',
                selectedCode: _referenceAyahHadithLanguageCode,
                onTap: () {
                  setState(() => _referenceAyahHadithLanguageCode = 'ar');
                  languageController.setReferenceLanguageCode('ar');
                },
              ),
              const SizedBox(width: 8),
              _langChip(
                label: 'English',
                code: 'en',
                selectedCode: _referenceAyahHadithLanguageCode,
                onTap: () {
                  setState(() => _referenceAyahHadithLanguageCode = 'en');
                  languageController.setReferenceLanguageCode('en');
                },
              ),
              const SizedBox(width: 8),
              _langChip(
                label: 'اردو',
                code: 'ur',
                selectedCode: _referenceAyahHadithLanguageCode,
                onTap: () {
                  setState(() => _referenceAyahHadithLanguageCode = 'ur');
                  languageController.setReferenceLanguageCode('ur');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _langChip({
    required String label,
    required String code,
    required String selectedCode,
    required VoidCallback onTap,
  }) {
    final selected = selectedCode == code;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _DS.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: selected
                ? Border.all(color: _DS.primary.withValues(alpha: 0.1))
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: _DS.body(
                16,
                color: selected ? _DS.primary : _DS.onSurfaceVariant,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // QURAN SETTINGS
  // ═══════════════════════════════════════════════════
  Widget _buildQuranSettings() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _quranExpanded = !_quranExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  Text('QURAN SETTINGS', style: _DS.label()),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _quranExpanded ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_less, color: _DS.primary),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: _DS.outlineVariant.withValues(alpha: 0.2)),

          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                // Translation
                _settingsSubSection(
                  icon: Icons.translate,
                  title: 'Translation',
                  child: _settingsSelectionTile(
                    label: 'Default translation',
                    value: _translationSelectionValue(),
                    onTap: _showTranslationPicker,
                  ),
                ),

                Divider(
                    height: 1,
                    color: _DS.outlineVariant.withValues(alpha: 0.1)),

                // Reciter
                _settingsSubSection(
                  icon: Icons.record_voice_over,
                  title: "Reciter",
                  child: _settingsSelectionTile(
                    label: 'Default reciter',
                    value: _reciterSelectionValue(),
                    onTap: _showReciterPicker,
                  ),
                ),

                Divider(
                    height: 1,
                    color: _DS.outlineVariant.withValues(alpha: 0.1)),

                // Tafseer
                _settingsSubSection(
                  icon: Icons.menu_book,
                  title: 'Tafseer',
                  child: _settingsSelectionTile(
                    label: 'Default tafseer',
                    value: _tafseerSelectionValue(),
                    onTap: _showTafseerPicker,
                  ),
                ),
              ],
            ),
            crossFadeState: _quranExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // HADITH SETTINGS
  // ═══════════════════════════════════════════════════
  Widget _buildHadithSettings() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _hadithExpanded = !_hadithExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories,
                      color: _DS.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text('HADITH TRANSLATION', style: _DS.label()),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _hadithExpanded ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_less, color: _DS.primary),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: _DS.outlineVariant.withValues(alpha: 0.2)),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                // Default Language
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _settingsSelectionTile(
                    label: 'Default language',
                    value: _selectedHadithLang,
                    onTap: _showHadithLanguagePicker,
                  ),
                ),
              ],
            ),
            crossFadeState: _hadithExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  String _translationSelectionValue() {
    return '$_selectedTranslationLanguage - $_selectedTranslator';
  }

  String _reciterSelectionValue() {
    return '$_selectedReciterLanguage - $_selectedReciter';
  }

  String _tafseerSelectionValue() {
    if (_selectedTafseerWriter == null || _selectedTafseerWriter!.isEmpty) {
      return 'None';
    }
    final language = _selectedTafseerLanguage;
    if (language == null || language.isEmpty) {
      return _selectedTafseerWriter!;
    }
    return '$language - ${_selectedTafseerWriter!}';
  }

  void _showTranslationPicker() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuranOptionPicker<Translation>(
        title: 'Select Translation',
        items: quranHadithController.translations,
        isLoading: quranHadithController.isLoading,
        getLanguage: (item) => item.language,
        getOptions: (item) => item.translators,
        getTotalCount: (item) => item.totalTranslators,
        optionLabel: 'translators',
        selectedOption: _selectedTranslator,
        onSelect: (language, translator) async {
          setState(() {
            _selectedTranslationLanguage = language;
            _selectedTranslator = translator;
          });
          await _storage.saveData(
              QuranHadithSettingsKeys.translationLanguage, language);
          await _storage.saveData(
              QuranHadithSettingsKeys.translationTranslator, translator);
        },
      ),
    );
  }

  void _showTafseerPicker() {
    if (!mounted) return;
    final tafseerOptions = <Tafseer>[
      Tafseer(language: 'None', tafseers: ['None'], totalTafseers: 1),
      ...quranHadithController.tafseers,
    ].obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuranOptionPicker<Tafseer>(
        title: 'Select Tafseer',
        items: tafseerOptions,
        isLoading: quranHadithController.isLoading,
        getLanguage: (item) => item.language,
        getOptions: (item) => item.tafseers,
        getTotalCount: (item) => item.totalTafseers,
        optionLabel: 'tafseers',
        selectedOption: _selectedTafseerWriter ?? 'None',
        onSelect: (language, tafseer) async {
          if (tafseer == 'None') {
            setState(() {
              _selectedTafseerLanguage = null;
              _selectedTafseerWriter = null;
            });
            await _storage.removeData(QuranHadithSettingsKeys.tafseerLanguage);
            await _storage.removeData(QuranHadithSettingsKeys.tafseerWriter);
            return;
          }

          setState(() {
            _selectedTafseerLanguage = language;
            _selectedTafseerWriter = tafseer;
          });
          await _storage.saveData(
              QuranHadithSettingsKeys.tafseerLanguage, language);
          await _storage.saveData(
              QuranHadithSettingsKeys.tafseerWriter, tafseer);
        },
      ),
    );
  }

  void _showReciterPicker() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuranOptionPicker<AudioUrl>(
        title: 'Select Qari Audio',
        items: quranHadithController.audioUrls,
        isLoading: quranHadithController.isLoading,
        getLanguage: (item) => item.language,
        getOptions: (item) => item.reciters,
        getTotalCount: (item) => item.totalReciters,
        optionLabel: 'reciters',
        selectedOption: _selectedReciter,
        onSelect: (language, reciter) async {
          setState(() {
            _selectedReciterLanguage = language;
            _selectedReciter = reciter;
          });
          await _storage.saveData(
              QuranHadithSettingsKeys.reciterLanguage, language);
          await _storage.saveData(QuranHadithSettingsKeys.reciterName, reciter);
        },
      ),
    );
  }

  void _showHadithLanguagePicker() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HadithOptionPicker(
        title: 'Select Language',
        languages: quranHadithController
                .hadithTranslationLanguages.value?.languages.obs ??
            <String>[].obs,
        isLoading: quranHadithController.isHadithTranslationLanguagesLoading,
        selectedLanguage: _selectedHadithLang,
        onSelect: (language) async {
          setState(() {
            _selectedHadithLang = language;
          });
          await _storage.saveData(
              QuranHadithSettingsKeys.hadithLanguage, language);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // REUSABLE BUILDERS
  // ═══════════════════════════════════════════════════

  /// White card wrapper
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DS.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DS.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [_DS.softShadow],
      ),
      child: child,
    );
  }

  /// Sub-section inside a settings card
  Widget _settingsSubSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _DS.secondary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: _DS.body(16)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _settingsSelectionTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _DS.surfaceLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _DS.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: _DS.label(color: _DS.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _DS.body(15, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _DS.outline),
            ],
          ),
        ),
      ),
    );
  }
}
