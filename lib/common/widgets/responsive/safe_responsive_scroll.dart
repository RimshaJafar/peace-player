import 'package:ecommerce_app/common/widgets/responsive/max_width_wrapper.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class SafeResponsiveScroll extends StatelessWidget {
  const SafeResponsiveScroll({
    super.key,
    required this.child,
    this.padding,
    this.controller,
    this.physics,
    this.maxWidth,
    this.safeArea = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final double? maxWidth;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final keyboardBottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final effectivePadding = (padding ??
            EdgeInsets.symmetric(
              horizontal: PSizes.pagePadding(context),
              vertical: PSizes.md,
            ))
        .add(EdgeInsets.only(bottom: keyboardBottomInset));

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final minHeight =
            constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;

        return SingleChildScrollView(
          controller: controller,
          physics: physics,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: MaxWidthWrapper(
              maxWidth: maxWidth,
              padding: effectivePadding,
              child: child,
            ),
          ),
        );
      },
    );

    return safeArea ? SafeArea(child: content) : content;
  }
}
