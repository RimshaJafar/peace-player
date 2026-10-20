import 'package:flutter/material.dart';

class MoralListTile extends StatelessWidget {
  const MoralListTile({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.index,
    this.textDirection = TextDirection.ltr,
    this.textColor = const Color(0xFF263842),
  });

  final String text;
  final Color backgroundColor;
  final int index;
  final TextDirection textDirection;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final isRtl = textDirection == TextDirection.rtl;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
          end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            backgroundColor.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: backgroundColor.withValues(alpha: 0.38),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF526F83).withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        textDirection: textDirection,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              textDirection: textDirection,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: textColor,
                fontFamily: isRtl ? 'Lateef' : 'Poppins',
                fontSize: isRtl ? 21 : 15,
                height: isRtl ? 1.45 : 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
