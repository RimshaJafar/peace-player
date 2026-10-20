import 'dart:async';

import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/responsive/max_width_wrapper.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/widgets/billing_status_banner.dart';
import 'package:ecommerce_app/features/billing/widgets/billing_upgrade_dialog.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlanComparisonItem {
  final String feature;
  final String free;
  final String pro;

  const PlanComparisonItem({
    required this.feature,
    required this.free,
    required this.pro,
  });
}

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  static const _pageBackground = Color(0xFFF7FAF8);
  static const _deepGreen = Color(0xFF0C4D3D);
  static const _emerald = Color(0xFF329070);
  static const _softGreen = Color(0xFFEAF7F2);
  static const _gold = Color(0xFFD8B44B);
  static const _textDark = Color(0xFF173D34);
  static const _textMuted = Color(0xFF64726D);
  static const _border = Color(0xFFE0E9E5);

  static const List<String> _proBenefits = [
    '30 Peace Guider AI messages/day',
    'Premium fast AI responses',
    'Advanced Quran/Hadith RAG retrieval',
    '30 image queries/month',
    '30 voice inputs/day',
    '30 text-to-speech playbacks/day',
    '30 Quran Listening Agent requests/day',
    '100 boycott scans/month',
    '50 Digital Wills/month + 10 PDF reports/month',
    'Full chat and scan history',
    'Cleaner experience with no upgrade reminders',
  ];

  static const List<PlanComparisonItem> _comparisonItems = [
    PlanComparisonItem(
      feature: 'Quran Listening Agent',
      free: '3 requests/day, up to 90 requests/month',
      pro: '30 requests/day, up to 900 requests/month',
    ),
    PlanComparisonItem(
      feature: 'Peace Guider AI Chat',
      free:
          '3 AI messages/day, up to 90 messages/month, basic response quality',
      pro:
          '30 AI messages/day, up to 900 messages/month, faster premium responses',
    ),
    PlanComparisonItem(
      feature: 'Chat History',
      free: 'Last 5 chats saved',
      pro: 'Full chat history',
    ),
    PlanComparisonItem(
      feature: 'Image-Based AI Chat',
      free: '3 image queries/month',
      pro: '30 image queries/month',
    ),
    PlanComparisonItem(
      feature: 'Voice Input',
      free: '3 voice inputs/day, up to 90/month',
      pro: '30 voice inputs/day, up to 900/month',
    ),
    PlanComparisonItem(
      feature: 'Text-to-Speech Playback',
      free: '3 playbacks/day, up to 90/month',
      pro: '30 playbacks/day, up to 900/month',
    ),
    PlanComparisonItem(
      feature: 'Voice Navigation',
      free: 'Not available',
      pro: 'Full voice-assisted navigation',
    ),
    PlanComparisonItem(
      feature: 'Boycott Scanner',
      free: '5 image scans/month, last 5 scan records saved',
      pro: '100 image scans/month with full scan history',
    ),
    PlanComparisonItem(
      feature: 'Digital Will',
      free: '5 will generations/month and last 5 saved records',
      pro: '50 will generations/month with full saved history',
    ),
    PlanComparisonItem(
      feature: 'Digital Will PDF Report',
      free: 'Not available',
      pro: '10 reports/month',
    ),
    PlanComparisonItem(
      feature: 'Price',
      free: 'Free',
      pro: 'Monthly or yearly Pro pricing',
    ),
  ];

  static const List<String> _policyNotes = [
    'Daily limits reset at midnight UTC.',
    'Monthly limits reset at the start of the applicable billing period.',
    'Pro uses fair-use protection for expensive AI, voice, image, scanner, and PDF features.',
    'Upgrade prompts appear only when a locked feature or quota limit is reached.',
    'Digital Will is document-preparation assistance and not legal advice.',
  ];

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late final BillingController _billingController;

  @override
  void initState() {
    super.initState();
    _billingController = Get.isRegistered<BillingController>()
        ? Get.find<BillingController>()
        : Get.put(BillingController(), permanent: true);
    final String? checkoutSessionId = _checkoutSessionIdFromRoute();
    if (checkoutSessionId == null) {
      unawaited(_billingController.refreshBillingProfile());
    } else {
      unawaited(_billingController.confirmCheckoutSession(checkoutSessionId));
    }
  }

  String? _checkoutSessionIdFromRoute() {
    final String? sessionId =
        Get.parameters['session_id'] ?? Get.parameters['sessionId'];
    final String normalized = sessionId?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SubscriptionScreen._pageBackground,
      appBar: const PAppBar(
        title: Text(
          'Subscription',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      bottomNavigationBar: Obx(
        () => _UpgradeBottomBar(
          label: _bottomActionLabel(),
          icon: _billingController.isPro
              ? Icons.manage_accounts_rounded
              : Icons.workspace_premium_rounded,
          isLoading: _billingController.isStartingCheckout.value ||
              _billingController.isOpeningPortal.value,
          onPressed: _handleBottomAction,
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 420 ? 24.0 : 16.0;

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                24,
              ),
              children: [
                MaxWidthWrapper(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _PricingHeader(),
                      const SizedBox(height: 16),
                      const BillingStatusBanner(),
                      Obx(
                        () => _billingController.isProfileLoading.value &&
                                !_billingController.hasProfile
                            ? const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: LinearProgressIndicator(),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => _PriceCard(
                          isPro: _billingController.isPro,
                          monthlyPriceText:
                              _billingController.monthlyPriceText,
                          yearlyPriceText: _billingController.yearlyPriceText,
                          subscriptionStatus: _billingController
                              .billingProfile?.subscriptionStatus,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _BenefitsCard(
                          benefits: SubscriptionScreen._proBenefits),
                      const SizedBox(height: 16),
                      Obx(
                        () => _ComparisonAccordion(
                          items: _comparisonItemsForPricing(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _EthicalNoteCard(),
                      const SizedBox(height: 12),
                      const _PolicyNotesCard(
                          notes: SubscriptionScreen._policyNotes),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _bottomActionLabel() {
    if (_billingController.isPastDue &&
        _billingController.canManageSubscription) {
      return 'Update Payment Method';
    }
    if (_billingController.isPro) return 'Manage Subscription';
    if (_billingController.isExpired &&
        _billingController.hasPreviousStripeSubscription) {
      return 'Renew Pro';
    }
    return 'Upgrade to Pro';
  }

  Future<void> _handleBottomAction() async {
    if ((_billingController.isPro || _billingController.isPastDue) &&
        _billingController.canManageSubscription) {
      await _billingController.openCustomerPortal();
      return;
    }
    showBillingPlanPicker();
  }

  List<PlanComparisonItem> _comparisonItemsForPricing() {
    return SubscriptionScreen._comparisonItems.map((PlanComparisonItem item) {
      if (item.feature != 'Price') return item;
      return PlanComparisonItem(
        feature: item.feature,
        free: _billingController.freePriceText,
        pro: _billingController.proPriceComparisonText,
      );
    }).toList(growable: false);
  }
}

class _PricingHeader extends StatelessWidget {
  const _PricingHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: PColors.linearGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: SubscriptionScreen._deepGreen.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'PeacePlayer Pro',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Unlock advanced AI-powered Islamic guidance.',
                  style: TextStyle(
                    color: Color(0xFFE9FFF8),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: SubscriptionScreen._gold,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.isPro,
    required this.monthlyPriceText,
    required this.yearlyPriceText,
    this.subscriptionStatus,
  });

  final bool isPro;
  final String monthlyPriceText;
  final String yearlyPriceText;
  final String? subscriptionStatus;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SubscriptionScreen._softGreen,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: SubscriptionScreen._deepGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pro Plan',
                      style: TextStyle(
                        color: SubscriptionScreen._textDark,
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Simple ethical pricing for advanced tools',
                      style: TextStyle(
                        color: SubscriptionScreen._textMuted,
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              isPro ? const _CurrentPlanBadge() : const _BestValueBadge(),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            monthlyPriceText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SubscriptionScreen._deepGreen,
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 34,
                height: 2,
                decoration: BoxDecoration(
                  color: SubscriptionScreen._gold,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'or $yearlyPriceText',
                  style: const TextStyle(
                    color: SubscriptionScreen._textMuted,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _BestValueBadge extends StatelessWidget {
  const _BestValueBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6D7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE9CB73)),
      ),
      child: const Text(
        'Best Value',
        style: TextStyle(
          color: Color(0xFF7A5A08),
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CurrentPlanBadge extends StatelessWidget {
  const _CurrentPlanBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF8DCFB7)),
      ),
      child: const Text(
        'Current Plan',
        style: TextStyle(
          color: SubscriptionScreen._deepGreen,
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  final List<String> benefits;

  const _BenefitsCard({required this.benefits});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pro benefits',
            style: TextStyle(
              color: SubscriptionScreen._textDark,
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            benefits.length,
            (index) => Column(
              children: [
                _BenefitRow(text: benefits[index]),
                if (index != benefits.length - 1)
                  Divider(
                    height: 14,
                    thickness: 1,
                    color: SubscriptionScreen._border.withValues(alpha: 0.70),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;

  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.check_circle_rounded,
            color: SubscriptionScreen._emerald,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: SubscriptionScreen._textDark,
              fontFamily: 'Poppins',
              fontSize: 13.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ComparisonAccordion extends StatelessWidget {
  final List<PlanComparisonItem> items;

  const _ComparisonAccordion({required this.items});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
          iconColor: SubscriptionScreen._deepGreen,
          collapsedIconColor: SubscriptionScreen._deepGreen,
          title: const Text(
            'Compare Free vs Pro',
            style: TextStyle(
              color: SubscriptionScreen._textDark,
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            ...items.map((item) => _ComparisonRow(item: item)),
            const SizedBox(height: 4),
            const _DigitalWillDisclaimer(),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final PlanComparisonItem item;

  const _ComparisonRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SubscriptionScreen._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.feature,
            style: const TextStyle(
              color: SubscriptionScreen._textDark,
              fontFamily: 'Poppins',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          _PlanDetailLine(
            label: 'Free',
            value: item.free,
            labelColor: const Color(0xFF586863),
            backgroundColor: const Color(0xFFF0F4F2),
          ),
          const SizedBox(height: 8),
          _PlanDetailLine(
            label: 'Pro',
            value: item.pro,
            labelColor: SubscriptionScreen._deepGreen,
            backgroundColor: SubscriptionScreen._softGreen,
          ),
        ],
      ),
    );
  }
}

class _PlanDetailLine extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color backgroundColor;

  const _PlanDetailLine({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: SubscriptionScreen._textMuted,
              fontFamily: 'Poppins',
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _DigitalWillDisclaimer extends StatelessWidget {
  const _DigitalWillDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7D7A0)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF9A7412),
            size: 18,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Digital Will provides educational and document-preparation assistance and is not legal advice.',
              style: TextStyle(
                color: Color(0xFF725813),
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EthicalNoteCard extends StatelessWidget {
  const _EthicalNoteCard();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(15),
      backgroundColor: const Color(0xFFF0FAF6),
      borderColor: const Color(0xFFD7ECE4),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.volunteer_activism_rounded,
            color: SubscriptionScreen._deepGreen,
            size: 22,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Core Quran, Hadith, worship, prayer, Kids, and Seerah features remain accessible for everyone. Pro supports advanced AI, voice, image, scanner, and secure digital services.',
              style: TextStyle(
                color: SubscriptionScreen._textDark,
                fontFamily: 'Poppins',
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyNotesCard extends StatelessWidget {
  final List<String> notes;

  const _PolicyNotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Billing notes',
            style: TextStyle(
              color: SubscriptionScreen._textDark,
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...notes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 7),
                    decoration: const BoxDecoration(
                      color: SubscriptionScreen._gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                        color: SubscriptionScreen._textMuted,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeBottomBar extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final bool isLoading;

  const _UpgradeBottomBar({
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  SubscriptionScreen._deepGreen,
                  SubscriptionScreen._emerald,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: SubscriptionScreen._deepGreen.withValues(alpha: 0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Color(0xFFFFF4C7),
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    if (isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    if (!isLoading) ...[
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
    this.borderColor = SubscriptionScreen._border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
