import 'package:flutter/material.dart';

class GradientTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const GradientTitle({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context)
        .textTheme
        .headlineMedium
        ?.copyWith(color: Colors.white);
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF60BEA8),
          Color(0xFF329070),
          Color(0xFF1C5D4E),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: style ?? defaultStyle,
        textAlign: textAlign,
      ),
    );
  }
}
