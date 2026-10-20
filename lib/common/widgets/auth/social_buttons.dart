import 'package:ecommerce_app/features/authentication/controllers/login_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PSocialButtons extends StatelessWidget {
  const PSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google Button
        _SocialButton(
          onPressed: () {
            controller.googleSignin();
            Get.back();
          },
          image: PImages.googleLogo,
        ),
        const SizedBox(width: PSizes.spaceBtwItems),

        // Apple Button
        _SocialButton(
          onPressed: () {},
          image: PImages.appleLogo,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onPressed,
    required this.image,
  });

  final VoidCallback onPressed;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 7,
      shadowColor: const Color(0xFF1C5D4E).withOpacity(0.22),
      shape: const CircleBorder(
        side: BorderSide(color: PColors.grey),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: Image(
              width: 34,
              height: 34,
              image: AssetImage(image),
            ),
          ),
        ),
      ),
    );
  }
}
