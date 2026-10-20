import 'dart:math' as math;

import 'package:ecommerce_app/common/widgets/auth/auth_background_panel.dart';
import 'package:ecommerce_app/common/widgets/auth/gradient_button.dart';
import 'package:ecommerce_app/common/widgets/auth/gradient_title.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportSuccessScreen extends StatelessWidget {
  const SupportSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final type = args?['type'] as String? ?? 'stripe';
    final transactionId = args?['transactionId'] as String? ?? '';
    final rawAmount = args?['amount'];
    final amount = rawAmount is num ? rawAmount.toDouble() : 0.0;
    final isManualPayment = type == 'manual';

    return AuthBackgroundPanel(
      centerContent: true,
      maxWidth: 470,
      outerPadding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      contentPadding: const EdgeInsets.fromLTRB(26, 82, 26, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const _SuccessBadge(),
          const SizedBox(height: 34),
          GradientTitle(
            text: 'JazakAllah Khair!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                ),
          ),
          const SizedBox(height: 24),
          const _OrnamentDivider(),
          if (amount > 0) ...[
            const SizedBox(height: 18),
            Text(
              'PKR ${amount.toStringAsFixed(0)}',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text(
            isManualPayment
                ? 'Your payment proof has been submitted. We will verify it within 24 hours, inshAllah.'
                : 'Your support has been received. May Allah reward you.',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: const Color(0xFF4E5661),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          if (transactionId.isNotEmpty) ...[
            const SizedBox(height: 30),
            _TransactionIdCard(transactionId: transactionId),
          ],
          const SizedBox(height: 20),
          _PrimaryActionButton(
            text: 'View My Support History',
            onPressed: () => Get.offAllNamed('/app-support/history'),
          ),
          const SizedBox(height: 20),
          _SecondaryActionButton(
            text: 'Back to Home',
            onPressed: () => Get.offAllNamed('/home'),
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
      height: 172,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 18,
            child: Container(
              width: 214,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1C5D4E).withValues(alpha: 0.04),
                    const Color(0xFF60BEA8).withValues(alpha: 0.12),
                    const Color(0xFF1C5D4E).withValues(alpha: 0.04),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 74,
            top: 78,
            child: _Sparkle(size: 13, opacity: 0.62),
          ),
          Positioned(
            right: 72,
            top: 84,
            child: _Sparkle(size: 12, opacity: 0.62),
          ),
          Positioned(
            left: 58,
            bottom: 50,
            child: _SoftDot(size: 10),
          ),
          Positioned(
            right: 54,
            bottom: 48,
            child: _SoftDot(size: 8),
          ),
          SizedBox(
            width: 156,
            height: 156,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7F2).withValues(alpha: 0.88),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 122,
                  height: 122,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.98),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1C5D4E).withValues(alpha: 0.14),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 106,
                  height: 106,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF41D28E),
                        Color(0xFF087457),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF329070).withValues(alpha: 0.30),
                        blurRadius: 20,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 68,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrnamentDivider extends StatelessWidget {
  const _OrnamentDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _SoftLine(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Icon(
            Icons.brightness_5_outlined,
            color: Color(0xFF329070),
            size: 29,
          ),
        ),
        _SoftLine(reverse: true),
      ],
    );
  }
}

class _SoftLine extends StatelessWidget {
  const _SoftLine({this.reverse = false});

  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.transparent,
      const Color(0xFF329070).withValues(alpha: 0.46),
    ];

    return Container(
      width: 82,
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reverse ? colors.reversed.toList() : colors,
        ),
      ),
    );
  }
}

class _TransactionIdCard extends StatelessWidget {
  const _TransactionIdCard({required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.only(left: 22, right: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E8E2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C5D4E).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'ID: $transactionId',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                color: const Color(0xFF4E5661),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: const Color(0xFFEAF7F2),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Clipboard.setData(ClipboardData(text: transactionId));
                PLoaders.successSnackBar(
                  title: 'Copied!',
                  message: 'Transaction ID copied to clipboard',
                  context: context,
                );
              },
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.copy_rounded,
                  color: PColors.primary,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C5D4E).withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: GradientButton(
        onPressed: onPressed,
        text: text,
        height: 68,
        borderRadius: 26,
        fontSize: 22,
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.86),
          side: const BorderSide(color: PColors.primary, width: 1.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.brightness_5_outlined,
              color: Color(0xFFB9DDD2),
              size: 30,
            ),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  color: const Color(0xFF147958),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.brightness_5_outlined,
              color: Color(0xFFB9DDD2),
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size.square(size),
        painter: _SparklePainter(),
      ),
    );
  }
}

class _SoftDot extends StatelessWidget {
  const _SoftDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFBDE1D6).withValues(alpha: 0.75),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBDE1D6)
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();

    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final radius = i.isEven ? size.width / 2 : size.width / 5;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
