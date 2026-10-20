import 'package:ecommerce_app/common/widgets/auth/auth_background_panel.dart';
import 'package:ecommerce_app/common/widgets/auth/gradient_button.dart';
import 'package:ecommerce_app/common/widgets/auth/gradient_title.dart';
import 'package:ecommerce_app/features/authentication/controllers/foget_password_controller.dart';
import 'package:ecommerce_app/features/authentication/screens/login_screen.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundPanel(
      centerContent: true,
      maxWidth: 470,
      scrollAreaTopInset: 210,
      panelRadius: 0,
      outerPadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(30, 78, 30, 30),
      trailing: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(CupertinoIcons.clear),
        color: const Color(0xFF1C5D4E),
        iconSize: 34,
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.all(6),
          minimumSize: const Size(42, 42),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const _ResetPasswordArtwork(),
          const SizedBox(height: 24),
          GradientTitle(
            text: PTexts.passwordResetTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.16,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            email,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF4E5661),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          Text(
            PTexts.passwordResetSubTitle.trim(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF8A9492),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C5D4E).withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: GradientButton(
              onPressed: () => Get.offAll(() => const LoginScreen()),
              text: "Done",
              height: 60,
              borderRadius: 34,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => ForgetPasswordController.instance
                .resendPasswordResetEmail(email),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF329070),
              textStyle: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text("Resend Email"),
          ),
        ],
      ),
    );
  }
}

class _ResetPasswordArtwork extends StatelessWidget {
  const _ResetPasswordArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 286,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 38,
            child: Container(
              width: 214,
              height: 196,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF6F1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            left: 42,
            bottom: 80,
            child: Icon(
              Icons.auto_awesome,
              color: Color(0xFFE0F0EA),
              size: 18,
            ),
          ),
          const Positioned(
            right: 48,
            bottom: 118,
            child: Icon(
              Icons.auto_awesome,
              color: Color(0xFFE0F0EA),
              size: 18,
            ),
          ),
          Image(
            image: const AssetImage(PImages.deliveredEmailIllustration),
            height: 276,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
