import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class PRoundedContainer extends StatelessWidget {
  const PRoundedContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.showBorder = false,
    this.radius = PSizes.cardRadiusLg,
    this.backgroundColor = PColors.white,
    this.borderColor = PColors.borderPrimary,
  });

  final double? width;
  final double? height;
  final Widget? child;
  final bool showBorder;
  final double radius;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: showBorder ? Border.all(color: borderColor) : null,
      ),
      // BoxDecoration
      child: child,
    );
  }}