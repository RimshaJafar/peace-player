import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';

/// Reusable ayah card item widget displaying Arabic text, translation, and ayah number badge.
class AyahCardItem extends StatelessWidget {
  const AyahCardItem({
    super.key,
    required this.surahNumber,
    required this.ayahNumberInSurah,
    required this.arabicText,
    required this.translationText,
    this.tafseerText = '',
    this.currentLang = 'ur',
    this.tafseerLang,
    this.onPlayAudio,
    this.isPlaying = false,
  });

  final int surahNumber;
  final int ayahNumberInSurah;
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
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah number badge
          Row(
            children: [
              IconButton(
                onPressed: onPlayAudio,
                icon: const Icon(Icons.volume_up),
                color: isPlaying ? const Color(0xFF329070) : Colors.grey,
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                margin: const EdgeInsets.only(bottom: 8),
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
                child: Text(
                  "$surahNumber:$ayahNumberInSurah",
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
            style: GoogleFonts.amiri(fontSize: 24, height: 2.1),
          ),
          const SizedBox(height: 16),
          // Translation
          Text(
            translationText,
            textDirection: TextDirectionUtils.directionFor(currentLang),
            textAlign: TextDirectionUtils.alignFor(currentLang),
            style: currentLang == 'ur'
                ? GoogleFonts.notoNastaliqUrdu(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    height: 2.5,
                  )
                : GoogleFonts.lateef(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
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
                    textAlign:
                        TextDirectionUtils.alignFor(tafseerLang ?? currentLang),
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
    );
  }

  /// Helper method for rounded gradient icon button
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
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
