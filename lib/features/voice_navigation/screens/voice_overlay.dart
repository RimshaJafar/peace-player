import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../controllers/voice_navigation_controller.dart';
import 'dart:math' as math;

class VoiceOverlay extends StatelessWidget {
  final VoiceNavigationController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.state.value;

      // Don't show anything when idle or success
      if (state == VoiceNavState.idle || state == VoiceNavState.success) {
        return SizedBox.shrink();
      }

      return Positioned(
        bottom: 50,
        left: 0,
        right: 0,
        child: Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _buildVoiceIndicator(state),
          ),
        ),
      );
    });
  }

  Widget _buildVoiceIndicator(VoiceNavState state) {
    switch (state) {
      case VoiceNavState.listening:
        return _SiriLikeIndicator(
          key: ValueKey('listening'),
          isListening: true,
          isProcessing: false,
        );
      case VoiceNavState.processing:
        return _SiriLikeIndicator(
          key: ValueKey('processing'),
          isListening: false,
          isProcessing: true,
        );
      case VoiceNavState.error:
        return _ErrorIndicator(
          key: ValueKey('error'),
          message: controller.errorMessage.value,
        );
      default:
        return SizedBox.shrink();
    }
  }
}

class _SiriLikeIndicator extends StatefulWidget {
  final bool isListening;
  final bool isProcessing;

  const _SiriLikeIndicator({
    super.key,
    required this.isListening,
    required this.isProcessing,
  });

  @override
  State<_SiriLikeIndicator> createState() => _SiriLikeIndicatorState();
}

class _SiriLikeIndicatorState extends State<_SiriLikeIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for processing state
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation for listening state
    _waveController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat();

    // Glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: widget.isListening
                    ? Color(0xFF00897B).withOpacity(0.4 * _glowAnimation.value)
                    : Color(0xFFFFB300).withOpacity(0.4 * _glowAnimation.value),
                blurRadius: 25 + (8 * _glowAnimation.value),
                spreadRadius: 3 + (3 * _glowAnimation.value),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isListening
                        ? [
                            Color(0xFF00695C).withOpacity(0.25),
                            Color(0xFF004D40).withOpacity(0.15),
                          ]
                        : [
                            Color(0xFFFF8F00).withOpacity(0.25),
                            Color(0xFFE65100).withOpacity(0.15),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: widget.isListening
                        ? Color(0xFF4DB6AC).withOpacity(0.4)
                        : Color(0xFFFFD54F).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isListening)
                      _buildListeningAnimation()
                    else if (widget.isProcessing)
                      _buildProcessingAnimation(),
                    SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isListening ? 'Listening' : 'Processing',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          widget.isListening ? 'Speak now' : 'Please wait',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListeningAnimation() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          width: 55,
          height: 55,
          child: CustomPaint(
            size: Size(55, 55),
            painter: _WaveformPainter(
              animation: _waveController.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessingAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFFFFB300),
                  Color(0xFFFF8F00),
                  Color(0xFFE65100),
                  Color(0xFFFFB300),
                ],
                stops: [0.0, 0.33, 0.66, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF8F00).withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                ),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double animation;

  _WaveformPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw animated outer rings (Islamic teal/green theme)
    for (int i = 0; i < 3; i++) {
      final progress = (animation + i * 0.25) % 1.0;
      final radius = (size.width / 4) + (progress * size.width / 3);
      final opacity = (1.0 - progress) * 0.4;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + (2 * (1 - progress))
        ..shader = LinearGradient(
          colors: [
            Color(0xFF26A69A).withOpacity(opacity),
            Color(0xFF00897B).withOpacity(opacity),
            Color(0xFF00695C).withOpacity(opacity),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }

    // Draw center orb with Islamic green gradient
    final orbPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color(0xFF4DB6AC),
          Color(0xFF26A69A),
          Color(0xFF00897B),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 5));

    canvas.drawCircle(center, size.width / 5, orbPaint);

    // Draw animated sound bars in the center
    final barPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    const barCount = 7;
    const barWidth = 2.0;
    const spacing = 4.0;
    const maxBarHeight = 20.0;

    final totalWidth = (barCount * barWidth) + ((barCount - 1) * spacing);
    final startX = center.dx - (totalWidth / 2);

    for (int i = 0; i < barCount; i++) {
      // Each bar has its own phase
      final phase = (i - barCount / 2).abs() / (barCount / 2);
      final barHeight = maxBarHeight *
          (0.2 +
              0.8 * math.sin((animation * math.pi * 3) + (i * math.pi / 4))) *
          (1 - phase * 0.3);

      final x = startX + (i * (barWidth + spacing));
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, center.dy),
          width: barWidth,
          height: barHeight.abs(),
        ),
        Radius.circular(1.5),
      );

      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _ErrorIndicator extends StatelessWidget {
  final String message;

  const _ErrorIndicator({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Auto dismiss after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      try {
        final controller = Get.find<VoiceNavigationController>();
        controller.state.value = VoiceNavState.idle;
      } catch (e) {
        // Controller might be disposed
      }
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: BoxConstraints(maxWidth: 300),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade600,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
