import 'dart:async';
import 'package:ecommerce_app/common/screens/success_screen.dart';
import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();
  Timer? _verificationTimer;

  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  @override
  void onClose() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
    super.onClose();
  }

  /// Send Email Verification Link
  Future<void> sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      PLoaders.successSnackBar(
        title: 'Email Sent',
        message: 'Please check your inbox and verify your email',
      );
    } catch (e) {
      PLoaders.errorSnackBar(
        title: 'Oh Snap',
        message: 'Unable to send verification email. Please try again.',
      );
    }
  }

  /// Timer to automatically redirect to Email Verification
  void setTimerForAutoRedirect() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        await FirebaseAuth.instance.currentUser?.reload();
      } catch (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('[VerifyEmail] reload failed: $error');
          debugPrint(stackTrace.toString());
        }
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        _verificationTimer = null;
        _goToSuccessScreen();
      }
    });
  }

  /// Manually Check if Email Verified
  Future<void> checkEmailVerificationStatus() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await currentUser?.reload();
      final reloadedUser = FirebaseAuth.instance.currentUser;

      if (reloadedUser != null && reloadedUser.emailVerified) {
        _verificationTimer?.cancel();
        _verificationTimer = null;
        _goToSuccessScreen();
        return;
      }

      PLoaders.warningSnackBar(
        title: 'Email Not Verified',
        message: 'Please verify your email, then try again.',
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[VerifyEmail] manual check failed: $error');
        debugPrint(stackTrace.toString());
      }
      PLoaders.errorSnackBar(
        title: 'Verification Error',
        message: 'Unable to check verification status. Please try again.',
      );
    }
  }

  void _goToSuccessScreen() {
    Get.off(() => PSuccessScreen(
          lottie: PImages.successfullyRegisterAnimation,
          title: PTexts.yourAccountCreatedTitle,
          subtitle: PTexts.yourAccountCreatedSubTitle,
          onPressed: () => AuthenticationRepository.instance.screenRedirect(),
        ));
  }
}
