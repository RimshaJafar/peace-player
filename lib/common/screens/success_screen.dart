import 'dart:math' as math;

import 'package:ecommerce_app/common/widgets/auth/auth_background_panel.dart';
import 'package:ecommerce_app/common/widgets/auth/gradient_button.dart';
import 'package:ecommerce_app/common/widgets/auth/gradient_title.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class PSuccessScreen extends StatelessWidget {
  const PSuccessScreen({
    super.key,
    required this.lottie,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final String lottie, title, subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundPanel(
      centerContent: true,
      maxWidth: 470,
      outerPadding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      contentPadding: const EdgeInsets.fromLTRB(30, 82, 30, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SuccessBadge(),
          const SizedBox(height: 36),
          GradientTitle(
            text: title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.14,
                ),
          ),
          const SizedBox(height: 22),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4E5661),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C5D4E).withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: GradientButton(
              onPressed: onPressed,
              text: PTexts.pcontinue,
              height: 60,
              borderRadius: 34,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 154,
      child: Center(
        child: SizedBox(
          width: 154,
          height: 154,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 138,
                height: 138,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2FAF6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1C5D4E).withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 132,
                height: 132,
                child: CustomPaint(
                  painter: _SuccessArcPainter(),
                ),
              ),
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFA8F0CC),
                      Color(0xFF60D2A3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF60D2A3).withValues(alpha: 0.28),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessArcPainter extends CustomPainter {
  const _SuccessArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - 5;

    final basePaint = Paint()
      ..color = const Color(0xFFE7F3EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final arcPaint = Paint()
      ..color = const Color(0xFF60D2A3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 0.58,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
