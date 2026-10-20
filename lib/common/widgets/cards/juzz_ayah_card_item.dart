import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';

/// Reusable juzz ayah card item widget displaying Arabic text, translation, and juzz:index badge.
class JuzzAyahCardItem extends StatelessWidget {
  const JuzzAyahCardItem({
    super.key,
    required this.juzNumber,
    required this.itemIndex,
    required this.arabicText,
    required this.translationText,
    this.tafseerText = '',
    this.currentLang = 'ur',
    this.tafseerLang,
    this.onPlayAudio,
    this.isPlaying = false,
  });

  final int juzNumber;
  final int itemIndex;
  final String arabicText;
  final String translationText;
  final String tafseerText;
  final String currentLang;
  final String? tafseerLang;
  final VoidCallback? onPlayAudio;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0EF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.14).toInt()),
            offset: const Offset(0, 1),
            blurRadius: 2.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ayah number badge (juz:index format)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF60BEA8),
                          Color(0xFF329070),
                          Color(0xFF1C5D4E),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$juzNumber:$itemIndex",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Arabic text
              Text(
                arabicText,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: GoogleFonts.amiri(
                  height: 2.1,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: PSizes.spaceBtwItems),
              // Translation (if not empty)
              if (translationText.isNotEmpty)
                Text(
                  translationText,
                  textDirection: TextDirectionUtils.directionFor(currentLang),
                  textAlign: TextDirectionUtils.alignFor(currentLang),
                  style: currentLang == 'ur'
                      ? GoogleFonts.notoNastaliqUrdu(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.black87,
                          height: 2.5,
                        )
                      : GoogleFonts.lateef(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                ),
              // Tafseer (if not empty)
              if (tafseerText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF329070),
                      width: 4.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Builder(builder: (context) {
                        final lang = tafseerLang ?? currentLang;
                        final label = () {
                          switch (lang) {
                            case 'ur':
                              return 'تفسیر';
                            case 'hi':
                              return 'तफ़सीर';
                            case 'ben':
                              return 'তাফসির';
                            default:
                              return 'Tafseer';
                          }
                        }();
                        final isRtl = lang == 'ur';
                        return Text(
                          label,
                          textAlign: isRtl ? TextAlign.right : TextAlign.left,
                          textDirection:
                              isRtl ? TextDirection.rtl : TextDirection.ltr,
                          style: GoogleFonts.notoNastaliqUrdu(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF329070),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      Text(
                        tafseerText,
                        textDirection: TextDirectionUtils.directionFor(
                            tafseerLang ?? currentLang),
                        textAlign: TextDirectionUtils.alignFor(
                            tafseerLang ?? currentLang),
                        style: (tafseerLang ?? currentLang) == 'ur'
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
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
          // Audio button on top-left using asset icon
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: onPlayAudio,
              child: Image.asset(
                'assets/icons/audio.png', // path to your audio icon asset
                width: 24,
                height: 24,
                color: isPlaying
                    ? const Color(0xFF329070)
                    : Colors.grey, // tint shows playing status
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method for rounded gradient icon button
  /// Updated helper method for rounded gradient icon button with asset icon
  Widget _buildGradientIconButton({
    required String assetPath,
    required VoidCallback onPressed,
    String? text, // optional text like "AI"
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF60BEA8),
              Color(0xFF329070),
              Color(0xFF1C5D4E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: text != null
              ? Stack(
                  children: [
                    Positioned(
                      left: 3,
                      top: 8,
                      child: Image.asset(
                        assetPath,
                        width: 20,
                        height: 22,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 12,
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              : Image.asset(
                  assetPath,
                  width: 30,
                  height: 30,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
