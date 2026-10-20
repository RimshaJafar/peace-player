import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/widgets/badges/gradient_range_badge.dart';

/// Reusable hadith chapter card widget with all styling and interaction.
class HadithChapterCard extends StatelessWidget {
  const HadithChapterCard({
    super.key,
    required this.chapterId,
    required this.chapterLeftName,
    required this.chapterRightName,
    required this.startHadithNumber,
    required this.endHadithNumber,
    required this.onTap,
  });

  final int chapterId;
  final String chapterLeftName;
  final String chapterRightName;
  final int startHadithNumber;
  final int endHadithNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6F0EF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.14).toInt()),
              offset: const Offset(0, 1),
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
          onTap: onTap,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main row with chapter ID, English, and Arabic name
              LayoutBuilder(
                builder: (context, constraints) {
                  final shouldStackNames = constraints.maxWidth < 360;

                  if (shouldStackNames) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '$chapterId)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  chapterLeftName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 28),
                          child: Text(
                            chapterRightName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.amiri(
                              fontSize: 22,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chapter ID (no padding, inline)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '$chapterId)',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // English Chapter Name
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            chapterLeftName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Arabic Chapter Name
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              chapterRightName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.amiri(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Hadith range badge (using shared GradientRangeBadge)
              Row(
                children: [
                  // Transparent spacer so the badge lines up with the chapter name text start
                  Text(
                    '$chapterId)',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.transparent,
                      
                    ),
                  ),
                  const SizedBox(width: 8),
                  GradientRangeBadge(
                    startNumber: startHadithNumber,
                    endNumber: endHadithNumber,
                    width: 100,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    separator: '-',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
