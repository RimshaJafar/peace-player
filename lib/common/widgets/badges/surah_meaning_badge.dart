import 'package:flutter/material.dart';

/// Reusable surah meaning badge with scrollable text and gradient background.
class SurahMeaningBadge extends StatelessWidget {
  const SurahMeaningBadge({
    super.key,
    required this.meaning,
  });

  final String meaning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.1).toInt()),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        meaning,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}
