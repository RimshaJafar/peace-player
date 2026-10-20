import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class PGridLayout extends StatelessWidget {
  const PGridLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.mainAxisExtent = 288,
  });

  final int itemCount;
  final double? mainAxisExtent;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: PSizes.adaptiveGridCount(context),
        mainAxisExtent: mainAxisExtent,
        mainAxisSpacing: PSizes.gridViewSpacing,
        crossAxisSpacing: PSizes.gridViewSpacing,
      ), // SliverGridDelegateWithFixedCrossAxisCount
      itemBuilder: itemBuilder,
    ); // GridView.builder
  }
}
