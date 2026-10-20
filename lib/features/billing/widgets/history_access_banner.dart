import 'dart:async';

import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/widgets/billing_upgrade_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryAccessBanner extends StatefulWidget {
  const HistoryAccessBanner({
    super.key,
    required this.freeLabel,
    required this.proLabel,
    required this.upgradeMessage,
    this.freeDescription,
    this.proDescription,
    this.margin = EdgeInsets.zero,
    this.accentColor = const Color(0xFF329070),
  });

  final String freeLabel;
  final String proLabel;
  final String upgradeMessage;
  final String? freeDescription;
  final String? proDescription;
  final EdgeInsetsGeometry margin;
  final Color accentColor;

  @override
  State<HistoryAccessBanner> createState() => _HistoryAccessBannerState();
}

class _HistoryAccessBannerState extends State<HistoryAccessBanner> {
  late final BillingController _billingController;

  @override
  void initState() {
    super.initState();
    _billingController = Get.isRegistered<BillingController>()
        ? Get.find<BillingController>()
        : Get.put(BillingController(), permanent: true);
    unawaited(_billingController.loadBillingProfile());
  }

  void _showUpgradeDialog() {
    if (_billingController.isPastDue) {
      showBillingUpgradeDialog(
        title: 'Payment issue',
        message:
            'Your payment could not be completed. Your account is currently using the Free Plan.',
        showManageSubscription: _billingController.canManageSubscription,
      );
      return;
    }

    if (_billingController.isExpired &&
        _billingController.hasPreviousStripeSubscription) {
      showBillingUpgradeDialog(
        title: 'Subscription expired',
        message:
            'Your Pro subscription has expired. Renew to continue Pro access.',
      );
      return;
    }

    showBillingUpgradeDialog(
      title: 'Unlock full history',
      message: widget.upgradeMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isPro = _billingController.isPro;
      final bool isLoading = _billingController.isProfileLoading.value &&
          !_billingController.hasProfile;
      final String label = isPro ? widget.proLabel : widget.freeLabel;
      final String detail = isPro
          ? widget.proDescription ?? 'Your full history is available.'
          : widget.freeDescription ?? 'Upgrade to see your complete history.';
      final Color titleColor =
          isPro ? const Color(0xFF174A3B) : const Color(0xFF263B35);

      return Semantics(
        container: true,
        button: !isPro,
        label: '$label. $detail',
        child: Container(
          margin: widget.margin,
          padding: const EdgeInsets.fromLTRB(11, 10, 10, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                widget.accentColor.withValues(alpha: 0.10),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.accentColor.withValues(alpha: 0.16),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF163E33).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.20),
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  isPro ? Icons.done_all_rounded : Icons.history_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.11),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPro ? 'PRO' : 'FREE',
                            style: TextStyle(
                              color: widget.accentColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.45,
                            ),
                          ),
                        ),
                        if (isLoading) ...<Widget>[
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 11,
                            height: 11,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color: widget.accentColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1.15,
                        color: Color(0xFF60776F),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isPro) ...<Widget>[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _showUpgradeDialog,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: widget.accentColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Unlock',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded, size: 13),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
