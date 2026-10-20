import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/containers/kids_screen_background.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/common/widgets/responsive/max_width_wrapper.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/features/app_support/controllers/manual_payment_controller.dart';

class ManualPaymentScreen extends StatelessWidget {
  const ManualPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManualPaymentController());

    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Local Payment',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      backgroundColor: const Color(0xFFE9F3EF),
      body: KidsScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: MaxWidthWrapper(
                child: Form(
                  key: controller.manualPaymentFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Payment Method',
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF24383F),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Select an account to view its transfer details',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: const Color(0xFF6A7A81),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _PaymentMethodSelector(controller: controller),
                      const SizedBox(height: 16),
                      _SelectedAccountDetails(controller: controller),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Upload Payment Proof',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'After sending payment, upload your screenshot below',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _RequiredLabel('Amount', isRequired: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.amountController,
                        readOnly: true,
                        keyboardType: TextInputType.number,
                        validator: controller.validateAmount,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                        decoration: _supportInputDecoration(
                          hint: 'Amount in PKR',
                          prefixIcon: Icons.payments_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _RequiredLabel('Leave a message (optional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.messageController,
                        maxLines: 3,
                        maxLength: 250,
                        validator: controller.validateSupporterMessage,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                        decoration: _supportInputDecoration(
                          hint: 'Your message...',
                          prefixIcon: Icons.message_rounded,
                          isMultiline: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _RequiredLabel('Screenshot', isRequired: true),
                      const SizedBox(height: 8),
                      _ScreenshotPicker(controller: controller),
                      const SizedBox(height: 32),
                      _SubmitPaymentButton(controller: controller),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitPaymentButton extends StatelessWidget {
  const _SubmitPaymentButton({required this.controller});

  final ManualPaymentController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSubmitting = controller.isSubmitting.value;

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isSubmitting ? 0.78 : 1,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF55BFA0),
                  Color(0xFF279174),
                  Color(0xFF17624F),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.75),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF17624F).withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: InkWell(
              onTap: isSubmitting ? null : controller.submitManualPayment,
              borderRadius: BorderRadius.circular(18),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSubmitting
                      ? const Row(
                          key: ValueKey('submitting'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Submitting Proof...',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          key: ValueKey('ready'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_upload_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Submit Payment Proof',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 21,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  const _PaymentMethodSelector({required this.controller});

  final ManualPaymentController controller;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: controller.selectedMethod.value,
      validator: controller.validatePaymentMethod,
      builder: (field) {
        return Obx(() {
          if (controller.isLoadingAccounts.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final accountsByMethod = {
            for (final account in controller.accounts)
              if (account.method.trim().isNotEmpty) account.method: account,
          };
          final accounts = accountsByMethod.values.toList();

          if (accounts.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFCEE2DC)),
              ),
              child: Text(
                'No payment accounts available',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(color: const Color(0xFF6A7A81)),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 12.0;
                  final useSingleColumn = constraints.maxWidth < 340;
                  final itemWidth = useSingleColumn
                      ? constraints.maxWidth
                      : (constraints.maxWidth - gap) / 2;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: accounts.map((account) {
                      final isSelected =
                          controller.selectedMethod.value == account.method;
                      return SizedBox(
                        width: itemWidth,
                        child: _PaymentMethodChoice(
                          method: account.method,
                          label: account.displayName.isNotEmpty
                              ? account.displayName
                              : _formatMethodLabel(account.method),
                          isSelected: isSelected,
                          onTap: () {
                            controller.selectedMethod.value = account.method;
                            field.didChange(account.method);
                            if (field.hasError) field.validate();
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              if (field.hasError) ...[
                const SizedBox(height: 7),
                Text(
                  field.errorText ?? '',
                  style: GoogleFonts.roboto(
                    color: const Color(0xFFD32F2F),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          );
        });
      },
    );
  }
}

class _PaymentMethodChoice extends StatelessWidget {
  const _PaymentMethodChoice({
    required this.method,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String method;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _paymentMethodColor(method);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 104,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.11)
                : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFC9DED8),
              width: isSelected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF526F83).withValues(alpha: 0.09),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.13),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _paymentMethodIcon(method),
                      color: color,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            key: const ValueKey('selected'),
                            color: color,
                            size: 22,
                          )
                        : const SizedBox(
                            key: ValueKey('unselected'),
                            width: 22,
                          ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  color: const Color(0xFF263A42),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedAccountDetails extends StatelessWidget {
  const _SelectedAccountDetails({required this.controller});

  final ManualPaymentController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedMethod = controller.selectedMethod.value;
      if (selectedMethod == null || selectedMethod.isEmpty) {
        return const SizedBox.shrink();
      }

      final matches = controller.accounts
          .where((account) => account.method == selectedMethod)
          .toList();
      if (matches.isEmpty) return const SizedBox.shrink();

      final account = matches.first;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Column(
          key: ValueKey(selectedMethod),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Details',
              style: GoogleFonts.roboto(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF24383F),
              ),
            ),
            const SizedBox(height: 10),
            _AccountCard(
              method: account.method,
              displayName: account.displayName,
              accountNumber: account.accountNumber,
              iban: account.iban,
              accountTitle: account.accountTitle,
            ),
          ],
        ),
      );
    });
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel(this.text, {this.isRequired = false});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Color(0xFFD32F2F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]
            : null,
      ),
      style: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

InputDecoration _supportInputDecoration({
  required String hint,
  required IconData prefixIcon,
  bool isMultiline = false,
}) {
  const borderRadius = BorderRadius.all(Radius.circular(10));

  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: hint,
    hintStyle: GoogleFonts.roboto(
      fontSize: 15,
      color: const Color(0xFF808080).withValues(alpha: 0.65),
    ),
    prefixIcon: Padding(
      padding: EdgeInsets.only(bottom: isMultiline ? 58 : 0),
      child: Icon(prefixIcon, color: PColors.primary, size: 22),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Color(0xFFC3BEBE)),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Color(0xFFC3BEBE)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: PColors.primary, width: 1.25),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.25),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.5),
    ),
  );
}

class _ScreenshotPicker extends StatelessWidget {
  const _ScreenshotPicker({required this.controller});

  final ManualPaymentController controller;

  @override
  Widget build(BuildContext context) {
    return FormField<XFile>(
      validator: controller.validateScreenshot,
      builder: (field) {
        return Obx(() {
          final image = controller.selectedImage.value;
          final imageBytes = controller.selectedImageBytes.value;
          final hasError = field.hasError;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  await controller.pickImage();
                  field.didChange(controller.selectedImage.value);
                  if (field.hasError) field.validate();
                },
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: hasError
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFFB7CFC8),
                            width: hasError ? 1.5 : 1.25,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF526F83)
                                  .withValues(alpha: 0.13),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: image != null && imageBytes != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  ColoredBox(
                                    color: const Color(0xFFF3F7F6),
                                    child: Image.memory(
                                      imageBytes,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.removeImage();
                                        field.didChange(null);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_android_rounded,
                                    size: 52,
                                    color: hasError
                                        ? const Color(0xFFD32F2F)
                                        : PColors.primary,
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      'Tap to upload screenshot',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: hasError
                                            ? const Color(0xFFD32F2F)
                                            : const Color(0xFF617078),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              if (hasError) ...[
                const SizedBox(height: 6),
                Text(
                  field.errorText ?? '',
                  style: GoogleFonts.roboto(
                    color: const Color(0xFFD32F2F),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          );
        });
      },
    );
  }
}

String _formatMethodLabel(String method) {
  switch (method) {
    case 'jazzcash':
      return 'JazzCash';
    case 'easypaisa':
      return 'EasyPaisa';
    case 'sadapay':
      return 'SadaPay';
    case 'nayapay':
      return 'NayaPay';
    case 'meezan_bank':
      return 'Meezan Bank';
    default:
      return method;
  }
}

Color _paymentMethodColor(String method) {
  switch (method) {
    case 'jazzcash':
      return const Color(0xFFCB222A);
    case 'easypaisa':
      return const Color(0xFF008E48);
    case 'sadapay':
      return const Color(0xFF6259D9);
    case 'nayapay':
      return const Color(0xFF167FC4);
    case 'meezan_bank':
      return const Color(0xFF174F7A);
    default:
      return PColors.primary;
  }
}

IconData _paymentMethodIcon(String method) {
  switch (method) {
    case 'jazzcash':
    case 'easypaisa':
    case 'sadapay':
    case 'nayapay':
      return Icons.phone_android_rounded;
    case 'meezan_bank':
      return Icons.account_balance_rounded;
    default:
      return Icons.account_balance_wallet_rounded;
  }
}

class _AccountCard extends StatelessWidget {
  final String method;
  final String displayName;
  final String accountNumber;
  final String? iban;
  final String accountTitle;

  const _AccountCard({
    required this.method,
    required this.displayName,
    required this.accountNumber,
    this.iban,
    required this.accountTitle,
  });

  Color _getMethodColor() {
    switch (method) {
      case 'jazzcash':
        return const Color(0xFFED1C24);
      case 'easypaisa':
        return const Color(0xFF00A651);
      case 'sadapay':
        return const Color(0xFF6C63FF);
      case 'nayapay':
        return const Color(0xFF1DA1F2);
      case 'meezan_bank':
        return const Color(0xFF003A70);
      default:
        return PColors.primary;
    }
  }

  IconData _getMethodIcon() {
    switch (method) {
      case 'jazzcash':
      case 'easypaisa':
      case 'sadapay':
      case 'nayapay':
        return Icons.mobile_friendly_rounded;
      case 'meezan_bank':
        return Icons.account_balance_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getMethodColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getMethodIcon(), color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accountNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (accountTitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        accountTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (iban != null && iban!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'IBAN: $iban',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: accountNumber));
                  PLoaders.successSnackBar(
                    title: 'Copied!',
                    message: 'Account number copied to clipboard',
                    duration: 2,
                    context: context,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    color: PColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
