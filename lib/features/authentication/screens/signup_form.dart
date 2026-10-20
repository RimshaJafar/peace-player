import 'package:ecommerce_app/common/widgets/legal/terms_and_condition.dart';
import 'package:ecommerce_app/features/authentication/controllers/signup_controller.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// Reused common widgets / helpers
import 'package:ecommerce_app/common/widgets/auth/auth_text_field.dart';
import 'package:ecommerce_app/common/widgets/auth/gradient_button.dart';
import 'package:ecommerce_app/common/widgets/auth/input_decorations.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());

    return Form(
      key: controller.signupFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name Fields (left / right) - reuse AuthTextField for consistency
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  controller: controller.firstName,
                  validator: (value) =>
                      PValidator.validateEmptyText("first name", value),
                  label: PTexts.firstName,
                  isRequired: true,
                  prefixIcon:
                      const Icon(Iconsax.user, color: Color(0xFF329070)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AuthTextField(
                  controller: controller.lastName,
                  validator: (value) =>
                      PValidator.validateEmptyText("last name", value),
                  label: PTexts.lastName,
                  isRequired: true,
                  prefixIcon:
                      const Icon(Iconsax.user, color: Color(0xFF329070)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Username
          AuthTextField(
            controller: controller.username,
            validator: (value) =>
                PValidator.validateEmptyText("Username", value),
            label: PTexts.username,
            isRequired: true,
            prefixIcon: const Icon(Iconsax.user_edit, color: Color(0xFF329070)),
          ),
          const SizedBox(height: 16),

          // Email
          AuthTextField(
            controller: controller.email,
            validator: (value) => PValidator.validateEmail(value),
            label: PTexts.email,
            isRequired: true,
            prefixIcon:
                const Icon(Icons.email_outlined, color: Color(0xFF329070)),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Phone Number
          AuthTextField(
            controller: controller.phoneNumber,
            validator: (value) => PValidator.validatePhoneNumber(value),
            label: PTexts.phoneNo,
            isRequired: true,
            prefixIcon: const Icon(Iconsax.call, color: Color(0xFF329070)),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Password (use InputDecorationHelper + Obx for visibility toggle)
          Obx(
            () {
              final baseDecoration = InputDecorations.authInputDecoration(
                context: context,
                label: PTexts.password,
                prefix:
                    const Icon(Icons.lock_outline, color: Color(0xFF329070)),
                isRequired: true,
              );
              return AuthFieldBox(
                child: TextFormField(
                  controller: controller.password,
                  obscureText: controller.hidepassword.value,
                  validator: (value) => PValidator.validatePassword(value),
                  style: const TextStyle(
                    color: Color(0xFF4E5661),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: baseDecoration.copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => controller.hidepassword.value =
                          !controller.hidepassword.value,
                      icon: Icon(
                        controller.hidepassword.value
                            ? Iconsax.eye_slash
                            : Iconsax.eye,
                        color: const Color(0xFF258A67),
                        size: 27,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Terms & Conditions
          const TermsAndConditions(),
          const SizedBox(height: 16),

          // Sign Up Button (use shared GradientButton)
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
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: GradientButton(
                onPressed: () => controller.signup(),
                text: PTexts.createAccount,
                height: 60,
                borderRadius: 34,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
