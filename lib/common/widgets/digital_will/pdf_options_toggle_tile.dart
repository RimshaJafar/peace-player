import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A premium toggle tile for PDF content options.
class PdfOptionsToggleTile extends StatelessWidget {
  const PdfOptionsToggleTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: value
                  ? const Color(0xFF1A5B48)
                  : const Color(0xFF8CA8A0),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D4A42),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF7A9B91),
                    ),
                  ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF1A5B48),
              activeTrackColor: const Color(0xFFB8DDD1),
              inactiveThumbColor: const Color(0xFFB0B0B0),
              inactiveTrackColor: const Color(0xFFE0E0E0),
            ),
          ),
        ],
      ),
    );
  }
}
