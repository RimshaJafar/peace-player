import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:ecommerce_app/utils/helpers/network_manager.dart';
import 'package:ecommerce_app/common/widgets/loaders/full_screen_loader.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  /// Variables
  final rememberMe = false.obs;
  final hidePassword = true.obs;

  final localStorage = GetStorage();

  final email = TextEditingController();
  final password = TextEditingController();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final userController = Get.put(UserController());
  bool _isEmailSignInInProgress = false;

  @override
  void onInit() {
    super.onInit();
    password.text = localStorage.read("REMEMBER_ME_PASSWORD") ?? '';
    email.text = localStorage.read("REMEMBER_ME_EMAIL") ?? '';
  }

  /// Email and Password Sign-in
  Future<void> emailAndPasswordSignIn() async {
    if (_isEmailSignInInProgress) return;
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    _isEmailSignInInProgress = true;
    var shouldRedirect = false;
    String? errorMessage;
    String? warningMessage;

    try {
      // Start Loading
      PFullScreenLoader.openLoadingDialog(
        'Logging you in....',
        PImages.doctorAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        warningMessage = 'Please check your connection and try again.';
      } else {
        // Login user using Email & Password
        await AuthenticationRepository.instance.loginWithEmailAndPassword(
          email.text.trim(),
          password.text.trim(),
        );

        // Only remember credentials after Firebase accepts them.
        if (rememberMe.value) {
          localStorage.write("REMEMBER_ME_EMAIL", email.text.trim());
          localStorage.write("REMEMBER_ME_PASSWORD", password.text.trim());
        }

        await userController.fetchUserRecord();
        shouldRedirect = true;
      }
    } catch (e) {
      errorMessage = AppErrorMessage.fromException(
        e,
        fallback: 'Unable to log you in. Please try again.',
      );
    } finally {
      PFullScreenLoader.stopLoading();
      _isEmailSignInInProgress = false;
    }

    // Present feedback only after the opaque loading route has been removed.
    if (warningMessage != null) {
      PLoaders.warningSnackBar(
        title: 'No Internet',
        message: warningMessage,
      );
      return;
    }
    if (errorMessage != null) {
      PLoaders.errorSnackBar(
        title: 'Login failed',
        message: errorMessage,
      );
      return;
    }

    if (shouldRedirect) {
      await AuthenticationRepository.instance.screenRedirect();
    }
  }

  Future<void> googleSignin() async {
    var shouldRedirect = false;
    String? warningTitle;
    String? warningMessage;
    String? errorTitle;
    String? errorMessage;

    try {
      // Start Loading
      PFullScreenLoader.openLoadingDialog(
          'Logging you in...', PImages.doctorAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        warningTitle = 'No Internet';
        warningMessage = 'Please check your connection and try again.';
      } else {
        // Google Authentication
        final userCredentials =
            await AuthenticationRepository.instance.signInWithGoogle();
        if (userCredentials?.user == null) {
          warningTitle = 'Sign-In Cancelled';
          warningMessage = 'Google sign-in was cancelled.';
        } else {
          await userController.saveUserRecord(userCredentials);
          await userController.fetchUserRecord();
          shouldRedirect = true;
        }
      }
    } catch (e) {
      errorTitle = 'Oops!';
      errorMessage = AppErrorMessage.fromException(
        e,
        fallback: 'Unable to sign in with Google. Please try again.',
      );
    } finally {
      PFullScreenLoader.stopLoading();
    }

    if (warningMessage != null) {
      PLoaders.warningSnackBar(
        title: warningTitle ?? 'Google Sign-In',
        message: warningMessage,
      );
      return;
    }
    if (errorMessage != null) {
      PLoaders.errorSnackBar(
        title: errorTitle ?? 'Google Sign-In Failed',
        message: errorMessage,
      );
      return;
    }

    if (shouldRedirect) {
      await AuthenticationRepository.instance.screenRedirect();
    }
  }
}
