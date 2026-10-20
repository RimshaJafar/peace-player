import 'package:ecommerce_app/features/quran_hadith/controllers/quran_hadith_controller.dart';
import 'package:ecommerce_app/features/quran_hadith/screens/surah_ayah_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/surah_list_tile.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final QuranHadithController controller = Get.put(QuranHadithController());
  late String externalSurahTileLeftName;
  String externalSurahTileRightName =
      QuranHadithDefaults.externalSurahTileRightName;
  String innerSurahAyahsBismillahTileRightName =
      QuranHadithDefaults.innerSurahAyahsBismillahTileRightName;

  @override
  void initState() {
    super.initState();
    externalSurahTileLeftName = QuranHadithDefaults.externalSurahTileLeftName;
    controller.fetchSurahs(); // Fetch data before widget build
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.surahError.value.isNotEmpty &&
            controller.surahs.isEmpty) {
          return _RetryState(
            message: controller.surahError.value,
            onRetry: () => controller.fetchSurahs(),
          );
        }
        if (controller.surahs.isEmpty) {
          return const Center(child: Text('No Surahs found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 24.0),
          itemCount: controller.surahs.length,
          itemBuilder: (context, index) {
            final surah = controller.surahs[index];

            return SurahListTile(
              surahNumber: surah.surahNumber,
              surahNameEnglish:
                  surah.surahName[externalSurahTileLeftName] ?? '',
              surahNameArabic:
                  surah.surahName[externalSurahTileRightName] ?? '',
              surahMeaning: surah.surahName['meaning'] ?? '',
              startAyahNumber: surah.startAyahNumber,
              endAyahNumber: surah.endAyahNumber,
              onTap: () {
                Get.to(() => SurahAyah(
                      surahNumber: surah.surahNumber,
                      surahName: surah.surahName[
                              innerSurahAyahsBismillahTileRightName] ??
                          '',
                    ));
              },
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
