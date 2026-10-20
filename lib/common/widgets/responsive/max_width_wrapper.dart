import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class MaxWidthWrapper extends StatelessWidget {
  const MaxWidthWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? PSizes.maxContentWidth(context);
    final paddedChild = Padding(
      padding: padding,
      child: child,
    );

    if (effectiveMaxWidth.isInfinite) {
      return paddedChild;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: paddedChild,
      ),
    );
  }
}
