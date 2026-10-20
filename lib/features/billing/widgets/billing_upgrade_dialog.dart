import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showBillingUpgradeDialog({
  String title = 'Upgrade to Pro',
  required String message,
  bool showManageSubscription = false,
}) {
  Get.dialog(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(onPressed: Get.back, child: const Text('Not now')),
        if (showManageSubscription)
          TextButton(
            onPressed: () {
              Get.back();
              BillingController.instance.openCustomerPortal();
            },
            child: const Text('Manage subscription'),
          )
        else
          FilledButton(
            onPressed: () {
              Get.back();
              showBillingPlanPicker();
            },
            child: const Text('Upgrade to Pro'),
          ),
      ],
    ),
  );
}

void showBillingPlanPicker() {
  final BillingController controller = BillingController.instance;
  Get.bottomSheet(
    SafeArea(
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Choose Pro billing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text('Checkout opens securely in your browser.'),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: controller.isStartingCheckout.value
                      ? null
                      : () async {
                          await controller.startCheckout(
                            controller.monthlyBillingPeriod,
                          );
                          if (controller.lastError.value == null) Get.back();
                        },
                  child: Text('Monthly - ${controller.monthlyPriceText}'),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: controller.isStartingCheckout.value
                      ? null
                      : () async {
                          await controller.startCheckout(
                            controller.yearlyBillingPeriod,
                          );
                          if (controller.lastError.value == null) Get.back();
                        },
                  child: controller.isStartingCheckout.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Yearly - ${controller.yearlyPriceText}'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
