import 'package:ecommerce_app/common/widgets/loaders/animation_loader.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A utility class for managing a full-screen loading dialog.
class PFullScreenLoader {
  static DialogRoute<void>? _loadingRoute;
  static NavigatorState? _navigator;

  /// Open a full-screen loading dialog with a given text and animation.
  /// This method doesn't return anything.
  ///
  /// Parameters:
  ///   - text: The text to be displayed in the loading dialog.
  ///   - animation: The Lottie animation to be shown.
  static void openLoadingDialog(String text, String animation) {
    final ctx = Get.context;
    if (ctx == null) return;

    final currentRoute = _loadingRoute;
    if (currentRoute != null && currentRoute.isActive) return;

    final navigator = Navigator.of(ctx, rootNavigator: true);
    final route = DialogRoute<void>(
      context: ctx,
      barrierDismissible:
          false, // The dialog can't be dismissed by tapping outside it
      builder: (_) => PopScope(
        canPop: false, // Disable popping with the back button
        child: Container(
          color: PColors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 250), // Adjust the spacing as needed
              PAnimationLoaderWidget(text: text, animation: animation),
            ],
          ),
        ),
      ),
    );

    _navigator = navigator;
    _loadingRoute = route;
    navigator.push<void>(route).whenComplete(() {
      if (identical(_loadingRoute, route)) {
        _loadingRoute = null;
        _navigator = null;
      }
    });
  }

  /// Stop the currently open loading dialog.
  /// This method doesn't return anything.
  static void stopLoading() {
    final route = _loadingRoute;
    final navigator = _navigator;

    _loadingRoute = null;
    _navigator = null;

    if (route != null && navigator != null && route.isActive) {
      navigator.removeRoute(route);
    }
  }
}
