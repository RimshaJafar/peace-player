import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/features/quran_hadith/screens/hadith_books_chapter_screen.dart';
import 'package:ecommerce_app/common/widgets/cards/gradient_leaf_decoration.dart';

/// Reusable hadith book card widget with gradient leaf decorations.
class HadithBookCard extends StatelessWidget {
  const HadithBookCard({
    super.key,
    required this.upperBookName,
    required this.lowerBookName,
    required this.bookId,
  });

  final String upperBookName;
  final String lowerBookName;
  final int bookId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => HadithBooksChapterScreen(bookId: bookId));
      },
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 2,
        color: const Color(0xFFE6F0EF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Top-left leaf
            GradientLeafDecoration(
              angle: 0,
              top: 6,
              left: 6,
            ),

            // Top-right leaf (90 degrees)
            GradientLeafDecoration(
              angle: 1.5708,
              top: 6,
              right: 6,
            ),

            // Bottom-left leaf (-90 degrees)
            GradientLeafDecoration(
              angle: -1.5708,
              bottom: 6,
              left: 6,
            ),

            // Bottom-right leaf (180 degrees)
            GradientLeafDecoration(
              angle: 3.1416,
              bottom: 6,
              right: 6,
            ),

            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      upperBookName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lateef(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF329070),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      lowerBookName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
