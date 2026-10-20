// This file is superseded by the new AI scanner.
// The BoycottProductScanPopup has been replaced by BoycottScannerScreen.
// Kept as a stub to avoid breaking any remaining imports.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/boycott/screens/boycott_scanner_screen.dart';

/// @deprecated Use BoycottScannerScreen instead.
/// This popup now redirects to the fullscreen AI scanner.
class BoycottProductScanPopup extends StatelessWidget {
  const BoycottProductScanPopup({super.key});

  @override
  Widget build(BuildContext context) {
    // Immediately close the dialog and open the new scanner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      Get.to(() => const BoycottScannerScreen());
    });
    return const SizedBox.shrink();
  }
}
