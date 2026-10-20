import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ecommerce_app/features/lifeevents/screens/eidain_screen.dart';
import 'package:ecommerce_app/features/lifeevents/screens/funneral_screen.dart';
import 'package:ecommerce_app/features/lifeevents/screens/jummah_screen.dart';
import 'package:ecommerce_app/features/lifeevents/screens/marriage_screen.dart';
import 'package:ecommerce_app/features/lifeevents/screens/Pilgrimage_guidance_screen.dart';

class RotatingFabMenu extends StatefulWidget {
  const RotatingFabMenu({super.key});

  @override
  State<RotatingFabMenu> createState() => _RotatingFabMenuState();
}

class _RotatingFabMenuState extends State<RotatingFabMenu>
    with TickerProviderStateMixin {
  bool _open = false;
  double _rotation = 0;
  Offset? _lastPanPosition;

  late AnimationController _menuController;
  late AnimationController _fabRotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fabRotationAnimation;

  final List<_FabItem> _items = [
    _FabItem(
      label: 'Funeral',
      asset: 'assets/icons/funeral.png',
      builder: (_) => const FuneralScreen(),
    ),
    _FabItem(
      label: 'Marriage',
      asset: 'assets/icons/marriage.png',
      builder: (_) => const MarriageScreen(),
    ),
    _FabItem(
      label: 'Eid',
      asset: 'assets/icons/eid.png',
      builder: (_) => const EidainScreen(),
    ),
    _FabItem(
      label: 'Hajj',
      asset: 'assets/icons/hajj.png',
      builder: (_) => const PilgrimageGuidanceScreen(),
    ),
    _FabItem(
      label: 'Jumma',
      asset: 'assets/icons/jummah.png',
      builder: (_) => const JummahScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _menuController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fabRotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _menuController, curve: Curves.elasticOut),
    );

    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabRotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    _fabRotationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _menuController.forward();
      _fabRotationController.forward();
    } else {
      _menuController.reverse();
      _fabRotationController.reverse();
    }
  }

  void _updateRotation(double delta) {
    if (_open) {
      setState(() {
        _rotation += delta;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double outerRadius = 85;
    const double innerRadius = 40;
    const double mainFabSize = 70;
    const double iconSize = 32;
    const double containerSize = 220;
    const double extraPadding = 20;

    final double hitTestSize =
        _open ? containerSize + extraPadding : mainFabSize;

    return SizedBox(
      width: hitTestSize,
      height: hitTestSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Animated circular menu ring (rotatable) - using ScaleTransition for proper animation
          if (_open)
            ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.center,
              child: FadeTransition(
                opacity: _menuController,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final center = Offset(containerSize / 2, containerSize / 2);
                    final touchPoint = Offset(
                        details.localPosition.dx, details.localPosition.dy);

                    // Calculate distance from center
                    final vector = touchPoint - center;
                    final distance = vector.distance;

                    // Only allow rotation when dragging in the ring area (not center FAB)
                    // and with sufficient drag distance to avoid accidental rotation on taps
                    const minDistance = 50.0;
                    const maxDistance = 130.0;
                    const minDragThreshold = 5.0;

                    if (distance >= minDistance && distance <= maxDistance) {
                      // Check if this is actual dragging, not just a tap
                      _lastPanPosition ??= touchPoint;
                      final dragDistance =
                          (_lastPanPosition! - touchPoint).distance;

                      if (dragDistance > minDragThreshold) {
                        final angle = atan2(vector.dy, vector.dx);
                        _updateRotation(angle * 0.15);
                        _lastPanPosition = touchPoint;
                      }
                    }
                  },
                  onPanEnd: (_) {
                    _lastPanPosition = null;
                  },
                  child: _CircularMenuPainter(
                    outerRadius: outerRadius,
                    innerRadius: innerRadius,
                    itemCount: _items.length,
                    rotation: _rotation,
                    items: _items,
                    iconSize: iconSize,
                    closeMenu: () => setState(() {
                      _open = false;
                      _menuController.reverse();
                      _fabRotationController.reverse();
                    }),
                    scaleAnimation: _scaleAnimation,
                  ),
                ),
              ),
            ),
          // Enhanced FAB Button in center
          Center(
            child: SizedBox(
              width: mainFabSize,
              height: mainFabSize,
              child: _EnhancedFabButton(
                onPressed: _toggle,
                rotationAnimation: _fabRotationAnimation,
                isOpen: _open,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedFabButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Animation<double> rotationAnimation;
  final bool isOpen;

  const _EnhancedFabButton({
    required this.onPressed,
    required this.rotationAnimation,
    required this.isOpen,
  });

  @override
  State<_EnhancedFabButton> createState() => _EnhancedFabButtonState();
}

class _EnhancedFabButtonState extends State<_EnhancedFabButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onPressed() {
    _pressController.forward().then((_) {
      _pressController.reverse();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: AnimatedBuilder(
        animation: widget.rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: widget.rotationAnimation.value * 2 * pi,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing shadow glow
            AnimatedBuilder(
              animation: widget.rotationAnimation,
              builder: (context, child) {
                final scale = 1.0 + (widget.rotationAnimation.value * 0.3);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF329070).withValues(
                              alpha: 0.3 * widget.rotationAnimation.value),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Gradient background
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF329070),
                    const Color(0xFF1B5E49),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            // FAB button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _onPressed,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logos/fab_logo.png',
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularMenuPainter extends StatelessWidget {
  final double outerRadius;
  final double innerRadius;
  final int itemCount;
  final double rotation;
  final List<_FabItem> items;
  final double iconSize;
  final VoidCallback closeMenu;
  final Animation<double> scaleAnimation;

  const _CircularMenuPainter({
    required this.outerRadius,
    required this.innerRadius,
    required this.itemCount,
    required this.rotation,
    required this.items,
    required this.iconSize,
    required this.closeMenu,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final size = outerRadius * 2 + 30;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ring background + dividing lines
          CustomPaint(
            size: Size(size, size),
            painter: _MenuPainter(
              outerRadius: outerRadius,
              innerRadius: innerRadius,
              itemCount: itemCount,
              rotation: rotation,
              scaleAnimation: scaleAnimation.value,
            ),
          ),
          // Icons positioned on the ring with staggered animation
          for (int i = 0; i < itemCount; i++)
            _AnimatedCircleIcon(
              outerRadius: outerRadius,
              innerRadius: innerRadius,
              index: i,
              total: itemCount,
              rotation: rotation,
              item: items[i],
              iconSize: iconSize,
              containerSize: size,
              scaleAnimation: scaleAnimation,
              onTap: () {
                closeMenu();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: items[i].builder),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MenuPainter extends CustomPainter {
  final double outerRadius;
  final double innerRadius;
  final int itemCount;
  final double rotation;
  final double scaleAnimation;

  _MenuPainter({
    required this.outerRadius,
    required this.innerRadius,
    required this.itemCount,
    required this.rotation,
    required this.scaleAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFF329070).withValues(alpha: 0.15 * scaleAnimation)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius + 8, glowPaint);

    // Create glassmorphism ring with gradient overlay
    final ringPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outerRadius))
      ..addOval(Rect.fromCircle(center: center, radius: innerRadius))
      ..fillType = PathFillType.evenOdd;

    // Gradient background for the ring
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.92),
          Colors.white.withValues(alpha: 0.85),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: outerRadius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(ringPath, gradientPaint);

    // Outer gradient border with shadow effect
    const outlineWidth = 1.5;
    final outerBorderPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outerRadius));

    final outerBorderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF329070).withValues(alpha: 0.6),
          const Color(0xFF1B5E49).withValues(alpha: 0.4),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: outerRadius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth;

    canvas.drawPath(outerBorderPath, outerBorderPaint);

    // Inner gradient border
    final innerBorderPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: innerRadius));

    final innerBorderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFF329070).withValues(alpha: 0.4),
          const Color(0xFF1B5E49).withValues(alpha: 0.6),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: innerRadius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth;

    canvas.drawPath(innerBorderPath, innerBorderPaint);

    // Draw elegant gradient dividing lines
    final linePaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < itemCount; i++) {
      final angle = (2 * pi / itemCount) * i + (pi / itemCount) + rotation;

      final innerPoint = Offset(
        center.dx + cos(angle) * innerRadius,
        center.dy + sin(angle) * innerRadius,
      );
      final outerPoint = Offset(
        center.dx + cos(angle) * outerRadius,
        center.dy + sin(angle) * outerRadius,
      );

      // Gradient line effect
      linePaint.shader = LinearGradient(
        begin: Alignment(cos(angle), sin(angle)),
        end: Alignment(-cos(angle), -sin(angle)),
        colors: [
          const Color(0xFF329070).withValues(alpha: 0.2),
          const Color(0xFF329070).withValues(alpha: 0.5),
          const Color(0xFF329070).withValues(alpha: 0.2),
        ],
      ).createShader(
        Rect.fromPoints(innerPoint, outerPoint),
      );

      canvas.drawLine(innerPoint, outerPoint, linePaint);
    }
  }

  @override
  bool shouldRepaint(_MenuPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.scaleAnimation != scaleAnimation;
  }
}

class _AnimatedCircleIcon extends StatefulWidget {
  final double outerRadius;
  final double innerRadius;
  final int index;
  final int total;
  final double rotation;
  final _FabItem item;
  final double iconSize;
  final double containerSize;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;

  const _AnimatedCircleIcon({
    required this.outerRadius,
    required this.innerRadius,
    required this.index,
    required this.total,
    required this.rotation,
    required this.item,
    required this.iconSize,
    required this.containerSize,
    required this.scaleAnimation,
    required this.onTap,
  });

  @override
  State<_AnimatedCircleIcon> createState() => _AnimatedCircleIconState();
}

class _AnimatedCircleIconState extends State<_AnimatedCircleIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapScaleAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _tapScaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final angle = (2 * pi / widget.total) * widget.index + widget.rotation;
    final center = widget.containerSize / 2;
    final iconRadius = (widget.outerRadius + widget.innerRadius) / 2;

    // Calculate position on the ring
    final offset = Offset(
      center + cos(angle) * iconRadius,
      center + sin(angle) * iconRadius,
    );

    return Positioned(
      left: offset.dx - (widget.iconSize + 8) / 2,
      top: offset.dy - (widget.iconSize + 8) / 2,
      width: widget.iconSize + 8,
      height: widget.iconSize + 8,
      child: ScaleTransition(
        scale: widget.scaleAnimation,
        alignment: Alignment.center,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: _handleTap,
            child: ScaleTransition(
              scale: _tapScaleAnim,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Icon background circle with gradient
                  Container(
                    width: widget.iconSize + 8,
                    height: widget.iconSize + 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF329070)
                              .withValues(alpha: _isHovered ? 0.3 : 0.15),
                          const Color(0xFF1B5E49)
                              .withValues(alpha: _isHovered ? 0.25 : 0.1),
                        ],
                      ),
                    ),
                  ),
                  // Icon shadow
                  Icon(
                    Icons.circle,
                    size: widget.iconSize + 6,
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                  // Icon itself with ripple
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleTap,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: widget.iconSize,
                        height: widget.iconSize,
                        child: Image.asset(
                          widget.item.asset,
                          width: widget.iconSize,
                          height: widget.iconSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FabItem {
  final String label;
  final String asset;
  final WidgetBuilder builder;
  const _FabItem({
    required this.label,
    required this.asset,
    required this.builder,
  });
}
