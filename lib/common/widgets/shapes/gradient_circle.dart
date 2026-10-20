import 'package:flutter/material.dart';

class GradientCircle extends StatelessWidget {
  final List<Color> colors;
  final double size;

  const GradientCircle({
    super.key,
    required this.colors,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
