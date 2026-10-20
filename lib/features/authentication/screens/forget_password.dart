import 'package:ecommerce_app/common/widgets/auth/auth_background_panel.dart';
import 'package:ecommerce_app/common/widgets/auth/auth_text_field.dart';
import 'package:ecommerce_app/common/widgets/auth/gradient_button.dart';
import 'package:ecommerce_app/common/widgets/auth/gradient_title.dart';
import 'package:ecommerce_app/features/authentication/controllers/foget_password_controller.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());

    return AuthBackgroundPanel(
      maxWidth: 470,
      scrollAreaTopInset: 210,
      outerPadding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      contentPadding: const EdgeInsets.fromLTRB(28, 84, 28, 24),
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
      child: Form(
        key: controller.forgetPasswordFormKey,
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
            const SizedBox(height: 30),
            GradientTitle(
              text: PTexts.forgetPasswordTitle,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 22),
            Text(
              PTexts.forgetPasswordSubTitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF4E5661),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 1.58,
                  ),
            ),
            const SizedBox(height: 30),
            AuthTextField(
              controller: controller.email,
              validator: (value) => PValidator.validateEmail(value),
              label: PTexts.email,
              isRequired: true,
              prefixIcon:
                  const Icon(Icons.email_outlined, color: Color(0xFF329070)),
              keyboardType: TextInputType.emailAddress,
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
                onPressed: () => controller.sendPasswordResetEmail(),
                text: "Submit",
                height: 60,
                borderRadius: 34,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
