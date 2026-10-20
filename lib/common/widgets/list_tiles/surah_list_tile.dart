import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/widgets/badges/surah_meaning_badge.dart';
import 'package:ecommerce_app/common/widgets/badges/gradient_range_badge.dart';

/// Reusable surah list tile widget with all styling and interaction.
class SurahListTile extends StatelessWidget {
  const SurahListTile({
    super.key,
    required this.surahNumber,
    required this.surahNameEnglish,
    required this.surahNameArabic,
    required this.surahMeaning,
    required this.startAyahNumber,
    required this.endAyahNumber,
    required this.onTap,
  });

  final int surahNumber;
  final String surahNameEnglish;
  final String surahNameArabic;
  final String surahMeaning;
  final int startAyahNumber;
  final int endAyahNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE6F0EF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.14).toInt()),
              offset: Offset(0, 1),
              blurRadius: 2.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 16.0,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          '$surahNumber)',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            surahNameEnglish,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      surahNameArabic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // BOTTOM ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: Meaning + Ayah range
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Spacer to align badges with surah name
                        Text(
                          '$surahNumber)',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.transparent,
                          ),
                        ),
                        // Meaning badge
                        SurahMeaningBadge(meaning: surahMeaning),
                        // Ayah range badge
                        GradientRangeBadge(
                          startNumber: startAyahNumber,
                          endNumber: endAyahNumber,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Right side: Heart icon
                  // IconButton(
                  //   icon: const Icon(Icons.favorite_border),
                  //   iconSize: 28.0,
                  //   color: Colors.green,
                  //   onPressed: () {
                  //     // Handle the tap
                  //   },
                  // ),
                ],
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
