import 'package:ecommerce_app/common/widgets/auth/auth_background_panel.dart';
import 'package:ecommerce_app/common/widgets/auth/gradient_title.dart';
import 'package:ecommerce_app/features/authentication/screens/signup_form.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundPanel(
      maxWidth: 470,
      scrollAreaTopInset: 210,
      outerPadding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 86, 20, 24),
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back),
        color: const Color(0xFF1C5D4E),
        iconSize: 34,
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.all(6),
          minimumSize: const Size(42, 42),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const Center(
            child: Image(
              height: 74,
              image: AssetImage(PImages.loginLogo),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GradientTitle(
              text: PTexts.signupTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
            ),
          ),
          const SizedBox(height: 24),

          /// Form
          const SignupForm(),
        ],
      ),
    );
  }
}
