import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/cards/worships_life_cards.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';
import 'package:ecommerce_app/features/digital_will/screens/basic_information.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/widgets/billing_usage_button.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'saved_wills_list.dart';

class DigitalWillLandingScreen extends StatelessWidget {
  const DigitalWillLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Digital Will',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
        actions: <Widget>[
          BillingUsageButton(
            featureKey: BillingFeatureKeys.digitalWill,
            featureLabel: 'Digital Will',
            unitLabel: 'wills',
            relatedUsageItems: <BillingUsageItem>[
              BillingUsageItem(
                featureKey: BillingFeatureKeys.digitalWillPdfReport,
                featureLabel: 'Digital Will PDF Reports',
                unitLabel: 'reports',
                icon: Icons.picture_as_pdf_rounded,
              ),
            ],
          ),
          SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ReferenceAyahHadithBox(
                    featureKey: 'will',
                    borderColor: Color(0xFF2E8D6F),
                    height: 240,
                    width: 560,
                  ),
                  const SizedBox(height: 30),
                  _ActionButton(
                    label: 'Calculate Wasiyyah',
                    icon: Icons.calculate_rounded,
                    filled: true,
                    onTap: () {
                      Get.find<DigitalWillController>().reset();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const BasicInformationScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: 'See Wills',
                    icon: Icons.folder_open_rounded,
                    filled: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SavedWillsListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget button = filled
        ? SizedBox(
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2F8C6E),
                    Color(0xFF1C5D4E),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C5D4E).withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(icon, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : SizedBox(
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2E8D6F), width: 2),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(icon, size: 20, color: const Color(0xFF1C5D4E)),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C5D4E),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );

    return SizedBox(width: double.infinity, child: button);
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4F675F),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF20473B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
