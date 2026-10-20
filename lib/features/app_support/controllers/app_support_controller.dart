import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/features/app_support/services/app_support_service.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';

class AppSupportController extends GetxController {
  final AppSupportService _service = AppSupportService();
  final UserController _userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());

  final selectedAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    if (_supportsStripePaymentSheet) {
      Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
    }
  }

  final customAmount = 0.0.obs;
  final isCustom = false.obs;
  final isLoading = false.obs;
  final supporterMessage = ''.obs;
  final showAmountError = false.obs;

  User? get _firebaseUser => FirebaseAuth.instance.currentUser;

  String get _userId {
    final authId = _firebaseUser?.uid.trim() ?? '';
    if (authId.isNotEmpty) return authId;
    return _userController.user.value.id.trim();
  }

  String get _userName {
    final profile = _userController.user.value;
    final fullName = profile.fullName.trim();
    if (fullName.isNotEmpty) return fullName;

    final username = profile.username.trim();
    if (username.isNotEmpty) return username;

    final displayName = _firebaseUser?.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;

    final email = _userEmail;
    if (email.contains('@')) return email.split('@').first;

    return 'Peace Player User';
  }

  String get _userEmail {
    final authEmail = _firebaseUser?.email?.trim() ?? '';
    if (authEmail.isNotEmpty) return authEmail;
    return _userController.user.value.email.trim();
  }

  bool get _supportsStripePaymentSheet {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  void selectAmount(double amount) {
    selectedAmount.value = amount;
    isCustom.value = false;
    showAmountError.value = false;
  }

  void selectCustomAmount(double amount) {
    customAmount.value = amount;
    isCustom.value = true;
    if (amount > 0) {
      showAmountError.value = false;
    }
  }

  double get effectiveAmount =>
      isCustom.value ? customAmount.value : selectedAmount.value;

  bool validateAmountSelection() {
    if (effectiveAmount <= 0) {
      showAmountError.value = true;
      PLoaders.warningSnackBar(
        title: 'Amount Required',
        message: 'Please select or enter an amount',
      );
      return false;
    }

    showAmountError.value = false;
    return true;
  }

  Future<void> _ensureUserProfileLoaded() async {
    final profile = _userController.user.value;
    if (profile.id.isEmpty ||
        (profile.fullName.trim().isEmpty && profile.username.trim().isEmpty)) {
      await _userController.fetchUserRecord();
    }
  }

  Future<void> initiateStripePayment() async {
    if (!validateAmountSelection()) return;
    isLoading.value = true;
    try {
      await _ensureUserProfileLoaded();
      if (_userId.isEmpty) {
        PLoaders.warningSnackBar(
          title: 'Sign In Required',
          message: 'Please sign in to continue',
        );
        return;
      }
      if (!_supportsStripePaymentSheet) {
        PLoaders.warningSnackBar(
          title: 'Card Payment Unavailable',
          message:
              'Card payment is available on Android and iOS. Please use Local Transfer.',
        );
        return;
      }
      if ((dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '').trim().isEmpty) {
        PLoaders.errorSnackBar(
          title: 'Payment Unavailable',
          message: 'Card payment is temporarily unavailable.',
        );
        return;
      }

      final result = await _service.initiateStripePayment(
        amount: effectiveAmount,
        currency: 'PKR',
        supporterMessage:
            supporterMessage.value.isNotEmpty ? supporterMessage.value : null,
        userId: _userId,
        userName: _userName,
        userEmail: _userEmail,
      );
      final clientSecret = result['client_secret'] as String;
      final transactionId = result['transaction_id'] as String;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Peace Player',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      final intentId = clientSecret.split('_secret_').first;
      await _service.confirmStripePayment(intentId);
      Get.toNamed('/app-support/success', arguments: {
        'type': 'stripe',
        'transactionId': transactionId,
        'amount': effectiveAmount,
      });
    } on StripeException catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AppSupport] Stripe payment failed: $error');
        debugPrint(stackTrace.toString());
      }
      if (error.error.code == FailureCode.Canceled) return;

      PLoaders.errorSnackBar(
        title: 'Card Payment Failed',
        message: 'The card payment could not be completed. Please try again.',
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AppSupport] Payment failed: $error');
        debugPrint(stackTrace.toString());
      }
      PLoaders.errorSnackBar(
        title: 'Payment Error',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'The payment could not be completed. Please try again.',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> navigateToManualPayment() async {
    if (!validateAmountSelection()) return;
    if (_userId.isEmpty) {
      PLoaders.warningSnackBar(
        title: 'Sign In Required',
        message: 'Please sign in to continue',
      );
      return;
    }
    Get.toNamed('/app-support/manual', arguments: {
      'amount': effectiveAmount,
    });
  }
}
