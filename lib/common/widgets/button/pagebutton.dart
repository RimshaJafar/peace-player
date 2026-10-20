import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';

class PageButton extends StatelessWidget {
  const PageButton({
    required this.iconPath,
    required this.onTap,
    required this.enabled,
  });

  final String iconPath;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: PColors.linearGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: PColors.linearGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            iconPath,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => const Icon(
              Icons.error_outline,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
