import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class PCircularImage extends StatelessWidget {
  const PCircularImage({
    super.key,
    this.fit = BoxFit.cover,
    required this.image,
    this.isNetworkImage = false,
    required this.overlayColor,
    this.backgroundColor,
    this.height = 30,
    this.padding = PSizes.sm,
    this.width = 30,
  });

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overlayColor;
  final Color? backgroundColor;
  final double width, height, padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black,
        borderRadius: BorderRadius.circular(90),
        image: DecorationImage(
          image: isNetworkImage
              ? NetworkImage(image) // For network image
              : AssetImage(image) as ImageProvider, // For asset image
          fit: fit ?? BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          color: overlayColor,
        ),
      ),
    );
  }
}
