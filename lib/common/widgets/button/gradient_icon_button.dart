import 'package:flutter/material.dart';

class GradientIconButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onPressed;
  final String? text;

  const GradientIconButton({
    super.key,
    required this.assetPath,
    required this.onPressed,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF60BEA8),
              Color(0xFF329070),
              Color(0xFF1C5D4E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: text != null
              ? Stack(
                  children: [
                    Positioned(
                      left: 3,
                      top: 8,
                      child: Image.asset(
                        assetPath,
                        width: 20,
                        height: 22,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 12,
                      child: Text(
                        text!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              : Image.asset(
                  assetPath,
                  width: 30,
                  height: 30,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
