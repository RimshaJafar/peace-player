import 'package:ecommerce_app/features/onboarding/controllers/onborading_controller.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final size = MediaQuery.sizeOf(context);

    return Positioned(
      bottom: size.height < 720 ? 46 : 68,
      left: size.width < 380 ? 34 : 50,
      child: SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        count: 3,
        effect: const ExpandingDotsEffect(
          activeDotColor: Color(0xFF329070),
          dotColor: Color(0xFFBFC5C8),
          dotHeight: 7,
          dotWidth: 20,
          spacing: 11,
          expansionFactor: 2.65,
        ),
      ),
    );
  }
}
