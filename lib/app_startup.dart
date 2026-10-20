import 'package:ecommerce_app/app.dart';
import 'package:ecommerce_app/bindings/general_bindings.dart';
import 'package:ecommerce_app/common/controllers/app_language_controller.dart';
import 'package:ecommerce_app/data/repositories/authentication_repository.dart';
import 'package:ecommerce_app/data/services/auth_service.dart';
import 'package:ecommerce_app/data/services/token_provider.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';
import 'package:ecommerce_app/firebase_options.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> initializeAndOpenApp(DateTime startedAt) async {
  await _startupStep('Load environment', () => dotenv.load());
  await _startupStep('Initialize storage', () => GetStorage.init());
  await _startupStep(
    'Register language controller',
    () async {
      if (!Get.isRegistered<AppLanguageController>()) {
        Get.put(AppLanguageController(), permanent: true);
      }
    },
  );
  await _startupStep(
    'Initialize Firebase',
    () async {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    },
  );
  await _startupStep(
    'Register auth service',
    () async {
      if (!Get.isRegistered<AuthService>()) {
        Get.put(AuthService(), permanent: true);
      }
    },
  );
  await _startupStep(
    'Register token provider',
    () async {
      if (!Get.isRegistered<TokenProvider>()) {
        Get.put(TokenProvider(), permanent: true);
      }
    },
  );
  await _startupStep(
    'Register authentication repository',
    () async {
      if (!Get.isRegistered<AuthenticationRepository>()) {
        Get.put(AuthenticationRepository());
      }
    },
  );
  await _startupStep(
    'Register user controller',
    () async {
      if (!Get.isRegistered<UserController>()) {
        Get.put(UserController());
      }
    },
  );
  await _startupStep(
    'Register billing controller',
    () async {
      if (!Get.isRegistered<BillingController>()) {
        Get.put(BillingController(), permanent: true);
      }
    },
  );
  await _startupStep(
    'Register digital will controller',
    () async {
      if (!Get.isRegistered<DigitalWillController>()) {
        Get.put(DigitalWillController(), permanent: true);
      }
    },
  );
  await _startupStep(
    'Register general bindings',
    () async {
      GeneralBindings().dependencies();
    },
  );

  const minimumSplashDuration = Duration(seconds: 2);
  final elapsed = DateTime.now().difference(startedAt);
  if (elapsed < minimumSplashDuration) {
    await Future<void>.delayed(minimumSplashDuration - elapsed);
  }

  runApp(const App());
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await AuthenticationRepository.instance.screenRedirect();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[Startup] screenRedirect failed: $error');
        debugPrint(stackTrace.toString());
      }
    }
  });
}

Future<void> _startupStep(
  String label,
  Future<void> Function() step,
) async {
  try {
    await step();
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('[Startup] $label failed: $error');
      debugPrint(stackTrace.toString());
    }
    throw const AppConfigurationException(
      'Unable to start Peace Player. Please try again.',
    );
  }
}
