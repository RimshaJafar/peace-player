import 'package:ecommerce_app/features/onboarding/controllers/onborading_controller.dart';
import 'package:flutter/material.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final size = MediaQuery.sizeOf(context);
    final diameter = size.width < 380 ? 64.0 : 76.0;

    return Positioned(
      right: size.width < 380 ? 22 : 32,
      bottom: size.height < 720 ? 18 : 28,
      child: GestureDetector(
        onTap: () => controller.nextPage(),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF60BEA8),
                Color(0xFF329070),
                Color(0xFF1C5D4E),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C5D4E).withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: diameter * 0.36,
              height: diameter * 0.36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: diameter * 0.30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
