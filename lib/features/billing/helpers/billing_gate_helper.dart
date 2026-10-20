import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/models/billing_models.dart';
import 'package:ecommerce_app/features/billing/services/billing_api_service.dart';
import 'package:ecommerce_app/features/billing/widgets/billing_upgrade_dialog.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';

class BillingGateHelper {
  const BillingGateHelper._();

  static Future<bool> ensureFeatureAccess(String featureKey) async {
    final BillingController controller = BillingController.instance;
    if (!controller.hasProfile && !controller.isProfileLoading.value) {
      await controller.loadBillingProfile();
    }

    // A temporary billing/network failure is not a local denial. Backend remains final authority.
    if (!controller.hasProfile) return true;
    if (!controller.isFeatureEnabled(featureKey)) {
      _showUnavailableFeature(controller);
      return false;
    }
    if (controller.hasExhaustedQuota(featureKey)) {
      _showQuotaReached(controller);
      return false;
    }
    return true;
  }

  static void handleException(Object error) {
    if (error is BillingApiException) {
      handleError(error.error);
    }
  }

  static void handleError(BillingApiErrorModel error) {
    BillingController.instance.recordApiError(error);
    final String code = error.errorCode ?? '';
    if (code == 'payment_past_due') {
      showBillingUpgradeDialog(
        title: 'Payment issue',
        message:
            'Your payment could not be completed. Your account is currently using the Free Plan.',
        showManageSubscription:
            BillingController.instance.canManageSubscription,
      );
      return;
    }
    if (code == 'subscription_expired') {
      showBillingUpgradeDialog(
        title: 'Subscription expired',
        message:
            'Your Pro subscription has expired. Renew to continue Pro access.',
      );
      return;
    }
    if (code == 'feature_not_available') {
      _showUnavailableFeature(BillingController.instance);
      return;
    }
    if (code == 'quota_exceeded') {
      _showQuotaReached(BillingController.instance);
      return;
    }
    if (code == 'rate_limited') {
      final String reset = error.resetAt == null
          ? ''
          : ' Try again after ${error.resetAt!.toLocal()}.';
      PLoaders.warningSnackBar(
        title: 'Please wait',
        message: 'Too many requests.$reset',
      );
      return;
    }
    if (code == 'duplicate_usage_request') {
      PLoaders.warningSnackBar(
        title: 'Request in progress',
        message: 'Please wait for the current request to finish.',
      );
      return;
    }
    if (code == 'stripe_customer_missing') {
      PLoaders.warningSnackBar(
        title: 'Subscription',
        message: 'No Stripe subscription found for this account.',
      );
      return;
    }
    if (error.message != null && error.message!.isNotEmpty) {
      PLoaders.errorSnackBar(
        title: 'Billing',
        message: AppErrorMessage.sanitize(error.message) ??
            'The billing request could not be completed. Please try again.',
      );
    }
  }

  static void _showUnavailableFeature(BillingController controller) {
    if (controller.isPastDue) {
      showBillingUpgradeDialog(
        title: 'Payment issue',
        message:
            'Your payment could not be completed. Your account is currently using the Free Plan.',
        showManageSubscription: controller.canManageSubscription,
      );
      return;
    }
    if (controller.isExpired && controller.hasPreviousStripeSubscription) {
      showBillingUpgradeDialog(
        title: 'Subscription expired',
        message:
            'Your Pro subscription has expired. Renew to continue Pro access.',
      );
      return;
    }
    showBillingUpgradeDialog(
      message: 'This feature is available on the Pro Plan.',
    );
  }

  static void _showQuotaReached(BillingController controller) {
    final String message = controller.isPro
        ? 'You have reached the current limit for this feature. Please wait for the reset time.'
        : 'You have reached your Free Plan limit for this feature.';
    showBillingUpgradeDialog(
      title: 'Limit reached',
      message: message,
      showManageSubscription:
          controller.isPro && controller.canManageSubscription,
    );
  }
}
