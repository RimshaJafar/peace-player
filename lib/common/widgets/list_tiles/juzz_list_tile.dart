import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/widgets/badges/gradient_range_badge.dart';

/// Reusable juzz list tile widget with all styling and interaction.
class JuzzListTile extends StatelessWidget {
  const JuzzListTile({
    super.key,
    required this.juzNumber,
    required this.juzNameEnglish,
    required this.juzNameArabic,
    required this.startAyahNumber,
    required this.endAyahNumber,
    required this.onTap,
  });

  final int juzNumber;
  final String juzNameEnglish;
  final String juzNameArabic;
  final int startAyahNumber;
  final int endAyahNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const leftTextStyle = TextStyle(
      fontSize: 16,
      color: Colors.black,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6F0EF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0x24000000),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "$juzNumber)",
                          style: leftTextStyle,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            juzNameEnglish,
                            style: leftTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    juzNameArabic,
                    style: GoogleFonts.amiri(
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    "$juzNumber)",
                    style: leftTextStyle.copyWith(color: Colors.transparent),
                  ),
                  const SizedBox(width: 8),
                  GradientRangeBadge(
                    startNumber: startAyahNumber,
                    endNumber: endAyahNumber,
                  ),
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
