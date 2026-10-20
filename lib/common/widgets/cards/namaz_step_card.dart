import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/good_words_color_palette.dart';

class NamazStepCard extends StatelessWidget {
  const NamazStepCard({
    super.key,
    required this.content,
    this.gradient,
    this.circleColor,
    this.cardIndex,
    this.onPlayAudio,
  });

  final Widget content;
  final LinearGradient? gradient;
  final Color? circleColor;
  final int? cardIndex;
  final VoidCallback? onPlayAudio;

  @override
  Widget build(BuildContext context) {
    // Get color set based on index with reversed gradient (bottom to top)
    final colorSet = cardIndex != null
        ? GoodWordsColorPalette.getColorSetReversed(cardIndex!)
        : GoodWordsColorSet(
            gradient: gradient ??
                const LinearGradient(
                  colors: [Color(0xFFCAA5CB), Color(0xFFD8B8D9)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
            circleColor: circleColor ?? const Color(0xFFCAA5CB),
          );

    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: gradient ?? colorSet.gradient,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.60),
              ),
              boxShadow: [
                BoxShadow(
                  color: (circleColor ?? colorSet.circleColor)
                      .withValues(alpha: 0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: content,
          ),
          Positioned(
            left: 18,
            top: -22,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPlayAudio,
                child: Ink(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (circleColor ?? colorSet.circleColor)
                            .withValues(alpha: 0.82),
                        circleColor ?? colorSet.circleColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (circleColor ?? colorSet.circleColor)
                            .withValues(alpha: 0.34),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 24,
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
