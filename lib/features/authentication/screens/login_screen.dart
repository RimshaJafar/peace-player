import 'package:ecommerce_app/common/widgets/auth/form_divider.dart';
import 'package:ecommerce_app/common/widgets/auth/social_buttons.dart';
import 'package:ecommerce_app/common/widgets/auth/auth_background_panel.dart';
import 'package:ecommerce_app/features/authentication/screens/login_form.dart';
import 'package:ecommerce_app/features/authentication/screens/login_header.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundPanel(
      centerContent: true,
      maxWidth: 470,
      scrollAreaTopInset: 210,
      outerPadding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      contentPadding: const EdgeInsets.fromLTRB(22, 86, 22, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const LoginHeader(),
          const LoginForm(),
          const SizedBox(height: 24),
          PFormDivider(dividerText: PTexts.orSignUpWith.capitalize!),
          const SizedBox(height: 16),
          const PSocialButtons(),
        ],
      ),
    );
  }
}
