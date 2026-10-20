import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class IconButtonContainer extends StatelessWidget {
  const IconButtonContainer({
    super.key,
    required this.iconPath,
    required this.backgroundColor,
    this.rotate90 = false,
    this.onTap,
  });

  final String iconPath;
  final Color backgroundColor;
  final bool rotate90;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final buttonSize = PSizes.quizButtonSize(context);
    final iconSize = buttonSize * 0.55;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: onTap == null ? 0.45 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor.withValues(alpha: 0.82),
                backgroundColor,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.24),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Transform.rotate(
              angle: rotate90 ? 3.14159 : 0, // 180 degrees in radians
              child: Image.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                errorBuilder: (context, error, stack) => Icon(
                  Icons.check,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
