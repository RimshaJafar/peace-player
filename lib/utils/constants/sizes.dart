import 'package:flutter/material.dart';

class PSizes {
  // Paddding and Margin Sizes
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  // Icon Sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  // Font Sizes
  static const double fontSizeSm = 14.0;
  static const double fontSizeMd = 16.0;
  static const double fontSizeLg = 18.0;
  // Button Sizes
  static const double buttonHeight = 18.0;
  static const double buttonRadius = 12.0;
  static const double buttonWidth = 120.0;
  static const double buttonElevation = 4.0;
  // AppBar Height
  static const double appBarHeight = 56.0;
  // Image Sizes
  static const double imageThumbSize = 80.0;
  // Default Spacing Between Sections
  static const double defaultSpace = 24.0;
  static const double spaceBtwItems = 16.0;
  static const double spaceBtwSections = 32.0;
  // Border Radius
  static const double borderRadiusSm = 4.0;
  static const double borderRadiusMd = 8.0;
  static const double borderRadiusLg = 12.0;
  // Divider Height
  static const double dividerHeight = 1.0;
  // Product Item Dimensions
  static const double productImageSize = 120.0;
  static const double productImageRadius = 16.0;
  static const double productItemHeight = 160.0;
  // Input Field
  static const double inputFieldRadius = 12.0;
  static const double spaceBtwInputField = 16.0;
  // Card Sizes
  static const double cardElevation = 2.0;
  static const double cardRadiusXs = 6.0;
  static const double cardRadiusSm = 10.0;
  static const double cardRadiusMd = 12.0;
  static const double cardRadiusLg = 16.0;
  // Image Carousel Height
  static const double imageCarouselHeight = 200.0;
  // Loading Indicator Size
  static const double loadingIndicatorSize = 36.0;
  // Grid View Spacing
  static const double gridViewSpacing = 16.0;

  static Size screen(BuildContext context) => MediaQuery.sizeOf(context);

  static double screenWidth(BuildContext context) => screen(context).width;

  static double screenHeight(BuildContext context) => screen(context).height;

  static bool isSmallPhone(BuildContext context) => screenWidth(context) < 360;

  static bool isCompactHeight(BuildContext context) =>
      screenHeight(context) < 700;

  static bool isTablet(BuildContext context) =>
      screen(context).shortestSide >= 600;

  static double pagePadding(BuildContext context) {
    if (isTablet(context)) return 32.0;
    if (isSmallPhone(context)) return 16.0;
    return 24.0;
  }

  static double compactSpace(
    BuildContext context,
    double normal,
    double compact,
  ) {
    return isSmallPhone(context) || isCompactHeight(context) ? compact : normal;
  }

  static double homeHeaderHeight(BuildContext context) {
    if (isCompactHeight(context)) return 370.0;
    if (isSmallPhone(context)) return 392.0;
    return 416.0;
  }

  static double kidsHeroHeight(BuildContext context) {
    if (isCompactHeight(context)) return 190.0;
    if (isSmallPhone(context)) return 215.0;
    return 250.0;
  }

  static double kidsCardIconSize(BuildContext context) {
    if (isCompactHeight(context)) return 46.0;
    if (isSmallPhone(context)) return 52.0;
    return 60.0;
  }

  static double quizButtonSize(BuildContext context) {
    if (isCompactHeight(context)) return 50.0;
    if (isSmallPhone(context)) return 54.0;
    return 62.0;
  }

  static double scannerFrameSize(BuildContext context) {
    final widthBased = screenWidth(context) * 0.78;
    final heightBased =
        screenHeight(context) * (isCompactHeight(context) ? 0.36 : 0.42);
    final frame = widthBased < heightBased ? widthBased : heightBased;
    final minFrame = isSmallPhone(context) ? 210.0 : 240.0;
    return frame.clamp(minFrame, 340.0).toDouble();
  }

  static int adaptiveGridCount(BuildContext context) {
    final width = screenWidth(context);
    if (width >= 900) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static double maxContentWidth(BuildContext context) {
    return isTablet(context) ? 720.0 : double.infinity;
  }
}
