import 'package:ecommerce_app/features/quran_hadith/controllers/quran_hadith_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar_action_button.dart';
import 'package:ecommerce_app/common/widgets/bottom_sheets/hadith_option_picker.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/common/widgets/cards/hadith_card_item.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:ecommerce_app/utils/local_storage/storage_utility.dart';

class HadithBooksChaptersHadithsScreen extends StatefulWidget {
  final int bookId;
  final int chapterId;
  const HadithBooksChaptersHadithsScreen({
    super.key,
    required this.bookId,
    required this.chapterId,
  });

  @override
  State<HadithBooksChaptersHadithsScreen> createState() =>
      HadithBooksChaptersHadithsScreenState();
}

class HadithBooksChaptersHadithsScreenState
    extends State<HadithBooksChaptersHadithsScreen> {
  final QuranHadithController controller = Get.put(QuranHadithController());
  final PLocalStorage _storage = PLocalStorage();
  late String selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadDefaultsFromStorage();
    controller.fetchHadithBooksChaptersHadiths(widget.bookId, widget.chapterId);
    controller.fetchHadithTranslationLanguages();
    controller.fetchHadithTranslations(
      widget.bookId,
      widget.chapterId,
      selectedLanguage,
    );
  }

  void _loadDefaultsFromStorage() {
    selectedLanguage =
        _storage.readData<String>(QuranHadithSettingsKeys.hadithLanguage) ??
            QuranHadithDefaults
                .hadithBooksChaptersHadithsDefaultTranslationLanguage;
  }

  void _showLanguagePicker() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HadithOptionPicker(
        title: 'Select Language',
        languages: controller.hadithTranslationLanguages.value?.languages.obs ??
            <String>[].obs,
        isLoading: controller.isHadithTranslationLanguagesLoading,
        selectedLanguage: selectedLanguage,
        onSelect: (language) {
          setState(() {
            selectedLanguage = language;
          });
          controller.fetchHadithTranslations(
            widget.bookId,
            widget.chapterId,
            language,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PAppBar(
        gradient: PColors.linearGradient,
        centerTitle: false,
        title: const SizedBox.shrink(),
        leadingWidth: 170,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: AppBarActionButton(
                text: 'LANGUAGE',
                onTap: _showLanguagePicker,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isHadithsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hadithsError.value.isNotEmpty &&
            controller.hadithBooksChaptersHadiths.isEmpty) {
          return _RetryState(
            message: controller.hadithsError.value,
            onRetry: () => controller.fetchHadithBooksChaptersHadiths(
              widget.bookId,
              widget.chapterId,
            ),
          );
        }
        if (controller.hadithBooksChaptersHadiths.isEmpty) {
          return const Center(child: Text('No Hadiths found.'));
        }

        final translations = controller.hadithTranslations;
        final isTranslationsLoading =
            controller.isHadithTranslationsLoading.value;

        return Column(
          children: [
            if (isTranslationsLoading)
              const LinearProgressIndicator(minHeight: 3),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: controller.hadithBooksChaptersHadiths.length,
                itemBuilder: (context, index) {
                  final hadith = controller.hadithBooksChaptersHadiths[index];

                  // Prefer fetched translations; fall back to embedded map
                  String translation = '';
                  for (final item in translations) {
                    if (item.hadithNumber == hadith.hadithNumber) {
                      translation = item.translation;
                      break;
                    }
                  }

                  if (translation.isEmpty) {
                    final langTranslation =
                        hadith.translations[selectedLanguage];
                    if (langTranslation != null) {
                      translation = langTranslation.toString();
                    } else {
                      final enTranslation = hadith.translations['en'];
                      if (enTranslation != null) {
                        translation = enTranslation.toString();
                      }
                    }
                  }

                  // Extract narrator name in selected language
                  String narrator = '';
                  final langNarrator = hadith.narratorName[selectedLanguage];
                  if (langNarrator != null) {
                    narrator = langNarrator.toString();
                  } else {
                    final enNarrator = hadith.narratorName['en'];
                    if (enNarrator != null) {
                      narrator = enNarrator.toString();
                    }
                  }

                  return HadithCardItem(
                    arabicText: hadith.textArabic,
                    narratorText: narrator,
                    translationText: translation,
                    translationLang: selectedLanguage,
                    bookName: hadith.bookName[selectedLanguage] ??
                        hadith.bookName['en'] ??
                        '',
                    hadithNumber: hadith.hadithNumber,
                    status: hadith.status,
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _RetryState extends StatelessWidget {
  const _RetryState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
