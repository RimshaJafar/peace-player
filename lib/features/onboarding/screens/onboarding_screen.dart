import 'package:ecommerce_app/features/onboarding/controllers/onborading_controller.dart';
import 'package:ecommerce_app/common/widgets/onboarding/onboarding_dot_navigation.dart';
import 'package:ecommerce_app/common/widgets/onboarding/onboarding_next_button.dart';
import 'package:ecommerce_app/common/widgets/onboarding/onboarding_page.dart';
import 'package:ecommerce_app/common/widgets/onboarding/onboarding_skip.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    return Scaffold(
      backgroundColor: const Color(0xFFEFF7F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C5D4E).withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    PImages.mosqueBackground,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.02),
                          Colors.white.withValues(alpha: 0.42),
                          Colors.white.withValues(alpha: 0.08),
                        ],
                        stops: const [0, 0.62, 1],
                      ),
                    ),
                  ),
                  PageView(
                    controller: controller.pageController,
                    onPageChanged: controller.updatePageIndicator,
                    children: const [
                      OnBoardingPage(
                        image: PImages.onBoardingImage1,
                        title: PTexts.onBoardingTitle1,
                        subTitle: PTexts.onBoardingSubTitle1,
                      ),
                      OnBoardingPage(
                        image: PImages.onBoardingImage2,
                        title: PTexts.onBoardingTitle2,
                        subTitle: PTexts.onBoardingSubTitle2,
                      ),
                      OnBoardingPage(
                        image: PImages.onBoardingImage3,
                        title: PTexts.onBoardingTitle3,
                        subTitle: PTexts.onBoardingSubTitle3,
                      ),
                    ],
                  ),
                  const OnBoeardingSkip(),
                  const OnBoardingDotNavigation(),
                  const OnBoardingNextButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
