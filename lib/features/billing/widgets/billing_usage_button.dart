import 'dart:async';

import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/models/billing_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BillingUsageButton extends StatelessWidget {
  const BillingUsageButton({
    super.key,
    required this.featureKey,
    required this.featureLabel,
    this.unitLabel = 'uses',
    this.relatedUsageItems = const <BillingUsageItem>[],
  });

  final String featureKey;
  final String featureLabel;
  final String unitLabel;
  final List<BillingUsageItem> relatedUsageItems;

  @override
  Widget build(BuildContext context) {
    final BillingController controller = BillingController.instance;

    return Obx(() {
      final bool exhausted = controller.hasExhaustedQuota(featureKey) ||
          relatedUsageItems.any(
            (BillingUsageItem item) =>
                controller.hasExhaustedQuota(item.featureKey),
          );
      final Color surface =
          exhausted ? const Color(0xFF8F302B) : const Color(0xFF0A5948);

      return Tooltip(
        message: 'View usage',
        child: Material(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: () {
              unawaited(controller.loadBillingProfile());
              showBillingUsageSheet(
                context,
                featureKey: featureKey,
                featureLabel: featureLabel,
                unitLabel: unitLabel,
                relatedUsageItems: relatedUsageItems,
              );
            },
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    exhausted
                        ? Icons.hourglass_disabled_rounded
                        : Icons.bolt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Usage',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class BillingUsageItem {
  const BillingUsageItem({
    required this.featureKey,
    required this.featureLabel,
    required this.unitLabel,
    this.icon = Icons.bolt_rounded,
  });

  final String featureKey;
  final String featureLabel;
  final String unitLabel;
  final IconData icon;
}

Future<void> showBillingUsageSheet(
  BuildContext context, {
  required String featureKey,
  required String featureLabel,
  required String unitLabel,
  List<BillingUsageItem> relatedUsageItems = const <BillingUsageItem>[],
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => _BillingUsageSheet(
      featureKey: featureKey,
      featureLabel: featureLabel,
      unitLabel: unitLabel,
      relatedUsageItems: relatedUsageItems,
    ),
  );
}

class _BillingUsageSheet extends StatelessWidget {
  const _BillingUsageSheet({
    required this.featureKey,
    required this.featureLabel,
    required this.unitLabel,
    required this.relatedUsageItems,
  });

  final String featureKey;
  final String featureLabel;
  final String unitLabel;
  final List<BillingUsageItem> relatedUsageItems;

  @override
  Widget build(BuildContext context) {
    final BillingController controller = BillingController.instance;

    return Obx(() {
      final List<BillingUsageItem> usageItems = <BillingUsageItem>[
        BillingUsageItem(
          featureKey: featureKey,
          featureLabel: featureLabel,
          unitLabel: unitLabel,
        ),
        ...relatedUsageItems,
      ];
      final bool isLoading =
          controller.isProfileLoading.value && !controller.hasProfile;
      final bool hasUsageConfiguration = usageItems.any(
        (BillingUsageItem item) {
          final FeatureUsageModel? usage = controller.getUsage(item.featureKey);
          return controller.getEntitlement(item.featureKey) != null ||
              usage?.daily != null ||
              usage?.monthly != null;
        },
      );

      return Container(
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAF9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            18 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8C6C1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF18765D).withValues(alpha: 0.11),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFF18765D),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Your usage',
                          style: TextStyle(
                            color: Color(0xFF173D34),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          featureLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF687A74),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18765D).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      controller.isPro ? 'PRO' : 'FREE',
                      style: const TextStyle(
                        color: Color(0xFF18765D),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF52655F),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const _UsageLoadingCard()
              else if (!hasUsageConfiguration)
                const _UsageUnavailableCard()
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (int index = 0; index < usageItems.length; index++) ...[
                      if (index > 0) const SizedBox(height: 14),
                      _UsageFeatureSection(
                        item: usageItems[index],
                        usage:
                            controller.getUsage(usageItems[index].featureKey),
                        entitlement: controller.getEntitlement(
                          usageItems[index].featureKey,
                        ),
                        showHeading: usageItems.length > 1,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _UsageFeatureSection extends StatelessWidget {
  const _UsageFeatureSection({
    required this.item,
    required this.usage,
    required this.entitlement,
    required this.showHeading,
  });

  final BillingUsageItem item;
  final FeatureUsageModel? usage;
  final BillingEntitlementModel? entitlement;
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    final bool hasUsageConfiguration =
        entitlement != null || usage?.daily != null || usage?.monthly != null;
    final bool isAvailable = entitlement == null ||
        (entitlement!.enabled && entitlement!.upgradeRequired != true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showHeading) ...[
          Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF18765D).withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: const Color(0xFF18765D),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.featureLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF173D34),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isAvailable)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6D7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE7D7A0)),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Color(0xFF8A6A1B),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
        ],
        if (!hasUsageConfiguration)
          const _UsageUnavailableCard()
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _UsagePeriodCard(
                  label: 'Daily quota',
                  icon: Icons.today_rounded,
                  usage: usage?.daily,
                  configuredLimit: entitlement?.dailyLimit,
                  unitLabel: item.unitLabel,
                  isAvailable: isAvailable,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _UsagePeriodCard(
                  label: 'Monthly quota',
                  icon: Icons.calendar_month_rounded,
                  usage: usage?.monthly,
                  configuredLimit: entitlement?.monthlyLimit,
                  unitLabel: item.unitLabel,
                  isAvailable: isAvailable,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _UsagePeriodCard extends StatelessWidget {
  const _UsagePeriodCard({
    required this.label,
    required this.icon,
    required this.usage,
    required this.configuredLimit,
    required this.unitLabel,
    required this.isAvailable,
  });

  final String label;
  final IconData icon;
  final UsagePeriodModel? usage;
  final int? configuredLimit;
  final String unitLabel;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final int? limit = isAvailable ? usage?.limit ?? configuredLimit : null;
    final bool unlimited = limit == null;
    final int effectiveLimit = limit ?? 0;
    final int used = usage?.used ?? 0;
    final int remaining = unlimited
        ? 0
        : usage?.remaining ?? (effectiveLimit - used).clamp(0, effectiveLimit);
    final double usedProgress = unlimited || effectiveLimit <= 0
        ? 0
        : (used / effectiveLimit).clamp(0.0, 1.0);
    final bool exhausted = !unlimited && remaining <= 0;
    final Color accent = !isAvailable
        ? const Color(0xFF9A7412)
        : exhausted
            ? const Color(0xFFC2413B)
            : const Color(0xFF18765D);
    final String resetLabel = !isAvailable
        ? 'Available on Pro'
        : unlimited
            ? 'No reset needed'
            : _formatReset(usage?.resetAt, label);

    return Semantics(
      container: true,
      label: !isAvailable
          ? '$label, not included in the current plan.'
          : unlimited
              ? '$label, unlimited, no reset needed.'
              : '$label, $remaining $unitLabel left, $used of $limit used. '
                  '$resetLabel',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.12)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF173D34).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    !isAvailable
                        ? Icons.lock_outline_rounded
                        : unlimited
                            ? Icons.all_inclusive_rounded
                            : icon,
                    color: accent,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF48615A),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                !isAvailable
                    ? 'Not included'
                    : unlimited
                        ? 'Unlimited'
                        : '$remaining left',
                style: TextStyle(
                  color: accent,
                  fontSize: !isAvailable || unlimited ? 18 : 21,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              !isAvailable
                  ? 'Current plan'
                  : unlimited
                      ? 'No ${_periodName(label)} limit'
                      : unitLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF7A8A85),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: !isAvailable
                    ? 0
                    : unlimited
                        ? 1
                        : usedProgress,
                minHeight: 6,
                backgroundColor: accent.withValues(alpha: 0.10),
                valueColor: AlwaysStoppedAnimation<Color>(
                  !isAvailable
                      ? accent.withValues(alpha: 0.16)
                      : unlimited
                          ? accent.withValues(alpha: 0.22)
                          : accent,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              !isAvailable
                  ? 'Upgrade required'
                  : unlimited
                      ? 'No usage cap'
                      : '$used of $limit used',
              style: const TextStyle(
                color: Color(0xFF687A74),
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7F5),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    !isAvailable
                        ? Icons.workspace_premium_rounded
                        : Icons.schedule_rounded,
                    color: const Color(0xFF60776F),
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      resetLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF60776F),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatReset(DateTime? resetAt, String periodLabel) {
    if (resetAt == null) {
      return periodLabel.startsWith('Daily')
          ? 'Resets daily'
          : 'Resets monthly';
    }
    return 'Resets ${DateFormat('d MMM, h:mm a').format(resetAt.toLocal())}';
  }

  static String _periodName(String periodLabel) =>
      periodLabel.startsWith('Daily') ? 'daily' : 'monthly';
}

class _UsageLoadingCard extends StatelessWidget {
  const _UsageLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF18765D),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class _UsageUnavailableCard extends StatelessWidget {
  const _UsageUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.info_outline_rounded, color: Color(0xFF60776F), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Usage details are currently unavailable.',
              style: TextStyle(
                color: Color(0xFF52655F),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
