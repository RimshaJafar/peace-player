import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/data/repositories/user_repository.dart';
import 'package:ecommerce_app/features/authentication/screens/reset_password.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:ecommerce_app/utils/helpers/network_manager.dart';
import 'package:ecommerce_app/common/widgets/loaders/full_screen_loader.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  /// Variables
  final email = TextEditingController();
  final GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  UserRepository get _userRepository => Get.isRegistered<UserRepository>()
      ? UserRepository.instance
      : Get.put(UserRepository());

  /// Send password reset email
  Future<void> sendPasswordResetEmail() async {
    try {
      // Start Loading
      PFullScreenLoader.openLoadingDialog(
        'Processing your request...',
        PImages.doctorAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        PLoaders.warningSnackBar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
        return;
      }

      // Form Validation
      if (!forgetPasswordFormKey.currentState!.validate()) {
        return;
      }

      final trimmedEmail = email.text.trim();
      await _sendResetEmailIfPasswordProvider(
        trimmedEmail,
        navigateOnSuccess: true,
      );
    } catch (e) {
      PLoaders.errorSnackBar(
        title: "Error",
        message: AppErrorMessage.fromException(
          e,
          fallback: 'Unable to send password reset email. Please try again.',
        ),
      );
    } finally {
      PFullScreenLoader.stopLoading();
    }
  }

  /// Resend password reset email
  Future<void> resendPasswordResetEmail(String email) async {
    try {
      // Start Loading
      PFullScreenLoader.openLoadingDialog(
        'Processing your request...',
        PImages.doctorAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        PLoaders.warningSnackBar(
          title: 'No Internet',
          message: 'Please check your connection and try again.',
        );
        return;
      }

      final trimmedEmail = email.trim();
      await _sendResetEmailIfPasswordProvider(trimmedEmail);
    } catch (e) {
      PLoaders.errorSnackBar(
        title: "Error",
        message: AppErrorMessage.fromException(
          e,
          fallback: 'Unable to resend password reset email. Please try again.',
        ),
      );
    } finally {
      PFullScreenLoader.stopLoading();
    }
  }

  Future<void> _sendResetEmailIfPasswordProvider(
    String email, {
    bool navigateOnSuccess = false,
  }) async {
    final authRepo = AuthenticationRepository.instance;
    final providers = await _providersForEmail(email);

    if (providers.isEmpty) {
      PFullScreenLoader.stopLoading();
      PLoaders.warningSnackBar(
        title: "Account Not Found",
        message: "This email does not have an account created in our app.",
      );
      return;
    }

    if (providers.contains('password')) {
      await authRepo.sendPasswordResetEmail(email);

      PFullScreenLoader.stopLoading();
      PLoaders.successSnackBar(
        title: "Email Sent",
        message: "A password reset link has been sent to your email address.",
      );

      if (navigateOnSuccess) {
        Get.to(() => ResetPassword(email: email));
      }
      return;
    }

    PFullScreenLoader.stopLoading();
    PLoaders.warningSnackBar(
      title: "Password Reset Unavailable",
      message: _providerMessage(providers),
    );
  }

  Future<List<String>> _providersForEmail(String email) async {
    final authRepo = AuthenticationRepository.instance;
    final firebaseProviders = await authRepo.fetchSignInMethodsForEmail(email);
    final savedProviders = await _fallbackProvidersFromSavedUser(email);

    return {
      ...firebaseProviders.map(_normalizeProvider),
      ...savedProviders.map(_normalizeProvider),
    }.where((provider) => provider.isNotEmpty).toList();
  }

  Future<List<String>> _fallbackProvidersFromSavedUser(String email) async {
    final user = await _userRepository.fetchUserByEmail(email);
    if (user == null) return const [];
    if (user.authProviders.isNotEmpty) return user.authProviders;

    if (user.profilePicture.contains('googleusercontent.com')) {
      return const ['google.com'];
    }

    return const ['password'];
  }

  String _providerMessage(List<String> providers) {
    if (providers.contains('google.com')) {
      return "This account was created using Google Sign-In. Please continue signing in with Google.";
    }

    if (providers.contains('apple.com')) {
      return "This account was created using Apple Sign-In. Please continue signing in with Apple.";
    }

    return "This account uses a third-party sign-in provider. Please continue signing in using your original authentication method.";
  }

  String _normalizeProvider(String provider) {
    final normalizedProvider = provider.trim().toLowerCase();
    if (normalizedProvider == 'email' ||
        normalizedProvider == 'email/password' ||
        normalizedProvider == 'emailpassword') {
      return 'password';
    }

    return normalizedProvider;
  }
}
