import 'package:ecommerce_app/features/authentication/controllers/login_controller.dart';
import 'package:ecommerce_app/features/authentication/screens/forget_password.dart';
import 'package:ecommerce_app/features/authentication/screens/signup.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:ecommerce_app/common/widgets/auth/auth_text_field.dart';
import 'package:ecommerce_app/common/widgets/auth/gradient_button.dart';
import 'package:ecommerce_app/common/widgets/auth/input_decorations.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Column(
          children: [
            // Email Text Field (reused common AuthTextField)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AuthTextField(
                controller: controller.email,
                validator: (value) => PValidator.validateEmail(value),
                label: PTexts.email,
                isRequired: true,
                prefixIcon:
                    const Icon(Icons.email_outlined, color: Color(0xFF329070)),
                keyboardType: TextInputType.emailAddress,
              ),
            ),

            // Password Text Field (uses shared input decoration helper, keeps Obx for toggle)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Obx(
                () {
                  final baseDecoration = InputDecorations.authInputDecoration(
                    context: context,
                    label: PTexts.password,
                    prefix: const Icon(Icons.lock_outline,
                        color: Color(0xFF329070)),
                    isRequired: true,
                  );
                  return AuthFieldBox(
                    child: TextFormField(
                      controller: controller.password,
                      obscureText: controller.hidePassword.value,
                      validator: (value) => PValidator.validatePassword(value),
                      style: const TextStyle(
                        color: Color(0xFF4E5661),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: baseDecoration.copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.hidePassword.value
                                ? Iconsax.eye_slash
                                : Iconsax.eye,
                            color: const Color(0xFF258A67),
                            size: 27,
                          ),
                          onPressed: () => controller.hidePassword.value =
                              !controller.hidePassword.value,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            //Remember Me and forget password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: Obx(
                        () => Checkbox(
                          value: controller.rememberMe.value,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: const BorderSide(
                            color: Color(0xFF329070),
                            width: 1.8,
                          ),
                          fillColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color(0xFF329070);
                            }
                            return Colors.white;
                          }),
                          onChanged: (value) => controller.rememberMe.value =
                              !controller.rememberMe.value,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      PTexts.rememberMe,
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => Get.to(() => const ForgetPassword()),
                  child: const Text(
                    PTexts.forgetPassword,
                    style: TextStyle(
                      color: Color(0xFF329070), // Match your app's theme
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // Sign In Button (uses shared GradientButton)
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
                onPressed: () => controller.emailAndPasswordSignIn(),
                text: PTexts.signIn,
                height: 56,
                borderRadius: 34,
              ),
            ),

            const SizedBox(height: 14),

            // Create Account Button with green outline
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C5D4E).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFF329070), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(34),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                  ),
                  onPressed: () => Get.to(() => const SignupScreen()),
                  child: const Text(
                    PTexts.createAccount,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF329070),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
