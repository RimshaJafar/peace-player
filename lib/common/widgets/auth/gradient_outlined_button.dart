import 'package:flutter/material.dart';

class GradientOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;
  final double padding;
  final double borderThickness;

  const GradientOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 30,
    this.padding = 10,
    this.borderThickness = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF60BEA8),
            Color(0xFF329070),
            Color(0xFF1C5D4E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(borderThickness),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            side: BorderSide.none,
            padding: EdgeInsets.symmetric(vertical: padding),
          ),
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}
