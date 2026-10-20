import 'package:ecommerce_app/features/quran_hadith/controllers/quran_hadith_controller.dart';
import 'package:ecommerce_app/features/quran_hadith/screens/hadith_books_chapters_hadiths_screen.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/common/widgets/cards/hadith_chapter_card.dart';

class HadithBooksChapterScreen extends StatefulWidget {
  final int bookId;
  const HadithBooksChapterScreen({super.key, required this.bookId});

  @override
  State<HadithBooksChapterScreen> createState() =>
      _HadithBooksChapterScreenState();
}

class _HadithBooksChapterScreenState extends State<HadithBooksChapterScreen> {
  final QuranHadithController controller = Get.find<QuranHadithController>();
  late String externalHadithBookChapterTileLeftName;
  String externalHadithBookChapterTileRightName =
      QuranHadithDefaults.externalHadithBookChapterTileRightName;

  @override
  void initState() {
    super.initState();
    externalHadithBookChapterTileLeftName =
        QuranHadithDefaults.externalHadithBookChapterTileLeftName;
    controller.hadithBooksChapters.clear(); // Clear previous chapters
    controller.fetchHadithBooksChapters(
        widget.bookId); // Fetch chapters for selected book
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          "Chapters",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient, showBackArrow: true,
        // backgroundTransparent: true,
      ),
      body: Obx(() {
        if (controller.isChaptersLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hadithChaptersError.value.isNotEmpty &&
            controller.hadithBooksChapters.isEmpty) {
          return _RetryState(
            message: controller.hadithChaptersError.value,
            onRetry: () => controller.fetchHadithBooksChapters(widget.bookId),
          );
        }
        if (controller.hadithBooksChapters.isEmpty) {
          return const Center(child: Text('No chapters found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 12.0),
          itemCount: controller.hadithBooksChapters.length,
          itemBuilder: (context, index) {
            final chapter = controller.hadithBooksChapters[index];

            return HadithChapterCard(
              chapterId: chapter.chapterId,
              chapterLeftName:
                  chapter.chapterName[externalHadithBookChapterTileLeftName] ??
                      '',
              chapterRightName:
                  chapter.chapterName[externalHadithBookChapterTileRightName] ??
                      '',
              startHadithNumber: chapter.startHadithNumber,
              endHadithNumber: chapter.endHadithNumber,
              onTap: () {
                Get.to(() => HadithBooksChaptersHadithsScreen(
                      bookId: widget.bookId,
                      chapterId: chapter.chapterId,
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
