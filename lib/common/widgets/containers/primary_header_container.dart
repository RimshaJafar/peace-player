import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
// import 'package:ecommerce_app/common/widgets/shapes/containers/circular_container.dart';
import 'package:ecommerce_app/common/widgets/shapes/curved_edges_widget.dart';
// import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
// import 'package:ecommerce_app/utils/constants/sizes.dart';

// class PPrimaryHeaderContainer extends StatelessWidget {
//   const PPrimaryHeaderContainer({super.key, required this.child});
//   final Widget child;
//   @override
//   Widget build(BuildContext context) {
//     return PCurvedEdgeWidget(
//       child: Container(
//         color: PColors.primary,
//         padding: const EdgeInsets.all(0),
//         child: Stack(
//           children: [
//             Positioned(
//               top: -150,
//               right: -250,
//               child: PCircularContainer(
//                 backgroundColor:
//                     PColors.textWhite.withAlpha((0.1 * 255).toInt()),
//                 margin: EdgeInsets.all(10),
//               ),
//             ),
//             Positioned(
//               top: 100,
//               right: -300,
//               child: PCircularContainer(
//                 backgroundColor:
//                     PColors.textWhite.withAlpha((0.1 * 255).toInt()),
//                 margin: EdgeInsets.all(10),
//               ),
//             ),
//             child,
//           ],
//         ), // SizedBox
//       ),
//     );
//   }
// }

class PrimaryHeaderContainer extends StatelessWidget {
  const PrimaryHeaderContainer({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return CurvedEdgeWidget(
      child: Container(
        height: PSizes.homeHeaderHeight(context),
        decoration: BoxDecoration(
          gradient: PColors.linearGradient,
        ),
        child: child,
      ),
    );
  }
}
