import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget {
  final String iconPath;

  const PaymentMethodCard({
    super.key,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 69,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFC3BEBE).withOpacity(0.6),
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Image.asset(
          iconPath,
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}
