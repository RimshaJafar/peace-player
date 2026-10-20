import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/utils/good_words_color_palette.dart';

class GoodWordsCard extends StatelessWidget {
  const GoodWordsCard({
    super.key,
    required this.arabicText,
    required this.translationText,
    this.translationIsUrdu = true,
    this.gradient,
    this.arabicColor = Colors.white,
    this.urduColor = Colors.black,
    this.circleColor,
    this.iconPath = 'assets/icons/volume.png',
    this.cardIndex,
    this.onPlayAudio,
  });

  final String arabicText;
  final String translationText;
  final bool translationIsUrdu;
  final LinearGradient? gradient;
  final Color arabicColor;
  final Color urduColor;
  final Color? circleColor;
  final String iconPath;
  final int? cardIndex;
  final VoidCallback? onPlayAudio;

  @override
  Widget build(BuildContext context) {
    // Get color set based on index (cycles every 5 cards)
    final colorSet = cardIndex != null
        ? GoodWordsColorPalette.getColorSet(cardIndex!)
        : GoodWordsColorSet(
            gradient: gradient ??
                const LinearGradient(
                  colors: [Color(0xFFCAA5CB), Color(0xFFD8B8D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            circleColor: circleColor ?? const Color(0xFFCAA5CB),
          );

    return SizedBox(
      width: 346,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 156,
              width: 346,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: gradient ?? colorSet.gradient,
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      arabicText,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: arabicColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: Text(
                      translationText,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: translationIsUrdu
                          ? GoogleFonts.notoNastaliqUrdu(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: urduColor,
                            )
                          : GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: urduColor,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: -23.5,
            child: GestureDetector(
              onTap: onPlayAudio,
              child: Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: circleColor ?? colorSet.circleColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    width: 28,
                    height: 28,
                    errorBuilder: (context, error, stack) => const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
