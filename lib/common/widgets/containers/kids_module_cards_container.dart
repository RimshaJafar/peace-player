import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class KidsModuleCardsContainer extends StatelessWidget {
  const KidsModuleCardsContainer({
    super.key,
    required this.child,
    this.gradientColors = const [
      Color(0xFFD5E5E9),
      Color(0xFFC1D6DC),
    ],
    this.borderColor = const Color(0xFF8EAEB6),
  });

  final Widget child;
  final List<Color> gradientColors;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(
              color: borderColor,
              width: 2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF244B43).withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: PSizes.compactSpace(context, 24.0, 16.0),
          vertical: PSizes.compactSpace(context, 20.0, 14.0),
        ),
        child: child,
      ),
    );
  }
}
