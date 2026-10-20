import 'dart:math' as math;

import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/common/widgets/responsive/max_width_wrapper.dart';
import 'package:ecommerce_app/features/app_support/controllers/app_support_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSupportScreen extends StatelessWidget {
  const AppSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppSupportController());
    final amounts = [300.0, 500.0, 1000.0];

    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFB),
      appBar: PAppBar(
        title: const Text(
          'Support This App',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
        actions: [
          IconButton(
            tooltip: 'Support history',
            onPressed: () => Get.toNamed('/app-support/history'),
            icon: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: MaxWidthWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MissionCard(),
                  const SizedBox(height: 18),
                  const _SectionTitle('Choose an amount', isRequired: true),
                  const SizedBox(height: 12),
                  Obx(
                    () => _AmountGrid(
                      children: [
                        ...amounts.map(
                          (amount) => _AmountTile(
                            label: 'PKR ${amount.toInt()}',
                            isSelected: !controller.isCustom.value &&
                                controller.selectedAmount.value == amount,
                            onTap: () => controller.selectAmount(amount),
                          ),
                        ),
                        _AmountTile(
                          label: 'Custom',
                          isSelected: controller.isCustom.value,
                          onTap: () {
                            controller.selectCustomAmount(0);
                            _showCustomAmountDialog(context, controller);
                          },
                        ),
                      ],
                    ),
                  ),
                  _AmountSelectionError(controller: controller),
                  _SelectedAmountBanner(controller: controller),
                  const SizedBox(height: 18),
                  const _SectionTitle(
                    'How can you contribute ?',
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 12.0;
                      final useSingleColumn = constraints.maxWidth < 340;
                      final cardWidth = useSingleColumn
                          ? constraints.maxWidth
                          : (constraints.maxWidth - gap) / 2;

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _PaymentMethodCard(
                              icon: Icons.credit_card_rounded,
                              title: 'Card Payment',
                              subtitle: 'Visa / Mastercard (International)',
                              onTap: () =>
                                  controller.initiateStripePayment(),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _PaymentMethodCard(
                              icon: Icons.mobile_friendly_rounded,
                              title: 'Local Transfer',
                              subtitle: 'JazzCash, EasyPaisa and more',
                              onTap: () =>
                                  controller.navigateToManualPayment(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const _SupportNote(),
                ],
              ),
            ),
          ),
          Obx(
            () => controller.isLoading.value
                ? Positioned.fill(
                    child: ColoredBox(
                      color: Colors.white.withValues(alpha: 0.35),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: PColors.primary,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showCustomAmountDialog(
    BuildContext context,
    AppSupportController controller,
  ) {
    final formKey = GlobalKey<FormState>();
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text.rich(
          TextSpan(
            text: 'Enter Amount',
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ],
          ),
          style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            keyboardType: TextInputType.number,
            validator: (value) =>
                PValidator.validateRequiredPositiveNumber('Amount', value),
            decoration: InputDecoration(
              hintText: 'Enter amount in PKR',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: PColors.primary),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD32F2F)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD32F2F)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;

              final amount = double.tryParse(textController.text.trim());
              if (amount != null && amount > 0) {
                controller.selectCustomAmount(amount);
                Get.back();
              } else {
                PLoaders.warningSnackBar(
                  title: 'Invalid Amount',
                  message: 'Please enter a valid amount',
                  context: context,
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ).whenComplete(textController.dispose);
  }
}

class _AmountSelectionError extends StatelessWidget {
  const _AmountSelectionError({required this.controller});

  final AppSupportController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showAmountError.value || controller.effectiveAmount > 0) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Amount is required.',
          style: GoogleFonts.roboto(
            color: const Color(0xFFD32F2F),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }
}

class _SelectedAmountBanner extends StatelessWidget {
  const _SelectedAmountBanner({required this.controller});

  final AppSupportController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final amount = controller.effectiveAmount;
      if (amount <= 0) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFE3D8)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF168861),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.isCustom.value
                      ? 'Custom amount selected'
                      : 'Amount selected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    color: const Color(0xFF09583F),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'PKR ${amount.toStringAsFixed(0)}',
                maxLines: 1,
                style: GoogleFonts.roboto(
                  color: const Color(0xFF09583F),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF52C29D),
            Color(0xFF159064),
            Color(0xFF075B42),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF55C39C), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF086247).withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _IslamicPatternPainter(
                color: Colors.white.withValues(alpha: 0.10),
                step: 54,
              ),
            ),
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Color(0xFFFFF4C8)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.nights_stay_rounded,
                        color: Color(0xFF168861),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Support Our Mission',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Help us keep Islamic tools free for everyone',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DividerLine(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.brightness_5_outlined,
                            color: Color(0xFFEAF7F2),
                            size: 18,
                          ),
                        ),
                        _DividerLine(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"The believer\'s shade on the Day of Resurrection will be his charity." - Prophet Muhammad (P.B.U.H) ',
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            const Color(0xFFEAF7F2),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.isRequired = false});

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
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ]
            : null,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.roboto(
        color: const Color(0xFF1F2426),
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
    );
  }
}

class _AmountGrid extends StatelessWidget {
  const _AmountGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final useSingleColumn = constraints.maxWidth < 340;
        final itemWidth = useSingleColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: 10,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 80,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEAF7F2) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? PColors.primary : const Color(0xFFDDE9E5),
              width: isSelected ? 1.3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C3F31).withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.brightness_5_outlined,
                  color: Color(0xFF09583F),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    color: const Color(0xFF09583F),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFEFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFBFE3D8),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C3F31).withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _IslamicPatternPainter(
                    color: PColors.primary.withValues(alpha: 0.045),
                    step: 42,
                  ),
                ),
              ),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 128,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F3ED),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0C3F31)
                                    .withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            color: const Color(0xFF168861),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            color: const Color(0xFF09583F),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            color: const Color(0xFF61656C),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportNote extends StatelessWidget {
  const _SupportNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFEFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFE3D8), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C3F31).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF2BA982),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your support keeps this app running. JazakAllah Khair \u{1F64C}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                color: const Color(0xFF5F646A),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  const _IslamicPatternPainter({
    required this.color,
    required this.step,
  });

  final Color color;
  final double step;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double x = -step; x < size.width + step; x += step) {
      for (double y = -step; y < size.height + step; y += step) {
        _drawRosette(canvas, Offset(x, y), step * 0.42, paint);
      }
    }
  }

  void _drawRosette(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = i * 0.78539816339;
      final dx = radius * 0.65 * math.cos(angle);
      final dy = radius * 0.65 * math.sin(angle);
      path
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(
          center.dx + dx,
          center.dy + dy,
          center.dx + radius * math.cos(angle + 0.39269908169),
          center.dy + radius * math.sin(angle + 0.39269908169),
        );
    }
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, radius * 0.18, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.step != step;
  }
}
