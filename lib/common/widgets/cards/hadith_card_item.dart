import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';

/// Reusable hadith card item widget with text, translation, and info badges.
class HadithCardItem extends StatelessWidget {
  const HadithCardItem({
    super.key,
    required this.arabicText,
    required this.narratorText,
    required this.translationText,
    required this.translationLang,
    required this.bookName,
    required this.hadithNumber,
    required this.status,
  });

  final String arabicText;
  final String narratorText;
  final String translationText;
  final String translationLang;
  final String bookName;
  final int hadithNumber;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0EF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.1).toInt()),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Arabic Hadith Text
          Text(
            arabicText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              fontSize: 22,
              height: 2.1,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // Narrator Section: heading + text, white background
          if (narratorText.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF329070),
                  width: 4.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    translationLang.toLowerCase().startsWith('ur')
                        ? 'راوی'
                        : 'Narrator',
                    textAlign: TextDirectionUtils.alignFor(translationLang),
                    style: translationLang.toLowerCase().startsWith('ur')
                        ? GoogleFonts.notoNastaliqUrdu(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 2.5,
                          )
                        : const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    narratorText,
                    textDirection:
                        TextDirectionUtils.directionFor(translationLang),
                    textAlign: TextDirectionUtils.alignFor(translationLang),
                    style: translationLang == 'ur'
                        ? GoogleFonts.notoNastaliqUrdu(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            height: 2.5,
                          )
                        : GoogleFonts.lateef(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                  ),
                ],
              ),
            ),
          if (narratorText.isNotEmpty) const SizedBox(height: 12),

          // Translation Text
          Text(
            translationText,
            textDirection: TextDirectionUtils.directionFor(translationLang),
            textAlign: TextDirectionUtils.alignFor(translationLang),
            style: translationLang == 'ur'
                ? GoogleFonts.notoNastaliqUrdu(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                    height: 3.0,
                  )
                : GoogleFonts.lateef(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                  ),
          ),
          const SizedBox(height: 16),
          // Single info tile containing all three fields (left/center/right)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF60BEA8),
                  Color(0xFF329070),
                  Color(0xFF1C5D4E)
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      bookName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      hadithNumber.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      status,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
