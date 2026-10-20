import 'package:audioplayers/audioplayers.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar_action_button.dart';
import 'package:ecommerce_app/common/widgets/bottom_sheets/quran_option_picker.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/bismillah_surah_tile.dart';
import 'package:ecommerce_app/features/quran_hadith/controllers/quran_hadith_controller.dart';
import 'package:ecommerce_app/features/quran_hadith/models/audio_url_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/surah_audio_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/surah_tafseer_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/surah_translation_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/tafseer_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/translation_model.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:ecommerce_app/utils/local_storage/storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/common/widgets/cards/ayah_card_item.dart';

class SurahAyah extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahAyah({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahAyah> createState() => _SurahAyahState();
}

class _SurahAyahState extends State<SurahAyah> {
  final QuranHadithController controller = Get.find<QuranHadithController>();
  final PLocalStorage _storage = PLocalStorage();
  final String translationLanguage =
      QuranHadithDefaults.surahsAyahsTilesDefaultTranslationLanguage;

  late final AudioPlayer _audioPlayer;
  late String selectedAudioLanguage;
  late String selectedReciter;
  int? playingAyahNumber;

  // Selected translation settings
  late String selectedLanguage;
  late String selectedTranslator;

  // Selected tafseer settings
  String? selectedTafseerLanguage;
  String? selectedTafseerWriter;

  @override
  void initState() {
    super.initState();
    _loadDefaultsFromStorage();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => playingAyahNumber = null);
      }
    });
    // Clear any previous tafseer data to default to "None"
    controller.surahTafseers.clear();
    // defer fetch to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchSurahAyahs(widget.surahNumber);
      controller.fetchTranslations();
      controller.fetchTafseers();
      await controller.fetchAudioUrls();
      await controller.fetchSurahAudioUrls(
          widget.surahNumber, selectedAudioLanguage, selectedReciter);
      // Fetch default translation
      await controller.fetchSurahTranslations(
          widget.surahNumber, selectedLanguage, selectedTranslator);
      if (selectedTafseerLanguage != null && selectedTafseerWriter != null) {
        await controller.fetchSurahTafseers(widget.surahNumber,
            selectedTafseerLanguage!, selectedTafseerWriter!);
      }
    });
  }

  void _loadDefaultsFromStorage() {
    selectedLanguage = _storage
            .readData<String>(QuranHadithSettingsKeys.translationLanguage) ??
        QuranHadithDefaults.surahsAyahsTilesDefaultTranslationLanguage;
    selectedTranslator = _storage
            .readData<String>(QuranHadithSettingsKeys.translationTranslator) ??
        QuranHadithDefaults
            .surahsAyahsTilesDefaultTranslationLanguageTranslator;
    selectedAudioLanguage =
        _storage.readData<String>(QuranHadithSettingsKeys.reciterLanguage) ??
            QuranHadithDefaults.surahsAyahsTilesDefaultRecitationLanguage;
    selectedReciter = _storage
            .readData<String>(QuranHadithSettingsKeys.reciterName) ??
        QuranHadithDefaults.surahsAyahsTilesDefaultRecitationLanguageReciter;
    selectedTafseerLanguage =
        _storage.readData<String>(QuranHadithSettingsKeys.tafseerLanguage);
    selectedTafseerWriter =
        _storage.readData<String>(QuranHadithSettingsKeys.tafseerWriter);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchSurahAudios() async {
    await controller.fetchSurahAudioUrls(
        widget.surahNumber, selectedAudioLanguage, selectedReciter);
  }

  Future<void> _playSurahAyahAudio(int ayahNumber) async {
    if (!mounted) return;

    if (controller.surahAudios.isEmpty) {
      await _fetchSurahAudios();
    }

    SurahAudio? audio;
    for (final item in controller.surahAudios) {
      if (item.ayahNumber == ayahNumber) {
        audio = item;
        break;
      }
    }

    if (audio == null || audio.audioUrl.isEmpty) {
      _showSnack('Audio not available for this ayah.');
      return;
    }

    setState(() => playingAyahNumber = ayahNumber);
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        UrlSource(audio.audioUrl, mimeType: 'audio/mpeg'),
      );
    } catch (e) {
      _showSnack('Unable to play audio. Please try again.');
      setState(() => playingAyahNumber = null);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    PLoaders.warningSnackBar(
      title: 'Notice',
      message: message,
      context: context,
    );
  }

  void _showTranslationPicker() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuranOptionPicker<Translation>(
        title: 'Select Translation',
        items: controller.translations,
        isLoading: controller.isLoading,
        getLanguage: (item) => item.language,
        getOptions: (item) => item.translators,
        getTotalCount: (item) => item.totalTranslators,
        optionLabel: 'translators',
        selectedOption: selectedTranslator,
        onSelect: (language, translator) {
          setState(() {
            selectedLanguage = language;
            selectedTranslator = translator;
          });
          controller.fetchSurahTranslations(
              widget.surahNumber, language, translator);
        },
      ),
    );
  }

  void _showTafseerPicker() {
    if (!mounted) return;

    // Create a list with "None" as the first option
    final tafseerOptions = <Tafseer>[
      Tafseer(
          language: 'None',
          tafseers: ['None'],
          totalTafseers: 1), // Dummy "None" option
      ...controller.tafseers, // Existing Tafseers
    ].obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuranOptionPicker<Tafseer>(
        title: 'Select Tafseer',
        items: tafseerOptions, // Use the modified list with "None" first
        isLoading: controller.isLoading,
        getLanguage: (item) => item.language,
        getOptions: (item) => item.tafseers,
        getTotalCount: (item) => item.totalTafseers,
        optionLabel: 'tafseers',
        selectedOption: selectedTafseerWriter ??
            'None', // Default to 'None' if no writer is selected
        onSelect: (language, tafseer) {
          if (tafseer == 'None') {
            // Clear selection to hide Tafseer
            setState(() {
              selectedTafseerLanguage = null;
              selectedTafseerWriter = null;
            });
            controller.surahTafseers
                .clear(); // Clear fetched Tafseers to hide them immediately
          } else {
            // Normal selection
            setState(() {
              selectedTafseerLanguage = language;
              selectedTafseerWriter = tafseer;
            });
            controller.fetchSurahTafseers(
                widget.surahNumber, language, tafseer);
          }
        },
      ),
    );
  }

  void _showAudioUrlPicker() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuranOptionPicker<AudioUrl>(
        title: 'Select Qari Audio',
        items: controller.audioUrls,
        isLoading: controller.isLoading,
        getLanguage: (item) => item.language,
        getOptions: (item) => item.reciters,
        getTotalCount: (item) => item.totalReciters,
        optionLabel: 'reciters',
        selectedOption: selectedReciter,
        onSelect: (language, reciter) {
          setState(() {
            selectedAudioLanguage = language;
            selectedReciter = reciter;
          });
          _fetchSurahAudios();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PAppBar(
        gradient: PColors.linearGradient,
        backgroundTransparent: true,
        leadingWidth: MediaQuery.of(context).size.width,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            const SizedBox(width: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  AppBarActionButton(
                    text: 'Translation',
                    onTap: _showTranslationPicker,
                  ),
                  AppBarActionButton(
                    text: 'Tafseer',
                    onTap: _showTafseerPicker,
                  ),
                  AppBarActionButton(
                    text: 'Reciter',
                    onTap: _showAudioUrlPicker,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isSurahAyahsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.ayahError.value.isNotEmpty &&
            controller.surahAyahs.isEmpty) {
          return _RetryState(
            message: controller.ayahError.value,
            onRetry: () => controller.fetchSurahAyahs(widget.surahNumber),
          );
        }

        if (controller.surahAyahs.isEmpty) {
          return const Center(child: Text("No Ayahs available"));
        }

        final ayahList = controller.surahAyahs;
        final translations = controller.surahTranslations;
        final isTranslationsLoading =
            controller.isSurahTranslationsLoading.value;
        final tafseers = controller.surahTafseers;
        final isTafseersLoading = controller.isSurahTafseersLoading.value;
        final showBismillah = widget.surahNumber != 9;

        // Total items: ayahs + optional bismillah + optional translation loader + optional tafseer loader
        final itemCount = ayahList.length +
            (showBismillah ? 1 : 0) +
            (isTranslationsLoading ? 1 : 0) +
            (isTafseersLoading ? 1 : 0);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            int currentIndex = index;

            // Bismillah tile at the top when applicable
            if (showBismillah) {
              if (currentIndex == 0) {
                final firstAyah = ayahList.first;
                final surahName = firstAyah.surahName[QuranHadithDefaults
                        .innerSurahAyahsBismillahTileRightName] ??
                    '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: BismillahSurahTile(
                    surahName: surahName,
                    totalAyahs: ayahList.length,
                  ),
                );
              }
              currentIndex -= 1;
            }

            // Show translation loader after Bismillah (if loading)
            if (isTranslationsLoading) {
              if (currentIndex == 0) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Loading translations...'),
                      ],
                    ),
                  ),
                );
              }
              currentIndex -= 1;
            }

            // Show tafseer loader (if loading)
            if (isTafseersLoading) {
              if (currentIndex == 0) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Loading tafseers...'),
                      ],
                    ),
                  ),
                );
              }
              currentIndex -= 1;
            }

            // currentIndex now maps to ayahList
            if (currentIndex < 0 || currentIndex >= ayahList.length) {
              return const SizedBox.shrink();
            }

            final ayah = ayahList[currentIndex];

            // Match translation by ayah number
            final matchingTranslation = translations.firstWhere(
              (translation) => translation.ayahNumber == ayah.ayahNumber,
              orElse: () => SurahTranslation(
                ayahNumber: 0,
                surahNumber: 0,
                language: '',
                translator: '',
                translationText: '',
              ),
            );

            // Match tafseer by ayah number
            final matchingTafseer = tafseers.firstWhere(
              (tafseer) => tafseer.ayahNumber == ayah.ayahNumber,
              orElse: () => SurahTafseer(
                ayahNumber: 0,
                surahNumber: 0,
                language: '',
                writer: '',
                tafseerText: '',
              ),
            );

            return AyahCardItem(
              surahNumber: widget.surahNumber,
              ayahNumberInSurah: ayah.ayahNumberInSurah,
              arabicText: ayah.textArabic,
              translationText: matchingTranslation.translationText,
              tafseerText: matchingTafseer.tafseerText,
              currentLang: selectedLanguage,
              tafseerLang: selectedTafseerLanguage ?? selectedLanguage,
              onPlayAudio: () => _playSurahAyahAudio(ayah.ayahNumber),
              isPlaying: playingAyahNumber == ayah.ayahNumber,
            );
          },
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

// class SurahAyah extends StatefulWidget {
//   final int surahNumber;
//   final String surahName;

//   const SurahAyah({
//     super.key,
//     required this.surahNumber,
//     required this.surahName,
//   });

//   @override
//   State<SurahAyah> createState() => SurahAyahState();
// }

// class SurahAyahState extends State<SurahAyah> {
//   final QuranHadithController controller = Get.find<QuranHadithController>();
//   final String currentLang = 'ur';

//   @override
//   void initState() {
//     super.initState();
//     controller.fetchSurahAyahs(widget.surahNumber);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.surahName,
//           style: const TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color(0xFF60BEA8),
//                 Color(0xFF329070),
//                 Color(0xFF1C5D4E),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
//           itemCount: widget.surahNumber != 9
//               ? controller.surahAyahs.length + 1
//               : controller.surahAyahs.length,
//           itemBuilder: (context, index) {
//             // Bismillah (except Surah 9)
//             if (index == 0 && widget.surahNumber != 9) {
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 24),
//                 child: BismillahSurahTile(
//                   surahName: controller.surahAyahs.isNotEmpty
//                       ? controller.surahAyahs.first.surahName[currentLang] ??
//                           controller.surahAyahs.first.surahName['en'] ??
//                           ''
//                       : '',
//                   totalAyahs: controller.surahAyahs.length,
//                 ),
