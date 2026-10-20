import 'dart:math' as math;

import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/helpers/billing_gate_helper.dart';
import 'package:ecommerce_app/features/digital_will/models/digital_will_response_model.dart';
import 'package:ecommerce_app/features/digital_will/controllers/pdf_generation_controller.dart';
import 'package:ecommerce_app/features/digital_will/screens/generate_pdf_bottom_sheet.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/controllers/external_service_controller.dart';
import 'package:ecommerce_app/common/models/country_model.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';

class DistributionResultScreen extends StatelessWidget {
  const DistributionResultScreen({
    super.key,
    this.response,
    required this.fallbackDeceasedName,
    required this.fallbackDistributableEstate,
    required this.fallbackAliveWivesCount,
    required this.fallbackHusbandAlive,
    required this.fallbackFatherAlive,
    required this.fallbackMotherAlive,
    required this.fallbackSonsCount,
    required this.fallbackDaughtersCount,
    this.onSave,
    this.onConvertPdf,
  });

  final DigitalWillCalculationResponse? response;
  final String fallbackDeceasedName;
  final double fallbackDistributableEstate;
  final int fallbackAliveWivesCount;
  final bool fallbackHusbandAlive;
  final bool fallbackFatherAlive;
  final bool fallbackMotherAlive;
  final int fallbackSonsCount;
  final int fallbackDaughtersCount;
  final Future<void> Function()? onSave;
  final Future<void> Function()? onConvertPdf;

  @override
  Widget build(BuildContext context) {
    if (response != null) {
      final DigitalWillCalculationResponse apiResponse = response!;
      final double estate =
          apiResponse.report.summary.finalEstateForDistribution;
      final List<_ShareEntry> shares = apiResponse.report.distribution
          .asMap()
          .entries
          .map(
            (entry) => _ShareEntry(
              label: entry.value.heirType,
              amount: entry.value.totalAmount,
              color: _shareColor(entry.key),
              ruleText: entry.value.notes ?? entry.value.fixedShare,
            ),
          )
          .toList();
      final double totalDistributed = apiResponse.report.totalDistributed;
      final double remainder =
          apiResponse.report.residueCalculation.finalResidue;

      return _ResponseView(
        response: apiResponse,
        deceasedName: apiResponse.basicInfo.fullName,
        estate: estate,
        totalDistributed: totalDistributed,
        shares: shares,
        remainder: remainder,
        warning: apiResponse.report.wasiyyahWarning,
        onConvertPdf: onConvertPdf,
      );
    }

    final _DistributionResult result = _FaraidEstimator(
      estate: fallbackDistributableEstate,
      aliveWivesCount: fallbackAliveWivesCount,
      husbandAlive: fallbackHusbandAlive,
      fatherAlive: fallbackFatherAlive,
      motherAlive: fallbackMotherAlive,
      sonsCount: fallbackSonsCount,
      daughtersCount: fallbackDaughtersCount,
    ).calculate();

    final double totalDistributed = result.shares.fold<double>(
      0,
      (double prev, _ShareEntry share) => prev + share.amount,
    );

    return _FallbackView(
      deceasedName: fallbackDeceasedName,
      distributableEstate: fallbackDistributableEstate,
      result: result,
      totalDistributed: totalDistributed,
      onConvertPdf: onConvertPdf,
    );
  }
}

class _ResponseView extends StatelessWidget {
  const _ResponseView({
    required this.response,
    required this.deceasedName,
    required this.estate,
    required this.totalDistributed,
    required this.shares,
    required this.remainder,
    required this.warning,
    required this.onConvertPdf,
  });

  final DigitalWillCalculationResponse response;
  final String deceasedName;
  final double estate;
  final double totalDistributed;
  final List<_ShareEntry> shares;
  final double remainder;
  final String? warning;
  final Future<void> Function()? onConvertPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Distribution Result',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFEAF5F1), Color(0xFFF8FBFA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroCard(
                      deceasedName: deceasedName,
                      estate: estate,
                      distributed: totalDistributed,
                      response: response,
                    ),
                    const SizedBox(height: 14),
                    _ChartCard(shares: shares),
                    const SizedBox(height: 14),
                    _SharesCard(
                      shares: shares,
                      estate: estate,
                      distribution: response.report.distribution,
                    ),
                    if (remainder > 0) ...[
                      const SizedBox(height: 12),
                      _InfoWarning(
                        message:
                            'Residue (${_formatCurrency(remainder, countryName: response.basicInfo.countryJurisdiction)}) distributed via: ${response.report.residueCalculation.method}',
                      ),
                    ],
                    if (warning != null) ...[
                      const SizedBox(height: 12),
                      _InfoWarning(message: warning!),
                    ],
                    const SizedBox(height: 14),
                    _HeirSummaryCard(heirSummary: response.report.heirSummary),
                    const SizedBox(height: 14),
                    if (response.report.blockedByRules.isNotEmpty) ...[
                      _BlockedTypesCard(
                        blockedByRules: response.report.blockedByRules,
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (response.report.validationNotes.isNotEmpty) ...[
                      _NotesCard(
                        title: 'Validation Notes',
                        notes: response.report.validationNotes,
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (response.report.calculationSteps.isNotEmpty) ...[
                      _NotesCard(
                        title: 'Calculation Steps',
                        notes: response.report.calculationSteps,
                      ),
                      const SizedBox(height: 14),
                    ],
                    _RoundingPolicyCard(
                      roundingPolicy: response.report.roundingPolicy,
                    ),
                    const SizedBox(height: 16),
                    _BottomActions(
                      onConvertPdf: onConvertPdf,
                      recordId: response.savedRecordId,
                      firebaseUserId: response.basicInfo.firebaseUserId,
                      deceasedName: response.basicInfo.fullName.isNotEmpty
                          ? response.basicInfo.fullName
                          : deceasedName,
                      countryName: response.basicInfo.countryJurisdiction,
                    ),
                    const SizedBox(height: 8),
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

class _FallbackView extends StatelessWidget {
  const _FallbackView({
    required this.deceasedName,
    required this.distributableEstate,
    required this.result,
    required this.totalDistributed,
    required this.onConvertPdf,
  });

  final String deceasedName;
  final double distributableEstate;
  final _DistributionResult result;
  final double totalDistributed;
  final Future<void> Function()? onConvertPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Distribution Result',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFEAF5F1), Color(0xFFF8FBFA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroCard(
                      deceasedName: deceasedName,
                      estate: distributableEstate,
                      distributed: totalDistributed,
                    ),
                    const SizedBox(height: 14),
                    _ChartCard(shares: result.shares),
                    const SizedBox(height: 14),
                    _SharesCard(
                      shares: result.shares,
                      estate: distributableEstate,
                      distribution: const [],
                    ),
                    if (result.unallocatedAmount > 0) ...[
                      const SizedBox(height: 12),
                      _InfoWarning(
                        message:
                            'Unallocated remainder: ${_formatCurrency(result.unallocatedAmount)}. Add more heir details to complete distribution.',
                      ),
                    ],
                    if (result.notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _NotesCard(notes: result.notes),
                    ],
                    const SizedBox(height: 16),
                    _BottomActions(
                      onConvertPdf: onConvertPdf,
                    ),
                    const SizedBox(height: 8),
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.deceasedName,
    required this.estate,
    required this.distributed,
    this.response,
  });

  final String deceasedName;
  final double estate;
  final double distributed;
  final DigitalWillCalculationResponse? response;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF114A3A), Color(0xFF2A7E66)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3428).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Faraid Distribution Report',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            response != null
                ? 'Estate owner: $deceasedName (${response!.report.caseType})'
                : 'Estate owner: $deceasedName',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFFDDF1EB),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  label: 'Distributable Estate',
                  value: _formatCurrency(estate,
                      countryName: response?.basicInfo.countryJurisdiction),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricPill(
                  label: 'Distributed Now',
                  value: _formatCurrency(distributed,
                      countryName: response?.basicInfo.countryJurisdiction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: const Color(0xFFDCF1EB),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.shares});

  final List<_ShareEntry> shares;

  @override
  Widget build(BuildContext context) {
    final double total = shares.fold<double>(
      0,
      (double value, _ShareEntry share) => value + share.amount,
    );

    return _CardShell(
      title: 'Visual Distribution',
      icon: Icons.pie_chart_outline_rounded,
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CustomPaint(
                      painter: _DonutChartPainter(shares: shares),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: const Color(0xFF58776C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatCurrency(total),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: const Color(0xFF174A3B),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final _ShareEntry share in shares)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _LegendLine(share: share, total: total),
            ),
        ],
      ),
    );
  }
}

class _LegendLine extends StatelessWidget {
  const _LegendLine({required this.share, required this.total});

  final _ShareEntry share;
  final double total;

  @override
  Widget build(BuildContext context) {
    final double ratio = total > 0 ? share.amount / total : 0;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: share.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            share.label,
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2A4B41),
            ),
          ),
        ),
        Text(
          '${(ratio * 100).toStringAsFixed(1)}%',
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3E655A),
          ),
        ),
      ],
    );
  }
}

class _SharesCard extends StatelessWidget {
  const _SharesCard({
    required this.shares,
    required this.estate,
    required this.distribution,
  });

  final List<_ShareEntry> shares;
  final double estate;
  final List<DigitalWillDistributionItemResponse> distribution;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Who Gets What',
      icon: Icons.groups_2_outlined,
      child: Column(
        children: [
          for (final _ShareEntry share in shares)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ShareTile(
                share: share,
                estate: estate,
              ),
            ),
        ],
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({required this.share, required this.estate});

  final _ShareEntry share;
  final double estate;

  @override
  Widget build(BuildContext context) {
    final double progress = estate > 0 ? (share.amount / estate) : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDEAE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  share.label,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF204338),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatCurrency(share.amount),
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: share.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 7,
              backgroundColor: const Color(0xFFE3EEE9),
              valueColor: AlwaysStoppedAnimation<Color>(share.color),
            ),
          ),
          if (share.ruleText.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              share.ruleText,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: const Color(0xFF55756A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes, this.title = 'Rule Notes'});

  final List<String> notes;
  final String title;

  @override
  Widget build(BuildContext context) {
    // Remove duplicates using Set
    final List<String> uniqueNotes = notes.toSet().toList();

    return _CardShell(
      title: title,
      icon: Icons.auto_awesome_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final String note in uniqueNotes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(0xFF4A6F63),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: const Color(0xFF36574D),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoWarning extends StatelessWidget {
  const _InfoWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECCB8E)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFF845C16),
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: const Color(0xFF6A4B14),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onConvertPdf,
    this.recordId,
    this.firebaseUserId,
    this.deceasedName,
    this.countryName,
  });

  final Future<void> Function()? onConvertPdf;
  final String? recordId;
  final String? firebaseUserId;
  final String? deceasedName;
  final String? countryName;

  Future<void> _openPdfBottomSheet(BuildContext context) async {
    if (!await BillingGateHelper.ensureFeatureAccess(
      BillingFeatureKeys.digitalWillPdfReport,
    )) {
      return;
    }

    if (!context.mounted) return;

    // Ensure the PdfGenerationController is registered
    if (!Get.isRegistered<PdfGenerationController>()) {
      Get.put(PdfGenerationController());
    }
    final PdfGenerationController pdfController =
        Get.find<PdfGenerationController>();

    // Resolve firebase user ID: use provided value, fallback to Firebase Auth
    String resolvedFirebaseUserId = firebaseUserId ?? '';
    if (resolvedFirebaseUserId.isEmpty) {
      resolvedFirebaseUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    }

    // Initialize with record data if available
    if (recordId != null &&
        recordId!.isNotEmpty &&
        resolvedFirebaseUserId.isNotEmpty) {
      pdfController.initializeForRecord(
        recordId: recordId!,
        firebaseUserId: resolvedFirebaseUserId,
        deceasedName: deceasedName,
        countryName: countryName,
      );
    }

    GeneratePdfBottomSheet.show(
      context,
      countryName: countryName,
      deceasedName: deceasedName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final BillingController billingController = BillingController.instance;

    return Obx(() {
      final bool enabled = onConvertPdf != null ||
          billingController.isFeatureEnabled(
            BillingFeatureKeys.digitalWillPdfReport,
          );

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () async {
            if (onConvertPdf != null) {
              await onConvertPdf!.call();
              return;
            }
            await _openPdfBottomSheet(context);
          },
          backgroundColor:
              enabled ? const Color(0xFF1A5B48) : const Color(0xFF6B7280),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          icon: Icon(
            enabled ? Icons.picture_as_pdf_rounded : Icons.lock_outline_rounded,
            size: 20,
          ),
          label: Text(
            enabled ? 'Generate PDF' : 'Unlock PDF Reports',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }
}

class _HeirSummaryCard extends StatelessWidget {
  const _HeirSummaryCard({required this.heirSummary});

  final DigitalWillHeirSummaryResponse heirSummary;

  @override
  Widget build(BuildContext context) {
    final List<String> summaryLines = [
      'Total Candidates: ${heirSummary.totalCandidates}',
      ...heirSummary.candidatesByType.entries
          .map((e) => '${e.key}: ${e.value}'),
    ];

    return _CardShell(
      title: 'Heir Summary',
      icon: Icons.family_restroom_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final String line in summaryLines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                line,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: const Color(0xFF36574D),
                ),
              ),
            ),
          if (heirSummary.excludedHeirs.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Excluded Heirs:',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: const Color(0xFF174A3B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              heirSummary.excludedHeirs.join(', '),
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: const Color(0xFF36574D),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlockedTypesCard extends StatelessWidget {
  const _BlockedTypesCard({required this.blockedByRules});

  final Map<String, List<String>> blockedByRules;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Blocked Heirs by Rules',
      icon: Icons.block_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final MapEntry<String, List<String>> entry
              in blockedByRules.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: const Color(0xFF174A3B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final String reason in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(color: Color(0xFF4A6F63)),
                          ),
                          Expanded(
                            child: Text(
                              reason,
                              style: GoogleFonts.roboto(
                                fontSize: 11,
                                color: const Color(0xFF36574D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundingPolicyCard extends StatelessWidget {
  const _RoundingPolicyCard({required this.roundingPolicy});

  final Map<String, dynamic> roundingPolicy;

  @override
  Widget build(BuildContext context) {
    final String method = roundingPolicy['method'] ?? 'standard';
    final dynamic adjustment = roundingPolicy['adjustment'] ?? 'N/A';

    return _CardShell(
      title: 'Rounding Policy',
      icon: Icons.calculate_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Method: ',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: const Color(0xFF174A3B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  method,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: const Color(0xFF36574D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Adjustment: ',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: const Color(0xFF174A3B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  adjustment.toString(),
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: const Color(0xFF36574D),
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

class _CardShell extends StatelessWidget {
  const _CardShell(
      {required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D3D2E).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF2D6A58)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C4035),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.shares});

  final List<_ShareEntry> shares;

  @override
  void paint(Canvas canvas, Size size) {
    final double total = shares.fold<double>(
      0,
      (double value, _ShareEntry share) => value + share.amount,
    );

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final Rect rect = Offset.zero & size;
    double startAngle = -math.pi / 2;

    if (total <= 0) {
      paint.color = const Color(0xFFDDEAE5);
      canvas.drawArc(rect.deflate(12), 0, math.pi * 2, false, paint);
      return;
    }

    for (final _ShareEntry share in shares) {
      final double sweep = (share.amount / total) * math.pi * 2;
      paint.color = share.color;
      canvas.drawArc(rect.deflate(12), startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.shares != shares;
  }
}

class _FaraidEstimator {
  _FaraidEstimator({
    required this.estate,
    required this.aliveWivesCount,
    required this.husbandAlive,
    required this.fatherAlive,
    required this.motherAlive,
    required this.sonsCount,
    required this.daughtersCount,
  });

  final double estate;
  final int aliveWivesCount;
  final bool husbandAlive;
  final bool fatherAlive;
  final bool motherAlive;
  final int sonsCount;
  final int daughtersCount;

  _DistributionResult calculate() {
    final List<_ShareEntry> shares = <_ShareEntry>[];
    final List<String> notes = <String>[];

    if (estate <= 0) {
      return _DistributionResult(
        shares: const <_ShareEntry>[],
        unallocatedAmount: 0,
        notes: const <String>[
          'No distributable estate amount found. Please verify assets, liabilities, and wasiyyah.',
        ],
      );
    }

    final bool hasChildren = sonsCount + daughtersCount > 0;

    double spouseFraction = 0;
    if (husbandAlive) {
      spouseFraction = hasChildren ? (1 / 4) : (1 / 2);
      notes.add(
        hasChildren
            ? 'Husband share applied: 1/4 (children exist).'
            : 'Husband share applied: 1/2 (no children).',
      );
    } else if (aliveWivesCount > 0) {
      spouseFraction = hasChildren ? (1 / 8) : (1 / 4);
      notes.add(
        hasChildren
            ? 'Wives collective share applied: 1/8 (children exist).'
            : 'Wives collective share applied: 1/4 (no children).',
      );
    }

    double motherFraction = 0;
    if (motherAlive) {
      motherFraction = hasChildren ? (1 / 6) : (1 / 3);
      notes.add(
        hasChildren
            ? 'Mother share applied: 1/6 (children exist).'
            : 'Mother share applied: 1/3 (no children).',
      );
    }

    double fatherFixedFraction = 0;
    if (fatherAlive && hasChildren) {
      fatherFixedFraction = 1 / 6;
      notes.add('Father fixed share applied: 1/6 (children exist).');
    }

    double daughtersFixedFraction = 0;
    if (sonsCount == 0 && daughtersCount > 0) {
      daughtersFixedFraction = daughtersCount == 1 ? (1 / 2) : (2 / 3);
      notes.add(
        daughtersCount == 1
            ? 'Single daughter fixed share applied: 1/2.'
            : 'Multiple daughters fixed share applied: 2/3 collectively.',
      );
    }

    double totalFixed = spouseFraction +
        motherFraction +
        fatherFixedFraction +
        daughtersFixedFraction;
    bool awlApplied = false;

    if (totalFixed > 1) {
      awlApplied = true;
      notes.add(
        'Fixed shares exceed estate; proportional adjustment (Awl) has been applied for this estimate.',
      );
      final double scale = 1 / totalFixed;
      spouseFraction *= scale;
      motherFraction *= scale;
      fatherFixedFraction *= scale;
      daughtersFixedFraction *= scale;
      totalFixed = 1;
    }

    if (husbandAlive && spouseFraction > 0) {
      shares.add(
        _ShareEntry(
          label: 'Husband',
          amount: estate * spouseFraction,
          color: const Color(0xFF1E6A55),
          ruleText: hasChildren ? 'Fixed share: 1/4' : 'Fixed share: 1/2',
        ),
      );
    }

    if (aliveWivesCount > 0 && spouseFraction > 0) {
      final double wivesAmount = estate * spouseFraction;
      final double eachWifeAmount = wivesAmount / aliveWivesCount;
      shares.add(
        _ShareEntry(
          label: 'Wives (collective)',
          amount: wivesAmount,
          color: const Color(0xFF32866D),
          ruleText:
              'Fixed share: ${hasChildren ? '1/8' : '1/4'}. Each wife receives ${_formatCurrency(eachWifeAmount)}.',
        ),
      );
    }

    if (motherAlive && motherFraction > 0) {
      shares.add(
        _ShareEntry(
          label: 'Mother',
          amount: estate * motherFraction,
          color: const Color(0xFF5A9B85),
          ruleText: hasChildren ? 'Fixed share: 1/6' : 'Fixed share: 1/3',
        ),
      );
    }

    if (fatherAlive && fatherFixedFraction > 0) {
      shares.add(
        _ShareEntry(
          label: 'Father (fixed part)',
          amount: estate * fatherFixedFraction,
          color: const Color(0xFF79A852),
          ruleText: 'Fixed share: 1/6',
        ),
      );
    }

    if (sonsCount == 0 && daughtersCount > 0 && daughtersFixedFraction > 0) {
      final double daughtersAmount = estate * daughtersFixedFraction;
      shares.add(
        _ShareEntry(
          label: 'Daughters (collective fixed)',
          amount: daughtersAmount,
          color: const Color(0xFFCC8A3B),
          ruleText:
              'Fixed share: ${daughtersCount == 1 ? '1/2' : '2/3'}. Each daughter receives ${_formatCurrency(daughtersAmount / daughtersCount)}.',
        ),
      );
    }

    final double fixedAmount = estate * totalFixed;
    double remainder = (estate - fixedAmount).clamp(0, estate);

    if (remainder > 0 && sonsCount > 0) {
      final int totalWeight = (sonsCount * 2) + daughtersCount;
      if (totalWeight > 0) {
        final double unit = remainder / totalWeight;
        final double sonsAmount = unit * (sonsCount * 2);
        final double daughtersAmount = unit * daughtersCount;

        shares.add(
          _ShareEntry(
            label: 'Sons (collective residuary)',
            amount: sonsAmount,
            color: const Color(0xFF4B8FCE),
            ruleText:
                'Residuary share. Each son gets 2 portions = ${_formatCurrency(unit * 2)}.',
          ),
        );

        if (daughtersCount > 0) {
          shares.add(
            _ShareEntry(
              label: 'Daughters (collective residuary)',
              amount: daughtersAmount,
              color: const Color(0xFF9B7BCD),
              ruleText:
                  'Residuary share with sons. Each daughter gets 1 portion = ${_formatCurrency(unit)}.',
            ),
          );
        }

        remainder = 0;
        notes.add(
          'Children residuary rule applied: each son receives twice the share of each daughter.',
        );
      }
    } else if (remainder > 0 && fatherAlive) {
      shares.add(
        _ShareEntry(
          label: 'Father (residuary part)',
          amount: remainder,
          color: const Color(0xFF8E784A),
          ruleText: 'Receives remaining estate as residuary heir.',
        ),
      );
      remainder = 0;
      notes.add('Father receives remaining estate as residuary heir.');
    }

    if (shares.isEmpty) {
      notes.add('No eligible heirs entered for automatic allocation.');
    }

    return _DistributionResult(
      shares: shares,
      unallocatedAmount: remainder,
      notes: notes,
      awlApplied: awlApplied,
    );
  }
}

class _DistributionResult {
  const _DistributionResult({
    required this.shares,
    required this.unallocatedAmount,
    required this.notes,
    this.awlApplied = false,
  });

  final List<_ShareEntry> shares;
  final double unallocatedAmount;
  final List<String> notes;
  final bool awlApplied;
}

class _ShareEntry {
  const _ShareEntry({
    required this.label,
    required this.amount,
    required this.color,
    this.ruleText = '',
  });

  final String label;
  final double amount;
  final Color color;
  final String ruleText;
}

Color _shareColor(int index) {
  const List<Color> palette = <Color>[
    Color(0xFF1E6A55),
    Color(0xFF32866D),
    Color(0xFF5A9B85),
    Color(0xFF79A852),
    Color(0xFFCC8A3B),
    Color(0xFF4B8FCE),
    Color(0xFF9B7BCD),
    Color(0xFF8E784A),
  ];

  return palette[index % palette.length];
}

String _formatCurrency(double value,
    {String? countryName, String? currencyCode}) {
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
  String code = currencyCode ?? '';

  // If caller didn't provide a country, try to use the draft basic info country
  if ((countryName == null || countryName.isEmpty) &&
      Get.isRegistered<DigitalWillController>()) {
    countryName =
        Get.find<DigitalWillController>().basicInfo?.countryJurisdiction;
  }

  if (Get.isRegistered<ExternalServiceController>()) {
    final ext = Get.find<ExternalServiceController>();
    Country? country;
    if (countryName != null && countryName.isNotEmpty) {
      country = ext.getCountryByName(countryName);
    }
    if (country != null) {
      if (country.currencies.isNotEmpty) {
        symbol = country.currencies.values.first;
        code = country.currencies.keys.first;
      }
      if (country.code.isNotEmpty) {
        flag = ExternalServiceController.flagEmojiFromCountryCode(country.code);
      }
    } else {
      if (code.isEmpty && Get.isRegistered<PdfGenerationController>()) {
        code = Get.find<PdfGenerationController>().selectedCurrency.value;
      }
      if (code.isNotEmpty) {
        final extSymbol = ext.findCurrencySymbolByCode(code);
        if (extSymbol != null) symbol = extSymbol;
      }
    }
  } else {
    if (code.isEmpty && Get.isRegistered<PdfGenerationController>()) {
      code = Get.find<PdfGenerationController>().selectedCurrency.value;
    }
  }

  if (symbol.isEmpty) {
    const Map<String, String> fallback = {
      'PKR': 'Rs',
      'SAR': 'SAR',
      'USD': '\$',
      'AED': 'AED',
      'GBP': '£',
      'EUR': '€',
      'INR': '₹'
    };
    if (code.isNotEmpty && fallback.containsKey(code)) {
      symbol = fallback[code]!;
    }
  }
  if (symbol.isEmpty) symbol = 'SAR';

  String result = '$symbol ${formatted.toString()}.$decimal';
  if (flag.isNotEmpty) {
    result = '$result $flag';
  }
  return result;
}
