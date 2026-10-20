import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/data/repositories/user_repository.dart';
import 'package:ecommerce_app/features/authentication/models/user_model.dart';
import 'package:ecommerce_app/features/authentication/screens/verify_email.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:ecommerce_app/utils/helpers/network_manager.dart';
import 'package:ecommerce_app/common/widgets/loaders/full_screen_loader.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  /// Variables
  final hidepassword = true.obs;
  final privacypolicy = true.obs;
  final email = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final phoneNumber = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  ///Sign Up
  Future<void> signup() async {
    var shouldNavigateToVerifyEmail = false;
    String? warningTitle;
    String? warningMessage;
    String? errorTitle;
    String? errorMessage;
    String? successTitle;
    String? successMessage;

    try {
      // Start Loading
      PFullScreenLoader.openLoadingDialog(
        'We are processing your information...',
        PImages.successfullyRegisterAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        warningTitle = 'No Internet';
        warningMessage = 'Please check your connection and try again.';
      } else if (!(signupFormKey.currentState?.validate() ?? false)) {
        // Form fields display their own validation messages.
      } else if (!privacypolicy.value) {
        warningTitle = 'Accept Privacy Policy';
        warningMessage = 'Accept the privacy policy to create an account.';
      } else {
        final userCredential = await AuthenticationRepository.instance
            .registerWithEmailAndPassword(
                email.text.trim(), password.text.trim());
        final firebaseUser = userCredential.user;
        if (firebaseUser == null) {
          errorTitle = 'Signup Error';
          errorMessage =
              'We could not complete account setup. Please try again.';
        } else {
          final newUser = UserModel(
            id: firebaseUser.uid,
            firstName: firstName.text.trim(),
            lastName: lastName.text.trim(),
            username: username.text.trim(),
            email: email.text.trim(),
            phoneNumber: phoneNumber.text.trim(),
            profilePicture: '',
            authProviders: const ['password'],
          );

          final userRepository = Get.put(UserRepository());
          try {
            await userRepository.saveUserRecord(newUser);
            successTitle = 'Congratulations';
            successMessage =
                'Your account has been created! Verify email to continue.';
            shouldNavigateToVerifyEmail = true;
          } catch (_) {
            errorTitle = 'Profile Setup Failed';
            errorMessage =
                'Your account was created, but we could not save your profile. Please try again before continuing.';
          }
        }
      }
    } catch (e) {
      warningTitle = 'Oh Snap!';
      warningMessage = AppErrorMessage.fromException(
        e,
        fallback: 'Unable to create your account. Please try again.',
      );
    } finally {
      PFullScreenLoader.stopLoading();
    }

    if (warningMessage != null) {
      PLoaders.warningSnackBar(
        title: warningTitle ?? 'Signup',
        message: warningMessage,
      );
      return;
    }
    if (errorMessage != null) {
      PLoaders.errorSnackBar(
        title: errorTitle ?? 'Signup Error',
        message: errorMessage,
      );
      return;
    }
    if (successMessage != null) {
      PLoaders.successSnackBar(
        title: successTitle ?? 'Signup Complete',
        message: successMessage,
      );
    }

    if (shouldNavigateToVerifyEmail) {
      Get.to(() => VerifyEmailScreen(email: email.text.trim()));
    }
  }
}
