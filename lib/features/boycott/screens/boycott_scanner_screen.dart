import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/boycott/controllers/scanner_controller.dart';
import 'package:ecommerce_app/features/boycott/screens/scanned_products_history_screen.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/widgets/billing_usage_button.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';

class BoycottScannerScreen extends StatefulWidget {
  const BoycottScannerScreen({super.key});

  @override
  State<BoycottScannerScreen> createState() => _BoycottScannerScreenState();
}

class _BoycottScannerScreenState extends State<BoycottScannerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  late ScannerController _scannerController;
  String _firebaseUserId = '';

  @override
  void initState() {
    super.initState();

    // Get or create scanner controller — permanent so it survives
    // navigation to ScannerProcessingScreen and ScannerResultScreen
    if (Get.isRegistered<ScannerController>()) {
      _scannerController = Get.find<ScannerController>();
    } else {
      _scannerController = Get.put(ScannerController(), permanent: true);
    }
    _scannerController.reset();

    // Get user ID
    try {
      final userController = Get.find<UserController>();
      _firebaseUserId = userController.user.value.id ?? '';
    } catch (_) {}

    // Pulse animation for scan frame
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Glow animation for border
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onScanFromCamera() {
    if (_firebaseUserId.isEmpty) {
      PLoaders.warningSnackBar(
        title: 'Login Required',
        message: 'Please log in to use the scanner.',
        context: context,
      );
      return;
    }
    _scannerController.captureFromCamera(_firebaseUserId);
  }

  void _onScanFromGallery() {
    if (_firebaseUserId.isEmpty) {
      PLoaders.warningSnackBar(
        title: 'Login Required',
        message: 'Please log in to use the scanner.',
        context: context,
      );
      return;
    }
    _scannerController.captureFromGallery(_firebaseUserId);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          // Dark gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1628),
                  Color(0xFF0D2137),
                  Color(0xFF0A1628),
                ],
              ),
            ),
          ),

          // Subtle grid pattern overlay
          CustomPaint(
            size: Size(size.width, size.height),
            painter: _GridPainter(),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = PSizes.isCompactHeight(context);
                final frameSize = PSizes.scannerFrameSize(context);
                final scanAreaHeight = frameSize + (compact ? 18.0 : 48.0);
                final buttonHeight = compact ? 52.0 : 56.0;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        // Top bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Back button
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Title
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'AI Scanner',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      'Ethical Product Analysis',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const BillingUsageButton(
                                featureKey: BillingFeatureKeys.boycottScanner,
                                featureLabel: 'AI Product Scanner',
                                unitLabel: 'scans',
                              ),
                              const SizedBox(width: 8),
                              // History button
                              GestureDetector(
                                onTap: () => Get.to(
                                    () => const ScannedProductsHistoryScreen()),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.history,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: compact ? 8 : 20),

                        // AI branding badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF329070), Color(0xFF1C5D4E)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF329070).withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'Powered by AI Vision',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: compact ? 18 : 32),

                        // Scanner frame area
                        SizedBox(
                          height: scanAreaHeight,
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: child,
                                );
                              },
                              child: AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: frameSize,
                                    height: frameSize,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF329070)
                                              .withOpacity(
                                                  _glowAnimation.value * 0.5),
                                          blurRadius: 30,
                                          spreadRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: child,
                                  );
                                },
                                child: Stack(
                                  children: [
                                    // Main frame
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.04),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: const Color(0xFF329070)
                                              .withOpacity(0.7),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Scan icon
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF329070)
                                                    .withOpacity(0.15),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(0xFF329070)
                                                      .withOpacity(0.5),
                                                  width: 2,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.document_scanner_outlined,
                                                color: Color(0xFF60BEA8),
                                                size: 38,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              'Align Product Here',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Take a photo or choose from gallery',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Corner decorations
                                    ..._buildCornerDecorations(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: compact ? 14 : 24),

                        // Scan tips
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 20,
                            runSpacing: 10,
                            children: [
                              _buildTip(
                                  Icons.light_mode_outlined, 'Good lighting'),
                              _buildTip(Icons.center_focus_strong_outlined,
                                  'Center product'),
                              _buildTip(Icons.text_fields, 'Show label'),
                            ],
                          ),
                        ),

                        SizedBox(height: compact ? 20 : 32),

                        // Action buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              // Camera button (primary)
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: ElevatedButton.icon(
                                  onPressed: _onScanFromCamera,
                                  icon: const Icon(Icons.camera_alt_outlined,
                                      size: 22),
                                  label: const Text(
                                    'Scan with Camera',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF329070),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Gallery button (secondary)
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: OutlinedButton.icon(
                                  onPressed: _onScanFromGallery,
                                  icon: const Icon(Icons.photo_library_outlined,
                                      size: 22),
                                  label: const Text(
                                    'Choose from Gallery',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF60BEA8),
                                    side: const BorderSide(
                                      color: Color(0xFF329070),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: compact ? 20 : 32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerDecorations() {
    const color = Color(0xFF60BEA8);
    const size = 24.0;
    const thickness = 3.0;

    return [
      // Top-left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
            borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24)),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
          ),
        ),
      ),
    ];
  }

  Widget _buildTip(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF60BEA8), size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for subtle grid background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
