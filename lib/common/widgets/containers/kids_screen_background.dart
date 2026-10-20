import 'package:flutter/material.dart';

class KidsScreenBackground extends StatelessWidget {
  const KidsScreenBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF4E5),
            Color(0xFFE9F3EF),
            Color(0xFFDCEAF3),
          ],
          stops: [0, 0.52, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: -75,
            right: -55,
            child: _BackgroundCircle(
              size: 190,
              color: Color(0x1FD97D55),
            ),
          ),
          const Positioned(
            top: 230,
            left: -70,
            child: _BackgroundCircle(
              size: 170,
              color: Color(0x2477ACA2),
            ),
          ),
          const Positioned(
            right: -65,
            bottom: -80,
            child: _BackgroundCircle(
              size: 210,
              color: Color(0x24CAA5CB),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
