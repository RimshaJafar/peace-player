import 'dart:async';

import 'package:ecommerce_app/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  var rootAppStarted = false;
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint('[FlutterError] ${details.exceptionAsString()}');
        debugPrint(details.stack?.toString());
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        debugPrint('[PlatformDispatcher] $error');
        debugPrint(stack.toString());
      }
      return true;
    };

    runApp(const SplashScreen(runStartup: true));
    rootAppStarted = true;
  }, (error, stack) {
    if (kDebugMode) {
      debugPrint('[runZonedGuarded] $error');
      debugPrint(stack.toString());
    }
    if (!rootAppStarted) {
      runApp(const SplashScreen(runStartup: true));
    }
  });
}
