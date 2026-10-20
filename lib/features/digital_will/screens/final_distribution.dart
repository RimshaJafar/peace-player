import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';
import 'package:ecommerce_app/features/digital_will/screens/distribution_result.dart';
import 'package:ecommerce_app/features/digital_will/models/digital_will_request_model.dart';
import 'package:ecommerce_app/features/digital_will/models/digital_will_response_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/controllers/external_service_controller.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kGreen = Color(0xFF329070);
const Color _kGreenDark = Color(0xFF0F3A2D);
const Color _kGreenLight = Color(0xFF2E7D63);
const Color _kGreenFog = Color(0xFFEEF6F2);
const Color _kGreenMist = Color(0xFFD6EAE2);

const Color _kRust = Color(0xFF8E3D2A);
const Color _kRustLight = Color(0xFFFAEDE8);
const Color _kRustBorder = Color(0xFFE8C0B0);

const Color _kGold = Color(0xFF7A5614);
const Color _kGoldLight = Color(0xFFF5E6C0);
const Color _kGoldBorder = Color(0xFFDFC07A);

const Color _kPageBg = Color(0xFFF4F3EE);
const Color _kCardBg = Color(0xFFFFFFFF);
const Color _kCardBorder = Color(0xFFE8EDE9);

const Color _kInkDark = Color(0xFF1A2420);
const Color _kInkMid = Color(0xFF3A4D46);
const Color _kInkLight = Color(0xFF6B7E78);
const Color _kDivider = Color(0xFFE8EDE9);

// ─── Screen ───────────────────────────────────────────────────────────────────
class FinalDistributionScreen extends StatelessWidget {
  const FinalDistributionScreen({
    super.key,
    this.summary,
    this.onEdit,
    this.onCalculateDistribution,
  });

  final FinalSummaryData? summary;
  final VoidCallback? onEdit;
  final Future<void> Function()? onCalculateDistribution;

  FinalSummaryData get _summaryData => summary ?? FinalSummaryData.sample();

  FinalSummaryData _buildSummaryFromController(
      DigitalWillController controller) {
    final Step1BasicInfoRequest? basicInfo = controller.basicInfo;
    final Step2AssetsRequest? assets = controller.assets;
    final Step3LiabilitiesRequest? liabilities = controller.liabilities;
    final Step4WasiyyahRequest? wasiyyah = controller.wasiyyah;
    final Step5HeirsRequest? heirs = controller.heirs;

    if (basicInfo == null ||
        assets == null ||
        liabilities == null ||
        wasiyyah == null ||
        heirs == null) {
      return FinalSummaryData.sample();
    }

    final double totalAssets = _sumAssetGroup(assets.realEstate) +
        _sumAssetGroup(assets.vehicles) +
        _sumAssetGroup(assets.financialAssets) +
        _sumAssetGroup(assets.businessAssets) +
        _sumAssetGroup(assets.preciousMetals) +
        _sumAssetGroup(assets.otherAssets);

    final double totalDebts = _sumLiabilityGroup(liabilities.debts);
    final double mahrDue = _sumLiabilityGroup(liabilities.mahrDue);
    final double funeralExpenses =
        _sumLiabilityGroup(liabilities.funeralExpenses);
    final double totalLiabilities = totalDebts + mahrDue + funeralExpenses;
    final double netEstate = totalAssets - totalLiabilities;

    return FinalSummaryData(
      basicInfo: BasicInformation(
        fullName: basicInfo.fullName,
        gender: basicInfo.gender,
        dateOfBirth: basicInfo.dateOfBirth,
        dateOfDeath: basicInfo.dateOfDeath,
        maritalStatus: heirs.maritalStatus,
        numberOfWives: heirs.wivesCount,
        executorName: basicInfo.executorName,
        executorContact: basicInfo.executorContact,
      ),
      assets: AssetsSummary(
        realEstateTotal: _sumAssetGroup(assets.realEstate),
        vehiclesTotal: _sumAssetGroup(assets.vehicles),
        financialAssetsTotal: _sumAssetGroup(assets.financialAssets),
        businessAssetsTotal: _sumAssetGroup(assets.businessAssets),
        preciousMetalsTotal: _sumAssetGroup(assets.preciousMetals),
        otherAssetsTotal: _sumAssetGroup(assets.otherAssets),
      ),
      liabilities: LiabilitiesSummary(
        totalDebts: totalDebts,
        mahrDue: mahrDue,
        funeralExpenses: funeralExpenses,
      ),
      wasiyyah: wasiyyah.hasWasiyyah
          ? WasiyyahDetails(
              type: wasiyyah.wasiyyahType,
              totalAmount: wasiyyah.totalWasiyyahAmount,
              beneficiaries: wasiyyah.beneficiaries
                  .map(
                    (beneficiary) => WasiyyahBeneficiary(
                      name: beneficiary.name,
                      amount: beneficiary.amount,
                      percentage: beneficiary.percentage,
                    ),
                  )
                  .toList(),
            )
          : null,
      heirs: HeirsSummary(
        aliveWivesCount:
            heirs.wifeStatuses.where((status) => status == 'alive').length,
        husbandAlive: basicInfo.gender.toLowerCase() == 'female' &&
            heirs.maritalStatus == 'Married',
        fatherAlive: heirs.fatherAlive,
        motherAlive: heirs.motherAlive,
        sonsCount: heirs.sons,
        daughtersCount: heirs.daughters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DigitalWillController controller = Get.find<DigitalWillController>();
    final FinalSummaryData data =
        summary ?? _buildSummaryFromController(controller);

    final double totalAssets = data.assets.totalAssets;
    final double totalLiabilities = data.liabilities.totalLiabilities;
    final double netEstate = totalAssets - totalLiabilities;
    final double wasiyyahApplied = data.wasiyyah?.totalAmount ?? 0;
    final double finalEstateForDistribution = netEstate - wasiyyahApplied;
    final bool hasWasiyyah = data.wasiyyah?.hasData == true;

    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Final Summary',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      backgroundColor: _kPageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _StepProgress(currentStep: 6, totalSteps: 6),
                  const SizedBox(height: 24),
                  const _HeroMessageCard(),
                  const SizedBox(height: 24),
                  _BasicInformationCard(basicInfo: data.basicInfo),
                  if (data.assets.hasAnyData) ...[
                    const SizedBox(height: 20),
                    _AssetsSummaryCard(assets: data.assets),
                  ],
                  if (data.liabilities.hasAnyData) ...[
                    const SizedBox(height: 20),
                    _LiabilitiesCard(liabilities: data.liabilities),
                  ],
                  if (hasWasiyyah) ...[
                    const SizedBox(height: 20),
                    _WasiyyahDetailsCard(wasiyyah: data.wasiyyah!),
                  ],
                  const SizedBox(height: 20),
                  _EstateCalculationCard(
                    totalAssets: totalAssets,
                    totalLiabilities: totalLiabilities,
                    netEstate: netEstate,
                    wasiyyahApplied: wasiyyahApplied,
                    finalEstateForDistribution: finalEstateForDistribution,
                  ),
                  if (data.heirs.hasRelevantHeirs) ...[
                    const SizedBox(height: 20),
                    _HeirsSummaryCard(heirs: data.heirs),
                  ],
                  const SizedBox(height: 20),
                  const _ReadyForCalculationCard(),
                  const SizedBox(height: 32),
                  _ActionButtons(
                    onEdit: onEdit,
                    onCalculateDistribution: onCalculateDistribution,
                    summaryData: data,
                    finalEstateForDistribution: finalEstateForDistribution,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero Card ────────────────────────────────────────────────────────────────
class _HeroMessageCard extends StatelessWidget {
  const _HeroMessageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kGreenDark, _kGreenLight],
          stops: [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: _kGreenDark.withOpacity(0.32),
            blurRadius: 40,
            spreadRadius: -6,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: _kGreenDark.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative top accent line
          Container(
            width: 40,
            height: 3,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Text(
            'Final Summary\n& Review',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.08,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white.withOpacity(0.18),
          ),
          const SizedBox(height: 14),
          Text(
            'Review all collected inputs before running\nFaraid distribution calculation.',
            style: GoogleFonts.roboto(
              fontSize: 14.5,
              color: Colors.white.withOpacity(0.78),
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Shell (card with green header) ───────────────────────────────────
class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kGreenDark.withOpacity(0.06),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _kGreenDark.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Green Header Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: const BoxDecoration(
              color: _kGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Body ──
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── Summary Line ─────────────────────────────────────────────────────────────
class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: emphasize ? 16.5 : 15.5,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
                color: _kInkLight,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.roboto(
                fontSize: emphasize ? 17 : 15,
                fontWeight: FontWeight.w700,
                color: valueColor ?? _kInkDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Total Bar ────────────────────────────────────────────────────────────────
class _TotalBar extends StatelessWidget {
  const _TotalBar({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    this.borderColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor ?? color.withOpacity(0.22),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.1,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Basic Information Card ───────────────────────────────────────────────────
class _BasicInformationCard extends StatelessWidget {
  const _BasicInformationCard({required this.basicInfo});

  final BasicInformation basicInfo;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Basic Information',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _SummaryLine(label: 'Full Name', value: basicInfo.fullName),
          const _BodyDivider(),
          _SummaryLine(label: 'Gender', value: _capitalize(basicInfo.gender)),
          const _BodyDivider(),
          _SummaryLine(label: 'Date of Birth', value: basicInfo.dateOfBirth),
          const _BodyDivider(),
          _SummaryLine(label: 'Date of Death', value: basicInfo.dateOfDeath),
          const _BodyDivider(),
          _SummaryLine(label: 'Marital Status', value: basicInfo.maritalStatus),
          if (basicInfo.gender.toLowerCase() == 'male' &&
              basicInfo.numberOfWives != null) ...[
            const _BodyDivider(),
            _SummaryLine(
              label: 'Number of Wives',
              value: basicInfo.numberOfWives.toString(),
            ),
          ],
          const _BodyDivider(),
          _SummaryLine(label: 'Executor Name', value: basicInfo.executorName),
          const _BodyDivider(),
          _SummaryLine(
              label: 'Executor Contact', value: basicInfo.executorContact),
        ],
      ),
    );
  }
}

// ─── Assets Summary Card ──────────────────────────────────────────────────────
class _AssetsSummaryCard extends StatelessWidget {
  const _AssetsSummaryCard({required this.assets});

  final AssetsSummary assets;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Assets Summary',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        children: [
          if (assets.realEstateTotal > 0) ...[
            _SummaryLine(
              label: 'Real Estate',
              value: _formatCurrency(assets.realEstateTotal),
            ),
            const _BodyDivider(),
          ],
          if (assets.vehiclesTotal > 0) ...[
            _SummaryLine(
              label: 'Vehicles',
              value: _formatCurrency(assets.vehiclesTotal),
            ),
            const _BodyDivider(),
          ],
          if (assets.financialAssetsTotal > 0) ...[
            _SummaryLine(
              label: 'Financial Assets',
              value: _formatCurrency(assets.financialAssetsTotal),
            ),
            const _BodyDivider(),
          ],
          if (assets.businessAssetsTotal > 0) ...[
            _SummaryLine(
              label: 'Business Assets',
              value: _formatCurrency(assets.businessAssetsTotal),
            ),
            const _BodyDivider(),
          ],
          if (assets.preciousMetalsTotal > 0) ...[
            _SummaryLine(
              label: 'Precious Metals',
              value: _formatCurrency(assets.preciousMetalsTotal),
            ),
            const _BodyDivider(),
          ],
          if (assets.otherAssetsTotal > 0) ...[
            _SummaryLine(
              label: 'Other Assets',
              value: _formatCurrency(assets.otherAssetsTotal),
            ),
            const _BodyDivider(),
          ],
          const SizedBox(height: 6),
          _TotalBar(
            label: 'Total Assets',
            value: _formatCurrency(assets.totalAssets),
            color: _kGreen,
            bgColor: _kGreenFog,
            borderColor: _kGreenMist,
          ),
        ],
      ),
    );
  }
}

// ─── Liabilities Card ─────────────────────────────────────────────────────────
class _LiabilitiesCard extends StatelessWidget {
  const _LiabilitiesCard({required this.liabilities});

  final LiabilitiesSummary liabilities;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Liabilities',
      icon: Icons.trending_down_rounded,
      child: Column(
        children: [
          if (liabilities.totalDebts > 0) ...[
            _SummaryLine(
              label: 'Total Debts',
              value: _formatCurrency(liabilities.totalDebts),
              valueColor: _kRust,
            ),
            const _BodyDivider(),
          ],
          if (liabilities.mahrDue > 0) ...[
            _SummaryLine(
              label: 'Mahr Due',
              value: _formatCurrency(liabilities.mahrDue),
              valueColor: _kRust,
            ),
            const _BodyDivider(),
          ],
          if (liabilities.funeralExpenses > 0) ...[
            _SummaryLine(
              label: 'Funeral Expenses',
              value: _formatCurrency(liabilities.funeralExpenses),
              valueColor: _kRust,
            ),
            const _BodyDivider(),
          ],
          const SizedBox(height: 6),
          _TotalBar(
            label: 'Total Liabilities',
            value: _formatCurrency(liabilities.totalLiabilities),
            color: _kRust,
            bgColor: _kRustLight,
            borderColor: _kRustBorder,
          ),
        ],
      ),
    );
  }
}

// ─── Estate Calculation Card ──────────────────────────────────────────────────
class _EstateCalculationCard extends StatelessWidget {
  const _EstateCalculationCard({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netEstate,
    required this.wasiyyahApplied,
    required this.finalEstateForDistribution,
  });

  final double totalAssets;
  final double totalLiabilities;
  final double netEstate;
  final double wasiyyahApplied;
  final double finalEstateForDistribution;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Estate Calculation',
      icon: Icons.calculate_outlined,
      child: Column(
        children: [
          _SummaryLine(
            label: 'Net Estate (Assets − Liabilities)',
            value: _formatCurrency(netEstate),
            valueColor: const Color(0xFF1D4F40),
          ),
          const _BodyDivider(),
          _SummaryLine(
            label: 'Wasiyyah Applied',
            value: _formatCurrency(wasiyyahApplied),
            valueColor: _kGold,
          ),
          const SizedBox(height: 10),
          _TotalBar(
            label: 'Final Estate for Distribution',
            value: _formatCurrency(finalEstateForDistribution),
            color: _kGreen,
            bgColor: _kGreenFog,
            borderColor: _kGreenMist,
          ),
        ],
      ),
    );
  }
}

// ─── Wasiyyah Card ────────────────────────────────────────────────────────────
class _WasiyyahDetailsCard extends StatelessWidget {
  const _WasiyyahDetailsCard({required this.wasiyyah});

  final WasiyyahDetails wasiyyah;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Wasiyyah',
      icon: Icons.description_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryLine(label: 'Type', value: _capitalize(wasiyyah.type)),
          if (wasiyyah.beneficiaries.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _kGold,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Beneficiaries',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kGold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final WasiyyahBeneficiary beneficiary
                in wasiyyah.beneficiaries)
              _BeneficiaryLine(beneficiary: beneficiary),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              'No beneficiaries specified.',
              style: GoogleFonts.roboto(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: _kInkLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Heirs Summary Card ───────────────────────────────────────────────────────
class _HeirsSummaryCard extends StatelessWidget {
  const _HeirsSummaryCard({required this.heirs});

  final HeirsSummary heirs;

  @override
  Widget build(BuildContext context) {
    final List<String> lines = heirs.relevantHeirsLines;

    return _SectionShell(
      title: 'Heirs Summary',
      icon: Icons.groups_2_outlined,
      child: Column(
        children: [
          for (int i = 0; i < lines.length; i++) ...[
            _HeirLine(value: lines[i]),
            if (i != lines.length - 1) const _BodyDivider(),
          ],
        ],
      ),
    );
  }
}

// ─── Heir Line (replaces _SummaryLine for heirs for better visual) ─────────────
class _HeirLine extends StatelessWidget {
  const _HeirLine({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    // value is like "Wife: 1 (Alive)" or "Sons: 2"
    final parts = value.split(':');
    final label = parts.isNotEmpty ? parts.first.trim() : value;
    final detail = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _kGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                color: _kInkLight,
              ),
            ),
          ),
          Text(
            detail,
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kInkDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ready For Calculation Card ───────────────────────────────────────────────
class _ReadyForCalculationCard extends StatelessWidget {
  const _ReadyForCalculationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kGreenFog,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kGreenMist, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kGreen.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: _kGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'All required information has been collected. You can now proceed to calculate the inheritance distribution.',
              style: GoogleFonts.roboto(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 62, 113, 96),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onEdit,
    required this.onCalculateDistribution,
    required this.summaryData,
    required this.finalEstateForDistribution,
  });

  final VoidCallback? onEdit;
  final Future<void> Function()? onCalculateDistribution;
  final FinalSummaryData summaryData;
  final double finalEstateForDistribution;

  @override
  Widget build(BuildContext context) {
    final DigitalWillController controller = Get.find<DigitalWillController>();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stacked = constraints.maxWidth < 420;

        // ─── Edit Button ──────────────────────────────────────────────────────────────
        final Widget editButton = SizedBox(
          height: 58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E8D6F), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: _kGreenDark.withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onEdit ?? () => Navigator.of(context).pop(),
                splashColor: _kGreenFog,
                highlightColor: _kGreenFog.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: Color(0xFF1C5D4E),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C5D4E),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // ─── Calculate Distribution Button ───────────────────────────────────────────
        final Widget calculateButton = Obx(() {
          final bool isCalculating =
              onCalculateDistribution == null && controller.isSubmitting.value;

          return SizedBox(
            height: 58,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCalculating
                      ? const [
                          Color(0xFF75A895),
                          Color(0xFF4C7B6E),
                        ]
                      : const [
                          Color(0xFF2F8C6E),
                          Color(0xFF1C5D4E),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C5D4E).withOpacity(0.30),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFF1C5D4E).withOpacity(0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white.withOpacity(0.12),
                  highlightColor: Colors.white.withOpacity(0.06),
                  onTap: isCalculating
                      ? null
                      : () async {
                          if (onCalculateDistribution != null) {
                            await onCalculateDistribution!.call();
                            return;
                          }

                          final DigitalWillCalculationResponse? response =
                              await controller.submitDigitalWill();

                          if (response == null) {
                            if (!context.mounted) return;

                            final String? errorMessage =
                                controller.lastError.value;
                            if (errorMessage == null || errorMessage.isEmpty) {
                              return;
                            }

                            PLoaders.errorSnackBar(
                              title: 'Calculation Error',
                              message: errorMessage,
                              context: context,
                            );
                            return;
                          }

                          if (!context.mounted) return;

                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DistributionResultScreen(
                                response: response,
                                fallbackDeceasedName:
                                    summaryData.basicInfo.fullName,
                                fallbackDistributableEstate:
                                    finalEstateForDistribution < 0
                                        ? 0
                                        : finalEstateForDistribution,
                                fallbackAliveWivesCount:
                                    summaryData.heirs.aliveWivesCount,
                                fallbackHusbandAlive:
                                    summaryData.heirs.husbandAlive,
                                fallbackFatherAlive:
                                    summaryData.heirs.fatherAlive,
                                fallbackMotherAlive:
                                    summaryData.heirs.motherAlive,
                                fallbackSonsCount: summaryData.heirs.sonsCount,
                                fallbackDaughtersCount:
                                    summaryData.heirs.daughtersCount,
                              ),
                            ),
                          );
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isCalculating)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          const Icon(
                            Icons.auto_graph_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          isCalculating
                              ? 'Calculating...'
                              : 'Calculate Distribution',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              editButton,
              const SizedBox(height: 14),
              calculateButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 2, child: editButton),
            const SizedBox(width: 14),
            Expanded(flex: 3, child: calculateButton),
          ],
        );
      },
    );
  }
}

// ─── Beneficiary Line ─────────────────────────────────────────────────────────
class _BeneficiaryLine extends StatelessWidget {
  const _BeneficiaryLine({required this.beneficiary});

  final WasiyyahBeneficiary beneficiary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: _kGoldLight.withOpacity(0.42),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _kGoldBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _kGold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              beneficiary.name,
              style: GoogleFonts.roboto(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: _kInkDark,
              ),
            ),
          ),
          Text(
            beneficiary.percentage != null
                ? _formatPercentage(beneficiary.percentage!)
                : _formatCurrency(beneficiary.amount ?? 0),
            style: GoogleFonts.roboto(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: _kGold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step Progress ────────────────────────────────────────────────────────────
// ─── Step Progress ────────────────────────────────────────────────────────────
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final double progress = totalSteps == 0 ? 0 : currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kInkLight,
              ),
            ),
            Text(
              'Final Review',
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: _kGreenMist,
            valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
          ),
        ),
      ],
    );
  }
}

// ─── Body Divider ─────────────────────────────────────────────────────────────
class _BodyDivider extends StatelessWidget {
  const _BodyDivider();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 10),
        Divider(
          height: 1,
          thickness: 1,
          color: _kDivider,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

// ─── Helpers (unchanged logic) ────────────────────────────────────────────────
double _sumAssetGroup(List<DigitalWillAssetItemRequest> items) {
  return items.fold<double>(
    0,
    (double total, DigitalWillAssetItemRequest item) =>
        total + item.estimatedValue,
  );
}

double _sumLiabilityGroup(List<DigitalWillLiabilityItemRequest> items) {
  return items.fold<double>(
    0,
    (double total, DigitalWillLiabilityItemRequest item) =>
        total + item.estimatedValue,
  );
}

String _formatCurrency(double value) {
  final String fixed = value.toStringAsFixed(2);
  final List<String> parts = fixed.split('.');
  final String whole = parts.first;
  final String decimal = parts.last;

  final StringBuffer formatted = StringBuffer();
  for (int i = 0; i < whole.length; i++) {
    final int reverseIndex = whole.length - i;
    formatted.write(whole[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      formatted.write(',');
    }
  }

  String symbol = '';
  String flag = '';

  // Try to use selected country/currency when available
  if (Get.isRegistered<ExternalServiceController>() &&
      Get.isRegistered<DigitalWillController>()) {
    final ext = Get.find<ExternalServiceController>();
    final digital = Get.find<DigitalWillController>();
    final String? countryName = digital.basicInfo?.countryJurisdiction;
    if (countryName != null && countryName.isNotEmpty) {
      final country = ext.getCountryByName(countryName);
      if (country != null) {
        if (country.currencies.isNotEmpty) {
          symbol = country.currencies.values.first;
        }
        if (country.code.isNotEmpty) {
          flag =
              ExternalServiceController.flagEmojiFromCountryCode(country.code);
        }
      }
    }
  }

  if (symbol.isEmpty) symbol = 'SAR';

  final String valueStr = formatted.toString() + '.$decimal';
  if (flag.isNotEmpty) {
    return '$symbol $flag $valueStr';
  }
  return '$symbol $valueStr';
}

String _formatPercentage(double value) {
  final String formatted = value.toStringAsFixed(2);
  final String withoutTrailingZeros =
      formatted.replaceFirst(RegExp(r'\.?0+$'), '');
  return '$withoutTrailingZeros%';
}

String _capitalize(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

// ─── Data Models (unchanged) ──────────────────────────────────────────────────
class FinalSummaryData {
  const FinalSummaryData({
    required this.basicInfo,
    required this.assets,
    required this.liabilities,
    required this.heirs,
    this.wasiyyah,
  });

  final BasicInformation basicInfo;
  final AssetsSummary assets;
  final LiabilitiesSummary liabilities;
  final WasiyyahDetails? wasiyyah;
  final HeirsSummary heirs;

  factory FinalSummaryData.sample() {
    return FinalSummaryData(
      basicInfo: const BasicInformation(
        fullName: 'Abdul Rahman Ali',
        gender: 'male',
        dateOfBirth: '1968-04-19',
        dateOfDeath: '2026-03-18',
        maritalStatus: 'Married',
        numberOfWives: 1,
        executorName: 'Yusuf Ali',
        executorContact: '+966500000000',
      ),
      assets: const AssetsSummary(
        realEstateTotal: 640000,
        vehiclesTotal: 120000,
        financialAssetsTotal: 280000,
        businessAssetsTotal: 180000,
        preciousMetalsTotal: 45000,
        otherAssetsTotal: 35000,
      ),
      liabilities: const LiabilitiesSummary(
        totalDebts: 150000,
        mahrDue: 20000,
        funeralExpenses: 10000,
      ),
      wasiyyah: const WasiyyahDetails(
        type: 'partial',
        totalAmount: 150000,
        beneficiaries: [
          WasiyyahBeneficiary(name: 'Charity Foundation', amount: 100000),
          WasiyyahBeneficiary(name: 'Friend', amount: 50000),
        ],
      ),
      heirs: const HeirsSummary(
        aliveWivesCount: 1,
        husbandAlive: false,
        fatherAlive: true,
        motherAlive: true,
        sonsCount: 2,
        daughtersCount: 1,
      ),
    );
  }
}

class BasicInformation {
  const BasicInformation({
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.dateOfDeath,
    required this.maritalStatus,
    required this.executorName,
    required this.executorContact,
    this.numberOfWives,
  });

  final String fullName;
  final String gender;
  final String dateOfBirth;
  final String dateOfDeath;
  final String maritalStatus;
  final int? numberOfWives;
  final String executorName;
  final String executorContact;
}

class AssetsSummary {
  const AssetsSummary({
    this.realEstateTotal = 0,
    this.vehiclesTotal = 0,
    this.financialAssetsTotal = 0,
    this.businessAssetsTotal = 0,
    this.preciousMetalsTotal = 0,
    this.otherAssetsTotal = 0,
  });

  final double realEstateTotal;
  final double vehiclesTotal;
  final double financialAssetsTotal;
  final double businessAssetsTotal;
  final double preciousMetalsTotal;
  final double otherAssetsTotal;

  double get totalAssets =>
      realEstateTotal +
      vehiclesTotal +
      financialAssetsTotal +
      businessAssetsTotal +
      preciousMetalsTotal +
      otherAssetsTotal;

  bool get hasAnyData => totalAssets > 0;
}

class LiabilitiesSummary {
  const LiabilitiesSummary({
    this.totalDebts = 0,
    this.mahrDue = 0,
    this.funeralExpenses = 0,
  });

  final double totalDebts;
  final double mahrDue;
  final double funeralExpenses;

  double get totalLiabilities => totalDebts + mahrDue + funeralExpenses;

  bool get hasAnyData => totalLiabilities > 0;
}

class WasiyyahDetails {
  const WasiyyahDetails({
    required this.type,
    required this.totalAmount,
    this.beneficiaries = const [],
  });

  final String type;
  final double totalAmount;
  final List<WasiyyahBeneficiary> beneficiaries;

  bool get hasData => totalAmount > 0 || beneficiaries.isNotEmpty;
}

class WasiyyahBeneficiary {
  const WasiyyahBeneficiary({
    required this.name,
    this.amount,
    this.percentage,
  });

  final String name;
  final double? amount;
  final double? percentage;
}

class HeirsSummary {
  const HeirsSummary({
    this.aliveWivesCount = 0,
    this.husbandAlive = false,
    this.fatherAlive = false,
    this.motherAlive = false,
    this.sonsCount = 0,
    this.daughtersCount = 0,
  });

  final int aliveWivesCount;
  final bool husbandAlive;
  final bool fatherAlive;
  final bool motherAlive;
  final int sonsCount;
  final int daughtersCount;

  bool get hasRelevantHeirs => relevantHeirsLines.isNotEmpty;

  List<String> get relevantHeirsLines {
    final List<String> lines = [];
    if (aliveWivesCount > 0) lines.add('Wife: $aliveWivesCount (Alive)');
    if (husbandAlive) lines.add('Husband: Alive');
    if (fatherAlive) lines.add('Father: Alive');
    if (motherAlive) lines.add('Mother: Alive');
    if (sonsCount > 0) lines.add('Sons: $sonsCount');
    if (daughtersCount > 0) lines.add('Daughters: $daughtersCount');
    return lines;
  }
}
