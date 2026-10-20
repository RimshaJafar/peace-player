import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PSearchContainer extends StatelessWidget {
  const PSearchContainer({
    super.key,
    required this.text,
    this.icon = Iconsax.search_normal,
    this.showBackground = true,
    this.showBorder = true,
    this.padding = const EdgeInsets.symmetric(horizontal: PSizes.defaultSpace),
  });
  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        width: PDeviceUtils.getScreenWidth(context),
        padding: EdgeInsets.all(PSizes.md),
        decoration: BoxDecoration(
            color: showBackground ? PColors.light : Colors.transparent,
            borderRadius: BorderRadius.circular(PSizes.cardRadiusLg),
            border: showBorder ? Border.all(color: PColors.darkGrey) : null),
        child: Row(
          children: [
            Icon(
              icon,
              color: PColors.darkGrey,
            ),
            SizedBox(
              width: PSizes.spaceBtwItems,
            ),
            Text(text, style: Theme.of(context).textTheme.bodySmall)
          ],
        ),
      ),
    );
  }
}
