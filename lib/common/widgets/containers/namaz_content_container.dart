import 'package:flutter/material.dart';

class NamazContentContainer extends StatelessWidget {
  const NamazContentContainer({
    super.key,
    this.child,
    this.backgroundColor = const Color(0xFFFFFFFF),
  });

  final Widget? child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              Color.lerp(backgroundColor, const Color(0xFFEEF6F3), 0.42)!,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.90),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF526F83).withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
