import 'package:ecommerce_app/features/onboarding/controllers/onborading_controller.dart';
import 'package:flutter/material.dart';

class OnBoeardingSkip extends StatelessWidget {
  const OnBoeardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Positioned(
      top: 30,
      right: screenWidth < 380 ? 24 : 38,
      child: TextButton(
        onPressed: () => controller.skipPage(),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF258A67),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        child: const Text("Skip"),
      ),
    );
  }
}
