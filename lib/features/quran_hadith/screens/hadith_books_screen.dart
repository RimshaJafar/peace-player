import 'package:ecommerce_app/features/quran_hadith/controllers/quran_hadith_controller.dart';
import 'package:ecommerce_app/utils/constants/qh_defaults.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/cards/hadith_book_card.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';

class HadithBooksScreen extends StatefulWidget {
  const HadithBooksScreen({super.key});

  @override
  State<HadithBooksScreen> createState() => HadithBooksScreenState();
}

class HadithBooksScreenState extends State<HadithBooksScreen> {
  final QuranHadithController controller = Get.put(QuranHadithController());
  late String externalHadithBookTileUpperName;
  String externalHadithBookTileLowerName =
      QuranHadithDefaults.externalHadithBookTileLowerName;

  @override
  void initState() {
    super.initState();
    externalHadithBookTileUpperName =
        QuranHadithDefaults.externalHadithBookTileUpperName;
    controller.fetchHadithBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isBooksLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hadithBooksError.value.isNotEmpty &&
            controller.hadithBooks.isEmpty) {
          return _RetryState(
            message: controller.hadithBooksError.value,
            onRetry: () => controller.fetchHadithBooks(),
          );
        }
        if (controller.hadithBooks.isEmpty) {
          return const Center(child: Text('No Hadith books found.'));
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
          child: GridView.builder(
            itemCount: controller.hadithBooks.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: PSizes.adaptiveGridCount(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              // Decrease aspect ratio (width/height) to increase tile height
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final hadithBook = controller.hadithBooks[index];
              return HadithBookCard(
                upperBookName:
                    hadithBook.bookName[externalHadithBookTileUpperName] ?? '',
                lowerBookName:
                    hadithBook.bookName[externalHadithBookTileLowerName] ?? '',
                bookId: hadithBook.bookId,
              );
            },
          ),
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
