import 'dart:async';

import 'package:ecommerce_app/features/authentication/screens/login_screen.dart';
import 'package:ecommerce_app/features/authentication/screens/verify_email.dart';
import 'package:ecommerce_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:ecommerce_app/main_screen.dart';
import 'package:ecommerce_app/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:ecommerce_app/utils/exceptions/firebase_exceptions.dart';
import 'package:ecommerce_app/utils/exceptions/format_exceptions.dart';
import 'package:ecommerce_app/utils/exceptions/platform_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final RxBool isLoggedInRx = false.obs;
  StreamSubscription<User?>? _authStateSubscription;

  // Get Authenticated User Data
  User? get authUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    isLoggedInRx.value = _auth.currentUser != null;
    _authStateSubscription = _auth.authStateChanges().listen(
      (user) {
        isLoggedInRx.value = user != null;
      },
      onError: (Object error, StackTrace stackTrace) {
        isLoggedInRx.value = _auth.currentUser != null;
        _logDebug('Authentication state listener failed.', error, stackTrace);
      },
    );
  }

  /// Function to show relevant screen
  Future<void> screenRedirect() async {
    late Widget Function() destination;

    try {
      final user = _auth.currentUser;
      if (user != null) {
        destination = user.emailVerified
            ? () => MainScreen()
            : () => VerifyEmailScreen(email: user.email);
      } else {
        await deviceStorage.writeIfNull('IsFirstTime', true);
        final isFirstTime = deviceStorage.read('IsFirstTime') == true;
        destination =
            isFirstTime ? () => OnBoardingScreen() : () => LoginScreen();
      }
    } catch (error, stackTrace) {
      _logDebug(
        'Unable to resolve the authentication destination.',
        error,
        stackTrace,
      );
      destination = () => LoginScreen();
    }

    try {
      final navigation = Get.offAll<void>(destination);
      if (navigation != null) {
        unawaited(
          navigation.then<void>(
            (_) {},
            onError: (Object error, StackTrace stackTrace) {
              _logDebug(
                'Authentication navigation failed.',
                error,
                stackTrace,
              );
            },
          ),
        );
      }
    } catch (error, stackTrace) {
      _logDebug('Authentication navigation failed.', error, stackTrace);
    }
  }

  /// [EmailAuthentication] - REGISTER
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred during registration.';
    } on FirebaseException catch (e) {
      throw e.message ?? 'A Firebase error occurred.';
    } on FormatException {
      throw 'Bad format detected. Please check your input.';
    } on PlatformException catch (e) {
      throw e.message ?? 'A platform error occurred.';
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - Forget Password
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    try {
      // Firebase currently marks this as deprecated because email enumeration
      // protection can affect it, but it is still the client API for provider lookup.
      // ignore: deprecated_member_use
      return await _auth.fetchSignInMethodsForEmail(email.trim());
    } on FirebaseAuthException catch (e) {
      throw PFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw PFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw PFormatException('invalid-input');
    } on PlatformException catch (e) {
      throw PPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw PFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw PFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw PFormatException('invalid-input');
    } on PlatformException catch (e) {
      throw PPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) debugPrint("Password reset failed: $e");
      throw 'Unable to send password reset email. Please try again.';
    }
  }

  ///[EmailVerification]-MAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw PFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw PFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw PFormatException('invalid-input');
    } on PlatformException catch (e) {
      throw PPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> logout() async {
    try {
      if (kIsWeb) {
        // Web uses Firebase Auth popup; sign out via Firebase only.
        await FirebaseAuth.instance.signOut();
      } else {
        // Mobile/desktop: also sign out the GoogleSignIn session.
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
      }
      isLoggedInRx.value = false;
      Get.offAll(() => LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw PFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw PFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw PFormatException('invalid-input');
    } on PlatformException catch (e) {
      throw PPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw PFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw PFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw PFormatException('invalid-input');
    } on PlatformException catch (e) {
      throw PPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  ///Google Authentication
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Use Firebase Auth popup flow on web (recommended)
        final provider = GoogleAuthProvider();
        // Force account selection so the user can choose a different email.
        provider.setCustomParameters({'prompt': 'select_account'});
        return await _auth.signInWithPopup(provider);
      } else {
        // Mobile/desktop: use google_sign_in plugin
        final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();
        if (userAccount == null) return null;
        final GoogleSignInAuthentication googleAuth =
            await userAccount.authentication;
        if (googleAuth.accessToken == null && googleAuth.idToken == null) {
          return null;
        }

        final credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credentials);
      }
    } on FirebaseAuthException catch (e) {
      throw PFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw PFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw PFormatException('invalid-input');
    } on PlatformException catch (e) {
      throw PPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) debugPrint("Google sign-in failed: $e");
      throw 'Unable to sign in with Google. Please try again.';
    }
  }

  void _logDebug(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode) return;
    debugPrint('[AuthenticationRepository] $message');
    if (error != null) debugPrint(error.toString());
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }

  @override
  void onClose() {
    unawaited(_authStateSubscription?.cancel());
    _authStateSubscription = null;
    super.onClose();
  }
}
