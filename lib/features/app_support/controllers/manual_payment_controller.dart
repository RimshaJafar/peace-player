import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/features/app_support/models/account_model.dart';
import 'package:ecommerce_app/features/app_support/services/app_support_service.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';

class ManualPaymentController extends GetxController {
  final AppSupportService _service = AppSupportService();
  final UserController _userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());

  final manualPaymentFormKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final messageController = TextEditingController();
  final accounts = <AccountModel>[].obs;
  final isLoadingAccounts = false.obs;
  final selectedAmount = 0.0.obs;
  final selectedMethod = Rxn<String>();
  final supporterMessage = ''.obs;
  final selectedImage = Rxn<XFile>();
  final selectedImageBytes = Rxn<Uint8List>();
  final showImageError = false.obs;
  final isSubmitting = false.obs;
  final imagePicker = ImagePicker();

  User? get _firebaseUser => FirebaseAuth.instance.currentUser;

  String get _userId {
    final authId = _firebaseUser?.uid.trim() ?? '';
    if (authId.isNotEmpty) return authId;
    return _userController.user.value.id.trim();
  }

  String get _userName {
    final profile = _userController.user.value;
    final fullName = profile.fullName.trim();
    if (fullName.isNotEmpty) return fullName;

    final username = profile.username.trim();
    if (username.isNotEmpty) return username;

    final displayName = _firebaseUser?.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;

    final email = _userEmail;
    if (email.contains('@')) return email.split('@').first;

    return 'Peace Player User';
  }

  String get _userEmail {
    final authEmail = _firebaseUser?.email?.trim() ?? '';
    if (authEmail.isNotEmpty) return authEmail;
    return _userController.user.value.email.trim();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['amount'] != null) {
      selectedAmount.value = (args['amount'] as num).toDouble();
      amountController.text = selectedAmount.value.toStringAsFixed(0);
    }
    fetchAccountNumbers();
  }

  @override
  void onClose() {
    amountController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> fetchAccountNumbers() async {
    isLoadingAccounts.value = true;
    try {
      final response = await _service.getAccountNumbers();
      accounts.value = response.accounts.where((a) => a.isActive).toList();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ManualPayment] Account loading failed: $error');
        debugPrint(stackTrace.toString());
      }
      PLoaders.errorSnackBar(
        title: 'Error',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Failed to load account details. Please try again.',
        ),
      );
    } finally {
      isLoadingAccounts.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final picked = await imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) {
        throw const AppUserFacingException(
          'The selected screenshot could not be read. Please choose another one.',
        );
      }
      selectedImage.value = picked;
      selectedImageBytes.value = bytes;
      showImageError.value = false;
      manualPaymentFormKey.currentState?.validate();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ManualPayment] Screenshot selection failed: $error');
        debugPrint(stackTrace.toString());
      }
      PLoaders.errorSnackBar(
        title: 'Screenshot Failed',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to select the screenshot. Please try again.',
        ),
      );
    }
  }

  void removeImage() {
    selectedImage.value = null;
    selectedImageBytes.value = null;
    if (showImageError.value) {
      manualPaymentFormKey.currentState?.validate();
    }
  }

  bool get isFormValid =>
      selectedAmount.value > 0 &&
      selectedMethod.value != null &&
      selectedImage.value != null;

  String? validateAmount(String? value) {
    if (selectedAmount.value <= 0) {
      return 'Amount is required.';
    }

    return PValidator.validateRequiredPositiveNumber('Amount', value);
  }

  String? validatePaymentMethod(String? value) {
    return PValidator.validateRequiredSelection('Payment method', value);
  }

  String? validateSupporterMessage(String? value) {
    final message = value?.trim() ?? '';
    if (message.length > 250) {
      return 'Message must be 250 characters or fewer.';
    }
    return null;
  }

  String? validateScreenshot(XFile? value) {
    if (selectedImage.value == null) {
      return 'Screenshot is required.';
    }
    return null;
  }

  bool validateManualPaymentForm() {
    final formValid = manualPaymentFormKey.currentState?.validate() ?? false;
    showImageError.value = selectedImage.value == null;

    if (!formValid || showImageError.value) {
      PLoaders.warningSnackBar(
        title: 'Missing Information',
        message: 'Please complete all required fields.',
      );
      return false;
    }

    return true;
  }

  Future<void> _ensureUserProfileLoaded() async {
    final profile = _userController.user.value;
    if (profile.id.isEmpty ||
        (profile.fullName.trim().isEmpty && profile.username.trim().isEmpty)) {
      await _userController.fetchUserRecord();
    }
  }

  Future<void> submitManualPayment() async {
    if (!validateManualPaymentForm()) return;
    isSubmitting.value = true;
    try {
      await _ensureUserProfileLoaded();
      if (_userId.isEmpty) {
        PLoaders.warningSnackBar(
          title: 'Sign In Required',
          message: 'Please sign in to continue',
        );
        return;
      }

      final message = messageController.text.trim();
      supporterMessage.value = message;
      final submitResult = await _service.submitManualPayment(
        amount: selectedAmount.value,
        currency: 'PKR',
        paymentMethod: selectedMethod.value!,
        supporterMessage: message.isNotEmpty ? message : null,
        userId: _userId,
        userName: _userName,
        userEmail: _userEmail,
      );
      final transactionId = submitResult['transaction_id'] as String;
      await _service.uploadScreenshot(
        transactionId: transactionId,
        imageFile: selectedImage.value!,
      );
      Get.offNamed('/app-support/success', arguments: {
        'type': 'manual',
        'transactionId': transactionId,
        'amount': selectedAmount.value,
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ManualPayment] Submission failed: $error');
        debugPrint(stackTrace.toString());
      }
      PLoaders.errorSnackBar(
        title: 'Submission Error',
        message: AppErrorMessage.fromException(
          error,
          fallback: 'Unable to submit the payment. Please try again.',
        ),
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
