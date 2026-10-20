import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/boycott/controllers/scanner_controller.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';

class ScannerProcessingScreen extends StatefulWidget {
  const ScannerProcessingScreen({Key? key}) : super(key: key);

  @override
  State<ScannerProcessingScreen> createState() =>
      _ScannerProcessingScreenState();
}

class _ScannerProcessingScreenState extends State<ScannerProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late ScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = Get.find<ScannerController>();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1628),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
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
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = PSizes.isCompactHeight(context);
                  final loaderSize = compact ? 104.0 : 120.0;
                  final innerLoaderSize = compact ? 82.0 : 96.0;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: PSizes.compactSpace(context, 28.0, 20.0),
                          vertical: compact ? 24 : 36,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Rotating AI loader
                            SizedBox(
                              width: loaderSize,
                              height: loaderSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer rotating ring
                                  RotationTransition(
                                    turns: _rotateController,
                                    child: Container(
                                      width: loaderSize,
                                      height: loaderSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: SweepGradient(
                                          colors: [
                                            const Color(0xFF329070)
                                                .withOpacity(0),
                                            const Color(0xFF329070),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Inner circle
                                  Container(
                                    width: innerLoaderSize,
                                    height: innerLoaderSize,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0D2137),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      color: Color(0xFF60BEA8),
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: compact ? 24 : 32),

                            // Title
                            const Text(
                              'AI Analysis in Progress',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Our AI is analyzing your product for ethical insights',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),

                            SizedBox(height: compact ? 28 : 48),

                            // Processing steps
                            Obx(() {
                              final currentStep = _scannerController
                                  .currentProcessingStep.value;
                              return Column(
                                children: List.generate(
                                  ScannerController.processingSteps.length,
                                  (index) => _buildStepTile(
                                    index: index,
                                    label: ScannerController
                                        .processingSteps[index],
                                    currentStep: currentStep,
                                  ),
                                ),
                              );
                            }),

                            SizedBox(height: compact ? 24 : 40),

                            // Bottom hint
                            Text(
                              'Please wait while we process your scan...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: compact ? 12 : 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepTile({
    required int index,
    required String label,
    required int currentStep,
  }) {
    final isDone = index < currentStep;
    final isActive = index == currentStep;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF329070).withOpacity(0.15)
              : isDone
                  ? Colors.white.withOpacity(0.04)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF329070).withOpacity(0.6)
                : isDone
                    ? const Color(0xFF329070).withOpacity(0.25)
                    : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Step indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFF329070)
                    : isActive
                        ? const Color(0xFF329070).withOpacity(0.2)
                        : Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF329070)
                      : isDone
                          ? const Color(0xFF329070)
                          : Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : isActive
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF60BEA8),
                              ),
                            ),
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 14),
            // Step label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDone
                      ? Colors.white.withOpacity(0.7)
                      : isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            // Status badge
            if (isDone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF329070).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Color(0xFF60BEA8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF329070).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Color(0xFF60BEA8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
