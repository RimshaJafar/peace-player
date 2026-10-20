import 'package:ecommerce_app/features/authentication/controllers/signup_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = SignUpController.instance;

    TextStyle? bodyStyle(Color color) {
      return Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 34,
          height: 34,
          child: Obx(
            () => Checkbox(
              value: controller.privacypolicy.value,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: const BorderSide(color: PColors.primary, width: 1.8),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return PColors.primary;
                }
                return Colors.white;
              }),
              onChanged: (value) => controller.privacypolicy.value =
                  !controller.privacypolicy.value,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${PTexts.iAgreeTo} ',
                  style: bodyStyle(const Color(0xFF0F172A)),
                ),
                TextSpan(
                  text: PTexts.privacyPolicy,
                  style: bodyStyle(PColors.primary),
                ),
                TextSpan(
                  text: ' ${PTexts.and} ',
                  style: bodyStyle(const Color(0xFF0F172A)),
                ),
                TextSpan(
                  text: PTexts.termsOfUse,
                  style: bodyStyle(PColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
