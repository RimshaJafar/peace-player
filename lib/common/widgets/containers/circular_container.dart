import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

// class PCircularContainer extends StatelessWidget {
//   const PCircularContainer({
//     super.key,
//     this.width = 20,
//     this.height = 20,
//     this.radius = 10, // Adjusted to prevent large radius issues
//     this.padding = 0,
//     this.child,
//     this.backgroundColor = PColors.white, // Use provided color
//     this.margin = EdgeInsets.zero, // Provide a default margin
//   });

//   final double? width;
//   final double? height;
//   final double radius;
//   final double padding;
//   final Widget? child;
//   final Color backgroundColor;
//   final EdgeInsets margin;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: height,
//       margin: margin,
//       padding: EdgeInsets.all(padding),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(radius),
//         color: backgroundColor, // Apply background color correctly
//       ),
//       child: child,
//     );
//   }
// }


class PCircularContainer extends StatelessWidget {
  const PCircularContainer({
    super.key,
    this.child,
    this.width = 400,
    this.height = 400,
    this.radius = 400,
    this.padding = 0,
    this.margin,
    this.backgroundColor = PColors.white,
  });

  final double? width;
  final double? height;
  final double? radius;
  final double padding;
  final Widget? child;
  final Color backgroundColor;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 0),
        color: backgroundColor,
      ),
      child: child,
    );
  }
}