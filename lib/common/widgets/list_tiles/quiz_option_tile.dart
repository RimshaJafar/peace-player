import 'package:flutter/material.dart';

class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    super.key,
    required this.optionText,
    required this.isSelected,
    required this.onTap,
    required this.optionNumber,
    this.textDirection = TextDirection.ltr,
  });

  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;
  final int optionNumber;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 66),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? const [Color(0xFFD97D55), Color(0xFFE99A76)]
                : const [Color(0xFF77ACA2), Color(0xFF63998F)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.65),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected
                      ? const Color(0xFFD97D55)
                      : const Color(0xFF527E76))
                  .withValues(alpha: 0.20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          textDirection: textDirection,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '$optionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                optionText,
                textDirection: textDirection,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily:
                      textDirection == TextDirection.rtl ? 'Lateef' : 'Poppins',
                  fontSize: textDirection == TextDirection.rtl ? 21 : 16,
                  height: textDirection == TextDirection.rtl ? 1.35 : 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
