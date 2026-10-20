import 'dart:math' as math;

import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/seerah_nabwi/controllers/seerah_nabwi_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';

class LineageTreeScreen extends StatefulWidget {
  const LineageTreeScreen({super.key});

  @override
  State<LineageTreeScreen> createState() => _LineageTreeScreenState();
}

class _LineageTreeScreenState extends State<LineageTreeScreen> {
  final SeerahNabwiController controller = Get.put(SeerahNabwiController());
  static const String _mainTag = 'lineage';
  static const String _subTag = 'none';

  // Track which index has expanded description
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    controller.fetchSeerahFeatures(mainTag: _mainTag, subTag: _subTag);
  }

  void _toggleDescription(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final isUrdu = textLanguageCode == 'ur';
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Lineage Tree',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: GetBuilder<SeerahNabwiController>(
        builder: (seerahController) {
          final key = '${_mainTag}_$_subTag';
          final isLoading = seerahController.isFeatureLoading(key);
          final items = seerahController.getFeatureItems(key);

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (items.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          // Build lineage data from API response
          final lineageData = items.map((item) {
            return {
              'name': AppLanguageHelper.pickText(item.title, titleLanguageCode),
              'description':
                  AppLanguageHelper.pickText(item.text, textLanguageCode),
            };
          }).toList();

          return InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 2.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildZigzagTree(lineageData, isUrdu),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildZigzagTree(
      List<Map<String, String>> lineageData, bool isUrdu) {
    final List<Widget> widgets = [];

    for (int i = 0; i < lineageData.length; i++) {
      final data = lineageData[i];
      final isRoot = i == 0;
      final isLeft = i.isEven; // Zigzag: even = left, odd = right
      final isExpanded = _expandedIndex == i;

      // Add the name node with zigzag alignment
      widgets.add(
        _ZigzagNameNode(
          name: data['name']!,
          isRoot: isRoot,
          isLeft: isLeft,
          isUrdu: isUrdu,
          onTap: () => _toggleDescription(i),
        ),
      );

      // If this node is expanded, show the description box
      if (isExpanded) {
        // Connector from node position to center (curved for non-root, straight for root)
        if (isRoot) {
          widgets.add(_buildCenterConnectorLine());
        } else {
          widgets.add(_buildSideToCenterConnectorLine(isLeft));
        }
        widgets.add(
          _DescriptionBox(
            name: data['name']!,
            description: data['description']!,
            isLeft: isLeft,
            isUrdu: isUrdu,
          ),
        );
        // Only add bottom connector if there's a next node to connect to
        if (i < lineageData.length - 1) {
          widgets.add(_buildCenterConnectorLine());
        }
      }

      // Add connector line to next node (if not last)
      if (i < lineageData.length - 1) {
        final nextIsLeft = (i + 1).isEven;
        // Start from center if root OR if node is expanded (description box is centered)
        final startFromCenter = isRoot || isExpanded;
        widgets.add(
          _ZigzagConnector(
            fromLeft: isLeft,
            toLeft: nextIsLeft,
            hasExpandedBox: isExpanded,
            fromCenter: startFromCenter,
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildSideToCenterConnectorLine(bool isLeft) {
    return SizedBox(
      height: 30,
      child: CustomPaint(
        size: const Size(double.infinity, 30),
        painter: _SideToCenterLinePainter(
          isLeft: isLeft,
          color: const Color(0xFF2E8B57),
        ),
      ),
    );
  }

  Widget _buildCenterConnectorLine() {
    return SizedBox(
      height: 25,
      child: CustomPaint(
        size: const Size(double.infinity, 25),
        painter: _CenterLinePainter(
          color: const Color(0xFF2E8B57),
        ),
      ),
    );
  }
}

class _ZigzagNameNode extends StatelessWidget {
  const _ZigzagNameNode({
    required this.name,
    required this.isRoot,
    required this.isLeft,
    required this.isUrdu,
    this.onTap,
  });

  final String name;
  final bool isRoot;
  final bool isLeft;
  final bool isUrdu;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double size = isRoot ? 124 : 84;

    // First name (Prophet) is centered at top
    if (isRoot) {
      return Center(
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1B5E4A),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                name,
                textAlign: TextAlign.center,
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                style: isUrdu
                    ? GoogleFonts.notoNastaliqUrdu(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      )
                    : GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isLeft) const Spacer(flex: 5),
        if (isLeft) const Spacer(flex: 1),
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _DashedCirclePainter(
                color: Colors.grey.shade400,
                strokeWidth: 2,
                dashLength: 6,
                gapLength: 4,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                  style: isUrdu
                      ? GoogleFonts.notoNastaliqUrdu(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        )
                      : GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                ),
              ),
            ),
          ),
        ),
        if (isLeft) const Spacer(flex: 5),
        if (!isLeft) const Spacer(flex: 1),
      ],
    );
  }
}

class _DescriptionBox extends StatelessWidget {
  const _DescriptionBox({
    required this.name,
    required this.description,
    required this.isLeft,
    required this.isUrdu,
  });

  final String name;
  final String description;
  final bool isLeft;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // 90% width
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1B5E4A),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              style: isUrdu
                  ? GoogleFonts.notoNastaliqUrdu(
                      color: const Color(0xFF1B5E4A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )
                  : GoogleFonts.poppins(
                      color: const Color(0xFF1B5E4A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              style: isUrdu
                  ? GoogleFonts.notoNastaliqUrdu(
                      color: const Color(0xFF1B5E4A).withValues(alpha: 0.8),
                      fontSize: 16,
                      height: 1.6,
                    )
                  : GoogleFonts.poppins(
                      color: const Color(0xFF1B5E4A).withValues(alpha: 0.8),
                      fontSize: 15,
                      height: 1.5,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZigzagConnector extends StatelessWidget {
  const _ZigzagConnector({
    required this.fromLeft,
    required this.toLeft,
    this.hasExpandedBox = false,
    this.fromCenter = false,
  });

  final bool fromLeft;
  final bool toLeft;
  final bool hasExpandedBox;
  final bool fromCenter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: CustomPaint(
        size: const Size(double.infinity, 50),
        painter: _ZigzagLinePainter(
          fromLeft: fromLeft,
          toLeft: toLeft,
          fromCenter: fromCenter,
          color: const Color(0xFF2E8B57),
        ),
      ),
    );
  }
}

class _ZigzagLinePainter extends CustomPainter {
  _ZigzagLinePainter({
    required this.fromLeft,
    required this.toLeft,
    required this.color,
    this.fromCenter = false,
  });

  final bool fromLeft;
  final bool toLeft;
  final Color color;
  final bool fromCenter;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final offsetAmount = size.width * 0.28;

    // If fromCenter, start from center, otherwise use zigzag offset
    final startX = fromCenter
        ? centerX
        : (fromLeft ? centerX - offsetAmount : centerX + offsetAmount);
    final endX = toLeft ? centerX - offsetAmount : centerX + offsetAmount;

    final path = Path();
    path.moveTo(startX, 0);

    // Use cubic bezier curve for smooth S-curve
    final controlPoint1X = startX;
    final controlPoint1Y = size.height * 0.6;
    final controlPoint2X = endX;
    final controlPoint2Y = size.height * 0.4;

    path.cubicTo(
      controlPoint1X,
      controlPoint1Y,
      controlPoint2X,
      controlPoint2Y,
      endX,
      size.height,
    );

    canvas.drawPath(path, paint);

    // Calculate tangent angle at the end of the bezier curve
    // Derivative at t=1: tangent = 3*(P3 - P2)
    final tangentX = endX - controlPoint2X;
    final tangentY = size.height - controlPoint2Y;
    final angle = math.atan2(tangentY, tangentX);

    // Draw arrow rotated to follow curve direction
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(endX, size.height);
    canvas.rotate(angle - math.pi / 2);

    final arrowPath = Path();
    arrowPath.moveTo(0, 0);
    arrowPath.lineTo(-6, -10);
    arrowPath.lineTo(6, -10);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SideToCenterLinePainter extends CustomPainter {
  _SideToCenterLinePainter({
    required this.isLeft,
    required this.color,
  });

  final bool isLeft;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final offsetAmount = size.width * 0.28;
    final startX = isLeft ? centerX - offsetAmount : centerX + offsetAmount;

    final path = Path();
    path.moveTo(startX, 0);
    path.cubicTo(
      startX,
      size.height * 0.6,
      centerX,
      size.height * 0.4,
      centerX,
      size.height,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CenterLinePainter extends CustomPainter {
  _CenterLinePainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;

    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    this.dashLength = 6,
    this.gapLength = 4,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final radius = (size.width / 2) - (strokeWidth / 2);
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * (dashLength + gapLength) / radius;
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2), radius: radius),
        startAngle,
        dashLength / radius,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
