import 'package:flutter/material.dart';

class GoodWordsColorSet {
  final LinearGradient gradient;
  final Color circleColor;

  const GoodWordsColorSet({
    required this.gradient,
    required this.circleColor,
  });
}

class GoodWordsColorPalette {
  static const List<GoodWordsColorSet> colorSets = [
    // 1st Set
    GoodWordsColorSet(
      gradient: LinearGradient(
        colors: [Color(0xFFF9957F), Color(0xFFF2F5D0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      circleColor: Color(0xFFF9957F),
    ),
    // 2nd Set
    GoodWordsColorSet(
      gradient: LinearGradient(
        colors: [Color(0xFF9FA5D5), Color(0xFFE8F5C8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      circleColor: Color(0xFF9FA5D5),
    ),
    // 3rd Set
    GoodWordsColorSet(
      gradient: LinearGradient(
        colors: [Color(0xFFAE8BA1), Color(0xFFF2ECB6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      circleColor: Color(0xFFAE8BA1),
    ),
    // 4th Set
    GoodWordsColorSet(
      gradient: LinearGradient(
        colors: [Color(0xFF1A4474), Color(0xFFE8F5C8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      circleColor: Color(0xFF1A4474),
    ),
    // 5th Set
    GoodWordsColorSet(
      gradient: LinearGradient(
        colors: [Color(0xFF4A2C37), Color(0xFFF2ECB6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      circleColor: Color(0xFF4A2C37),
    ),
  ];

  /// Get color set by index (cycles every 5 cards)
  static GoodWordsColorSet getColorSet(int index) {
    return colorSets[index % colorSets.length];
  }

  /// Get color set with reversed gradient (bottom to top) for namaz steps
  static GoodWordsColorSet getColorSetReversed(int index) {
    final originalSet = colorSets[index % colorSets.length];
    return GoodWordsColorSet(
      gradient: LinearGradient(
        colors: originalSet.gradient.colors,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
      circleColor: originalSet.circleColor,
    );
  }
}
