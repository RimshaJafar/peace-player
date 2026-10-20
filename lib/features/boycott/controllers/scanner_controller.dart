import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/boycott/models/scan_response_model.dart';
import 'package:ecommerce_app/features/boycott/controllers/boycott_scanner_service.dart';
import 'package:ecommerce_app/features/boycott/screens/scanner_processing_screen.dart';
import 'package:ecommerce_app/features/boycott/screens/scanner_result_screen.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/helpers/billing_gate_helper.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';

enum ScannerState { idle, capturing, uploading, processing, done, error }

class ScannerController extends GetxController {
  final BoycottScannerService _service = BoycottScannerService();
  final ImagePicker _picker = ImagePicker();

  final scannerState = ScannerState.idle.obs;
  final uploadProgress = 0.0.obs;
  final errorMessage = ''.obs;
  // Store XFile directly — avoids dart:io File content URI issues on Android
  final capturedXFile = Rxn<XFile>();
  final scanResult = Rxn<ScanResponse>();

  // Processing step index (0-5)
  final currentProcessingStep = 0.obs;

  static const List<String> processingSteps = [
    'Uploading Image',
    'Detecting Product',
    'Extracting Text',
    'Identifying Brand',
    'Ethical Analysis',
    'Generating Insights',
  ];

  bool get isLoading =>
      scannerState.value == ScannerState.uploading ||
      scannerState.value == ScannerState.processing;

  /// Pick image from camera using image_picker
  Future<void> captureFromCamera(String firebaseUserId) async {
    try {
      if (!await BillingGateHelper.ensureFeatureAccess(
        BillingFeatureKeys.boycottScanner,
      )) {
        return;
      }
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (picked == null) return;

      capturedXFile.value = picked;
      await _runAnalysis(firebaseUserId);
    } catch (error) {
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to open the camera. Please try again.',
      );
      scannerState.value = ScannerState.error;
      PLoaders.errorSnackBar(
        title: 'Camera Error',
        message: errorMessage.value,
      );
    }
  }

  /// Pick image from gallery using image_picker
  Future<void> captureFromGallery(String firebaseUserId) async {
    try {
      if (!await BillingGateHelper.ensureFeatureAccess(
        BillingFeatureKeys.boycottScanner,
      )) {
        return;
      }
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (picked == null) return;

      capturedXFile.value = picked;
      await _runAnalysis(firebaseUserId);
    } catch (error) {
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to open the gallery. Please try again.',
      );
      scannerState.value = ScannerState.error;
      PLoaders.errorSnackBar(
        title: 'Gallery Error',
        message: errorMessage.value,
      );
    }
  }

  Future<void> _runAnalysis(String firebaseUserId) async {
    if (capturedXFile.value == null) return;

    scannerState.value = ScannerState.uploading;
    currentProcessingStep.value = 0;
    errorMessage.value = '';

    // Navigate to processing screen
    Get.to(() => const ScannerProcessingScreen());

    try {
      // Simulate step progression while uploading
      _startStepProgression();

      final result = await _service.analyzeProduct(
        xFile: capturedXFile.value!,
        firebaseUserId: firebaseUserId,
        onProgress: (p) => uploadProgress.value = p,
      );

      scanResult.value = result;
      scannerState.value = ScannerState.done;
      currentProcessingStep.value = processingSteps.length - 1;

      // Small delay so user sees final step
      await Future.delayed(const Duration(milliseconds: 600));

      // Replace processing screen with result screen
      Get.off(() => ScannerResultScreen(scanResponse: result));
    } catch (error) {
      BillingGateHelper.handleException(error);
      scannerState.value = ScannerState.error;
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to scan this product. Please try again.',
      );
      // Go back to scanner on error
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back();
      }
      PLoaders.errorSnackBar(
        title: 'Scan Failed',
        message: errorMessage.value,
        duration: 4,
      );
    }
  }

  void _startStepProgression() async {
    for (int i = 0; i < processingSteps.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (scannerState.value == ScannerState.uploading ||
          scannerState.value == ScannerState.processing) {
        currentProcessingStep.value = i + 1;
      }
    }
  }

  void reset() {
    scannerState.value = ScannerState.idle;
    uploadProgress.value = 0.0;
    errorMessage.value = '';
    capturedXFile.value = null;
    scanResult.value = null;
    currentProcessingStep.value = 0;
  }
}
