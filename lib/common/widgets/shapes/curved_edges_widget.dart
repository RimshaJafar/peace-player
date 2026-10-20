import 'package:ecommerce_app/common/widgets/shapes/curved_edges.dart';
import 'package:flutter/material.dart';

// class PCurvedEdgeWidget extends StatelessWidget {
//   const PCurvedEdgeWidget({super.key, this.child});
//   final Widget? child;

//   @override
//   Widget build(BuildContext context) {
//     return ClipPath(clipper: PCustomCurvedEdges(), child: child // Container
//         );
//   }
// }


class CurvedEdgeWidget extends StatelessWidget {
  const CurvedEdgeWidget({super.key, this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurvedEdges(),
      child: child,
    );
  }
}