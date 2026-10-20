import 'dart:math' as math;

import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/qibla/controllers/qibla_controller.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QiblaDirectionScreen extends StatefulWidget {
  const QiblaDirectionScreen({super.key});

  @override
  State<QiblaDirectionScreen> createState() => _QiblaDirectionScreenState();
}

class _QiblaDirectionScreenState extends State<QiblaDirectionScreen> {
  late final QiblaController _controller;

  static const _deepGreen = Color(0xFF0B4D3A);
  static const _primaryGreen = Color(0xFF1C7459);
  static const _mint = Color(0xFF62CDB0);
  static const _pageColor = Color(0xFFF7F8F3);

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<QiblaController>()) {
      Get.put(QiblaController());
    }
    _controller = Get.find<QiblaController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageColor,
      appBar: PAppBar(
        title: const Text(
          'Qibla Direction',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14785C), Color(0xFF083F31)],
        ),
        showBackArrow: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            iconSize: 28,
            onPressed: () => _controller.recalculateQibla(),
            tooltip: 'Recalculate Qibla',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return _buildLoadingIndicator();
        }
        if (_controller.error.value != null) {
          return _buildErrorWidget(_controller.error.value!);
        }
        if (!_controller.isCompassAvailable.value) {
          return _buildCompassNotAvailableWidget();
        }
        return _buildBody();
      }),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: _pageColor)),
        Positioned.fill(
          child: Opacity(
            opacity: 0.48,
            child: Image.asset(
              PImages.mosqueBackground,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 105),
            Expanded(
              child: LayoutBuilder(
                builder: (context, viewportConstraints) {
                  final contentWidth = math.min(
                    600.0,
                    math.max(0.0, viewportConstraints.maxWidth - 32),
                  );
                  final compassSize = math.min(225.0, contentWidth * 0.68);
                  final minimumContentHeight = math.max(
                    0.0,
                    viewportConstraints.maxHeight - 24,
                  );

                  return ClipRect(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 600,
                            minHeight: minimumContentHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(child: _buildCompass(compassSize)),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 14, 0, 6),
                                  child: _buildGuidanceCard(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: _buildDirectionCards(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompass(double size) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.035),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FFFB), Color(0xFFCAE4D8)],
        ),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: _deepGreen.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final diameter = constraints.maxWidth;
          final needleLength = diameter * 0.64;
          final qiblaLineHeight = needleLength / 2 - 30;

          return ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: CompassPainter()),
                ),

                // Device heading needle. Its angle and source are unchanged.
                Transform.rotate(
                  angle: _controller.deviceHeadingRadians,
                  child: CustomPaint(
                    painter: NeedlePainter(color: const Color(0xFFFF493B)),
                    child: SizedBox(width: 14, height: needleLength),
                  ),
                ),

                // Qibla pointer. The controller still provides the same angle.
                Transform.rotate(
                  angle: _controller.relativeQiblaAngle,
                  child: SizedBox(
                    width: 48,
                    height: needleLength,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          top: 28,
                          child: Container(
                            width: 6,
                            height: math.max(0, qiblaLineHeight),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [_mint, Color(0xFF269572)],
                              ),
                              borderRadius: BorderRadius.circular(99),
                              boxShadow: [
                                BoxShadow(
                                  color: _mint.withValues(alpha: 0.28),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: Container(
                            width: 38,
                            height: 38,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFB7DACE),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/content/kaaba.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  width: diameter * 0.095,
                  height: diameter * 0.095,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_mint, Color(0xFF279273)],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.72),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 9,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String get _displayGuidance => _controller.guidanceMessage
      .replaceAll('Â°', '°')
      .replaceAll('âœ“', '✓');

  Widget _buildGuidanceCard() {
    return Obx(() {
      final aligned = _controller.isAligned;
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: aligned
                ? const Color(0xFF57B994)
                : const Color(0xFFC8DED5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _deepGreen.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1C7459), Color(0xFF083F31)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBBDACC), width: 3),
                  ),
                  child: Image.asset(
                    'assets/images/content/kaaba.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _displayGuidance,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: aligned
                          ? const Color(0xFF167253)
                          : _deepGreen,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFD7E5DF))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: _primaryGreen.withValues(alpha: 0.58),
                    size: 14,
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFD7E5DF))),
              ],
            ),
            const SizedBox(height: 5),
            const Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'جب تیر سیدھی سمت پر آ جائے تو موبائل کو اسی رخ پر سیدھا رکھیں — یہی قبلہ ہے۔',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4C5652),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDirectionCards() {
    return Row(
      children: [
        Expanded(
          child: _DirectionMetricCard(
            icon: Icons.explore_rounded,
            label: 'Qibla Direction',
            value: Obx(
              () => Text(
                '${_controller.qiblaDirection.value?.toStringAsFixed(1) ?? '—'}°',
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DirectionMetricCard(
            icon: Icons.my_location_rounded,
            label: 'Your Direction',
            value: Obx(
              () => Text(
                '${_controller.deviceDirection.value.toStringAsFixed(1)}°',
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const _QiblaStateView(
      icon: Icons.explore_rounded,
      title: 'Finding Qibla',
      message: 'Calculating the direction from your current location…',
      showProgress: true,
    );
  }

  Widget _buildErrorWidget(String error) {
    return _QiblaStateView(
      icon: Icons.location_off_rounded,
      title: 'Unable to find Qibla',
      message: error,
      actionLabel: 'Try Again',
      onAction: () => _controller.recalculateQibla(),
    );
  }

  Widget _buildCompassNotAvailableWidget() {
    return _QiblaStateView(
      icon: Icons.explore_off_rounded,
      title: 'Compass Not Available',
      message:
          'This device does not have a compass sensor. Qibla direction can be calculated, but real-time orientation is unavailable.',
      actionLabel: 'Recalculate Qibla',
      onAction: () => _controller.recalculateQibla(),
    );
  }
}

class _DirectionMetricCard extends StatelessWidget {
  const _DirectionMetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF278C6C), Color(0xFF074C39)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB9D7CA), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B4D3A).withValues(alpha: 0.17),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.64),
                width: 1.4,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: value,
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
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

class _QiblaStateView extends StatelessWidget {
  const _QiblaStateView({
    required this.icon,
    required this.title,
    required this.message,
    this.showProgress = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool showProgress;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F8F3),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD3E3DC)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B4D3A).withValues(alpha: 0.10),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF52B89D), Color(0xFF0B4D3A)],
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0B4D3A),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF66736E),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (showProgress) ...[
                  const SizedBox(height: 22),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Color(0xFF1C7459),
                      strokeWidth: 3,
                    ),
                  ),
                ],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1C7459),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the static compass face. Sensor and Qibla calculations are handled
/// exclusively by [QiblaController].
class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final bounds = Rect.fromCircle(center: center, radius: radius);

    final facePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF176449), Color(0xFF083D2F)],
        stops: [0, 1],
      ).createShader(bounds);
    canvas.drawCircle(center, radius, facePaint);

    final patternPaint = Paint()
      ..color = const Color(0xFF72B8A1).withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < 16; i++) {
      final angle = i * math.pi / 8;
      final inner = Offset(
        center.dx + radius * 0.12 * math.cos(angle),
        center.dy + radius * 0.12 * math.sin(angle),
      );
      final outer = Offset(
        center.dx + radius * 0.55 * math.cos(angle + math.pi / 8),
        center.dy + radius * 0.55 * math.sin(angle + math.pi / 8),
      );
      canvas.drawLine(inner, outer, patternPaint);
    }
    canvas.drawCircle(center, radius * 0.42, patternPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFFF7FAF7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.095;
    canvas.drawCircle(center, radius - radius * 0.075, ringPaint);

    final edgePaint = Paint()
      ..color = const Color(0xFF238364)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius - radius * 0.13, edgePaint);

    for (int degree = 0; degree < 360; degree += 5) {
      final radians = degree * math.pi / 180;
      final isMajor = degree % 30 == 0;
      final isMedium = degree % 10 == 0;
      final outerRadius = radius - radius * 0.032;
      final tickLength = isMajor
          ? radius * 0.085
          : isMedium
              ? radius * 0.058
              : radius * 0.032;
      final startRadius = outerRadius - tickLength;
      final tickPaint = Paint()
        ..color = isMajor
            ? const Color(0xFF0B5A43)
            : const Color(0xFF60877A)
        ..strokeWidth = isMajor
            ? 2.6
            : isMedium
                ? 1.5
                : 0.8
        ..strokeCap = StrokeCap.round;

      final start = Offset(
        center.dx + startRadius * math.sin(radians),
        center.dy - startRadius * math.cos(radians),
      );
      final end = Offset(
        center.dx + outerRadius * math.sin(radians),
        center.dy - outerRadius * math.cos(radians),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    _drawDirectionText(canvas, center, radius, 'N', 0);
    _drawDirectionText(canvas, center, radius, 'E', 90);
    _drawDirectionText(canvas, center, radius, 'S', 180);
    _drawDirectionText(canvas, center, radius, 'W', 270);
  }

  void _drawDirectionText(
    Canvas canvas,
    Offset center,
    double radius,
    String text,
    int angle,
  ) {
    final radians = angle * math.pi / 180;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xD9FFFFFF),
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final textRadius = radius * 0.70;
    final offset = Offset(
      center.dx + textRadius * math.sin(radians) - textPainter.width / 2,
      center.dy - textRadius * math.cos(radians) - textPainter.height / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints the device-heading needle only; its rotation remains controller-led.
class NeedlePainter extends CustomPainter {
  const NeedlePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final northPaint = Paint()..color = color;
    final northPath = Path()
      ..moveTo(centerX, 0)
      ..lineTo(size.width, centerY)
      ..lineTo(centerX, centerY - 4)
      ..lineTo(0, centerY)
      ..close();
    canvas.drawPath(northPath, northPaint);

    final southPaint = Paint()..color = const Color(0xFF9E2F2B);
    final southPath = Path()
      ..moveTo(centerX, size.height)
      ..lineTo(0, centerY)
      ..lineTo(centerX, centerY + 4)
      ..lineTo(size.width, centerY)
      ..close();
    canvas.drawPath(southPath, southPaint);
  }

  @override
  bool shouldRepaint(covariant NeedlePainter oldDelegate) =>
      oldDelegate.color != color;
}
