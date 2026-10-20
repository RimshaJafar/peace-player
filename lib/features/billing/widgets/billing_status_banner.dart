import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BillingStatusBanner extends StatelessWidget {
  const BillingStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final BillingController controller = BillingController.instance;
    return Obx(() {
      String? message;
      Color background = const Color(0xFFEAF7F2);
      Color foreground = const Color(0xFF0C4D3D);
      IconData icon = Icons.workspace_premium_rounded;

      if (controller.isConfirmingPayment.value ||
          controller.confirmationMessage.value.isNotEmpty) {
        message = controller.confirmationMessage.value.isEmpty
            ? 'Confirming payment with Stripe...'
            : controller.confirmationMessage.value;
        background = const Color(0xFFEAF2FF);
        foreground = const Color(0xFF175CD3);
        icon = Icons.hourglass_top_rounded;
      } else if (controller.isPastDue) {
        message =
            'Your payment could not be completed. You are using the Free Plan.';
        background = const Color(0xFFFFF7E6);
        foreground = const Color(0xFF9A6700);
        icon = Icons.payment_rounded;
      } else if (controller.isExpired &&
          controller.hasPreviousStripeSubscription) {
        message =
            'Your Pro subscription has expired. Renew to continue Pro access.';
        background = const Color(0xFFFFF0F0);
        foreground = const Color(0xFFB42318);
        icon = Icons.workspace_premium_outlined;
      } else if (controller.isPro) {
        final String period = controller.billingProfile?.billingPeriod ?? '';
        message =
            period.isEmpty ? 'Pro is active.' : 'Pro is active ($period).';
      }

      if (message == null) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style:
                    TextStyle(color: foreground, fontWeight: FontWeight.w600),
              ),
            ),
            if (controller.isPastDue && controller.canManageSubscription)
              TextButton(
                onPressed: controller.openCustomerPortal,
                child: const Text('Manage'),
              ),
          ],
        ),
      );
    });
  }
}
