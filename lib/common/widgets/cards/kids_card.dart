import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class KidsCard extends StatelessWidget {
  final Color cardColor;
  final String iconPath;
  final String text;
  final VoidCallback? onTap;

  const KidsCard({
    Key? key,
    required this.cardColor,
    required this.iconPath,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconSize = PSizes.kidsCardIconSize(context);
    final topPadding = PSizes.compactSpace(context, 15.0, 8.0);
    final itemGap = PSizes.compactSpace(context, 20.0, 12.0);
    final fontSize = PSizes.isSmallPhone(context) ? 16.0 : 18.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: Image.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                errorBuilder: (context, error, stack) => Icon(
                  Icons.image_not_supported,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: itemGap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
