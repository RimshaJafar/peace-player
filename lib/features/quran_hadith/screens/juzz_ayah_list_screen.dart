import 'package:audioplayers/audioplayers.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar_action_button.dart';
import 'package:ecommerce_app/common/widgets/bottom_sheets/quran_option_picker.dart';
import 'package:ecommerce_app/features/quran_hadith/controllers/quran_hadith_controller.dart';
import 'package:ecommerce_app/features/quran_hadith/models/audio_url_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/juz_audio_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/juz_tafseer_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/juz_translation_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/tafseer_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/translation_model.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:ecommerce_app/utils/local_storage/storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/bismillah_juzz_tile.dart';
import 'package:ecommerce_app/common/widgets/cards/juzz_ayah_card_item.dart';

class JuzzAyah extends StatefulWidget {
  final int juzNumber;
  final String juzName;

  const JuzzAyah(
      {super.key,
      required this.juzNumber,
      required this.juzName}); // <-- added semicolon here

  @override
  State<JuzzAyah> createState() => _JuzzAyahState();
}

class _JuzzAyahState extends State<JuzzAyah> {
  final QuranHadithController controller = Get.find<QuranHadithController>();
  final PLocalStorage _storage = PLocalStorage();
  final String translationLanguage =
      QuranHadithDefaults.juzsAyahsTilesDefaultTranslationLanguage;

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
    controller.juzTafseers.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchJuzAyahs(widget.juzNumber);
      controller.fetchTranslations();
      controller.fetchTafseers();
      await controller.fetchAudioUrls();
      await _fetchJuzAudios();
      // Fetch default translation
      await controller.fetchJuzTranslations(
          widget.juzNumber, selectedLanguage, selectedTranslator);
      if (selectedTafseerLanguage != null && selectedTafseerWriter != null) {
        await controller.fetchJuzTafseers(
            widget.juzNumber, selectedTafseerLanguage!, selectedTafseerWriter!);
      }
    });
  }

  void _loadDefaultsFromStorage() {
    selectedLanguage = _storage
            .readData<String>(QuranHadithSettingsKeys.translationLanguage) ??
        QuranHadithDefaults.juzsAyahsTilesDefaultTranslationLanguage;
    selectedTranslator = _storage
            .readData<String>(QuranHadithSettingsKeys.translationTranslator) ??
        QuranHadithDefaults.juzsAyahsTilesDefaultTranslationLanguageTranslator;
    selectedAudioLanguage =
        _storage.readData<String>(QuranHadithSettingsKeys.reciterLanguage) ??
            QuranHadithDefaults.juzsAyahsTilesDefaultRecitationLanguage;
    selectedReciter =
        _storage.readData<String>(QuranHadithSettingsKeys.reciterName) ??
            QuranHadithDefaults.juzsAyahsTilesDefaultRecitationLanguageReciter;
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

  Future<void> _fetchJuzAudios() async {
    await controller.fetchJuzAudioUrls(
        widget.juzNumber, selectedAudioLanguage, selectedReciter);
  }

  Future<void> _playJuzAyahAudio(int ayahNumber) async {
    if (!mounted) return;

    if (controller.juzAudios.isEmpty) {
      await _fetchJuzAudios();
    }

    JuzAudio? audio;
    for (final item in controller.juzAudios) {
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
          controller.fetchJuzTranslations(
              widget.juzNumber, language, translator);
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
            controller.juzTafseers
                .clear(); // Clear fetched Tafseers to hide them immediately
          } else {
            // Normal selection
            setState(() {
              selectedTafseerLanguage = language;
              selectedTafseerWriter = tafseer;
            });
            controller.fetchJuzTafseers(widget.juzNumber, language, tafseer);
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
          _fetchJuzAudios();
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
        if (controller.isJuzAyahsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.ayahError.value.isNotEmpty &&
            controller.juzzAyahs.isEmpty) {
          return _RetryState(
            message: controller.ayahError.value,
            onRetry: () => controller.fetchJuzAyahs(widget.juzNumber),
          );
        }

        if (controller.juzzAyahs.isEmpty) {
          return const Center(child: Text("No Ayahs available"));
        }

        // Access juzTranslations to make it observable
        final translations = controller.juzTranslations;
        final isTranslationsLoading = controller.isJuzTranslationsLoading.value;

        // Access juzTafseers to make it observable
        final tafseers = controller.juzTafseers;
        final isTafseersLoading = controller.isJuzTafseersLoading.value;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          itemCount: controller.juzzAyahs.length +
              (isTranslationsLoading ? 2 : 1) +
              (isTafseersLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: BismillahJuzzTile(
                  juzName: widget.juzName,
                  totalAyahs: controller.juzzAyahs.length,
                ),
              );
            }

            // Show loading indicator for translations
            if (index == 1 && isTranslationsLoading) {
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

            // Show loading indicator for tafseers
            if (isTranslationsLoading && index == 2 && isTafseersLoading) {
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
            } else if (!isTranslationsLoading &&
                index == 1 &&
                isTafseersLoading) {
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

            // Calculate ayah index accounting for Bismillah and loaders
            int ayahIndex = index - 1; // Subtract Bismillah
            if (isTranslationsLoading) {
              ayahIndex -= 1; // Subtract translation loader
            }
            if (isTafseersLoading) {
              ayahIndex -= 1; // Subtract tafseer loader
            }

            if (ayahIndex < 0 || ayahIndex >= controller.juzzAyahs.length) {
              return const SizedBox.shrink();
            }

            final ayah = controller.juzzAyahs[ayahIndex];

            // Find matching translation by ayah number
            final matchingTranslation = translations.firstWhere(
              (translation) => translation.ayahNumber == ayah.ayahNumber,
              orElse: () => JuzTranslation(
                ayahNumber: 0,
                juzNumber: 0,
                language: '',
                translator: '',
                translationText: '',
              ),
            );

            // Find matching tafseer by ayah number
            final matchingTafseer = tafseers.firstWhere(
              (tafseer) => tafseer.ayahNumber == ayah.ayahNumber,
              orElse: () => JuzTafseer(
                ayahNumber: 0,
                juzNumber: 0,
                language: '',
                writer: '',
                tafseerText: '',
              ),
            );

            return JuzzAyahCardItem(
              juzNumber: widget.juzNumber,
              itemIndex: ayahIndex + 1,
              arabicText: ayah.arabicText,
              translationText: matchingTranslation.translationText,
              tafseerText: matchingTafseer.tafseerText,
              currentLang: selectedLanguage,
              tafseerLang: selectedTafseerLanguage ?? selectedLanguage,
              onPlayAudio: () => _playJuzAyahAudio(ayah.ayahNumber),
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
//               );
//             }

//             final ayahIndex = widget.surahNumber == 9 ? index : index - 1;

//             final ayah = controller.surahAyahs[ayahIndex];

//             /// 🔹 Translation extraction (SCREEN RESPONSIBILITY)
//             final translation = ayah.translations[currentLang]?['default'] ??
//                 ayah.translations['en']?['default'] ??
//                 '';

//             return Container(
//               margin: const EdgeInsets.only(bottom: 24),
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE6F0EF),
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withAlpha((255 * 0.14).toInt()),
//                     offset: const Offset(0, 1),
//                     blurRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   /// 🔹 Ayah Number Badge
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 14, vertical: 6),
//                         margin: const EdgeInsets.only(bottom: 8),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [
//                               Color(0xFF60BEA8),
//                               Color(0xFF329070),
//                               Color(0xFF1C5D4E),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           "${widget.surahNumber}:${ayah.ayahNumberInSurah}",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 8),

//                   /// 🔹 Arabic Text
//                   Text(
//                     ayah.textArabic,
//                     textDirection: TextDirection.rtl,
//                     textAlign: TextAlign.right,
//                     style: GoogleFonts.amiri(
//                       fontSize: 22,
//                       height: 2.1,
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   /// 🔹 Translation (Dynamic)
//                   if (translation.isNotEmpty)
//                     Text(
//                       translation,
//                       textDirection: currentLang == 'ur'
//                           ? TextDirection.rtl
//                           : TextDirection.ltr,
//                       textAlign: currentLang == 'ur'
//                           ? TextAlign.right
//                           : TextAlign.left,
//                       style: GoogleFonts.lateef(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w300,
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }
