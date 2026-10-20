import 'package:flutter/material.dart';

class PFormDivider extends StatelessWidget {
  const PFormDivider({super.key, required this.dividerText});

  final String dividerText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            color: const Color(0xFFD9DFDD),
            thickness: 1.2,
            indent: 44,
            endIndent: 14,
          ),
        ),
        Text(
          dividerText,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF6E7778),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
        ),
        Expanded(
          child: Divider(
            color: const Color(0xFFD9DFDD),
            thickness: 1.2,
            indent: 14,
            endIndent: 44,
          ),
        ),
      ],
    ); // Row
  }
}
