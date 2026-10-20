import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/digital_will/models/digital_will_response_model.dart';
import 'package:ecommerce_app/features/digital_will/controllers/pdf_generation_controller.dart';
import 'package:ecommerce_app/features/digital_will/screens/generate_pdf_bottom_sheet.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/helpers/billing_gate_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/controllers/external_service_controller.dart';
import 'package:ecommerce_app/common/models/country_model.dart';

String _formatCurrencyGlobal(double value,
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
  if (flag.isNotEmpty) result = '$result $flag';
  return result;
}

// Backwards-compatible helper used by widgets in this file
String _formatCurrency(double value,
    {String? countryName, String? currencyCode}) {
  return _formatCurrencyGlobal(value,
      countryName: countryName, currencyCode: currencyCode);
}

class SavedWillDetailScreen extends StatelessWidget {
  const SavedWillDetailScreen({
    required this.response,
    this.countryName,
    super.key,
  });

  final DigitalWillCalculationResponse response;
  final String? countryName;

  String _formatCurrency(double amount, {String? countryName}) {
    return _formatCurrencyGlobal(
      amount,
      countryName: countryName ??
          this.countryName ??
          response.basicInfo.countryJurisdiction,
    );
  }

  Color _shareColor(int index) {
    final List<Color> colors = <Color>[
      const Color(0xFF1A5B48),
      const Color(0xFF2A7E66),
      const Color(0xFF114A3A),
      const Color(0xFF3FA998),
      const Color(0xFF5AAAB5),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final String resolvedCountryName =
        countryName ?? response.basicInfo.countryJurisdiction;
    final double estate =
        response.report.summary.finalEstateForDistribution.toDouble();
    final List<_ShareEntry> shares = response.report.distribution
        .asMap()
        .entries
        .map(
          (entry) => _ShareEntry(
            label: entry.value.heirType,
            amount: entry.value.totalAmount.toDouble(),
            color: _shareColor(entry.key),
            ruleText: entry.value.notes ?? entry.value.fixedShare,
          ),
        )
        .toList();
    final double remainder =
        response.report.residueCalculation.finalResidue.toDouble();
    final double totalDistributed = response.report.totalDistributed.toDouble();

    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Will Details',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      floatingActionButton: _GeneratePdfFab(
        response: response,
        countryName: resolvedCountryName,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                      deceasedName: response.basicInfo.fullName,
                      estate: estate,
                      distributed: totalDistributed,
                      response: response,
                      countryName: resolvedCountryName,
                    ),
                    const SizedBox(height: 14),
                    SavedWillExecutorInfoCard(basicInfo: response.basicInfo),
                    const SizedBox(height: 14),
                    _ChartCard(
                        shares: shares, countryName: resolvedCountryName),
                    const SizedBox(height: 14),
                    _SharesCard(
                      shares: shares,
                      estate: estate,
                      distribution: response.report.distribution,
                      countryName: resolvedCountryName,
                    ),
                    if (remainder > 0) ...[
                      const SizedBox(height: 12),
                      _InfoWarning(
                        message:
                            'Residue (${_formatCurrency(remainder, countryName: resolvedCountryName)}) distributed via: ${response.report.residueCalculation.method}',
                      ),
                    ],
                    if (response.report.wasiyyahWarning != null) ...[
                      const SizedBox(height: 12),
                      _InfoWarning(message: response.report.wasiyyahWarning!),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _EstateBreakdownCard(
                        summary: response.report.summary,
                        wasiyyahDetails: response.report.wasiyyahDetails,
                        countryName: resolvedCountryName,
                      ),
                    ),
                    const SizedBox(height: 30),
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
    required this.response,
    required this.countryName,
  });

  final String deceasedName;
  final double estate;
  final double distributed;
  final DigitalWillCalculationResponse response;
  final String countryName;

  String _formatCurrency(double amount) {
    return _formatCurrencyGlobal(amount, countryName: countryName);
  }

  String _formatCaseType(String caseType) {
    final String formatted = caseType
        .trim()
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
    if (formatted.isEmpty) {
      return '';
    }
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final String caseType = _formatCaseType(response.report.caseType);

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
            color: const Color(0xFF0B3428).withValues(alpha: 0.25),
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
            'Estate owner: $deceasedName',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFFDDF1EB),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          if (caseType.isNotEmpty) ...[
            Text(
              'Case type: $caseType',
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: const Color(0xFFDDF1EB),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'Country: $countryName',
            style: GoogleFonts.roboto(
              fontSize: 13,
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
                  value: _formatCurrency(estate),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricPill(
                  label: 'Distributed Now',
                  value: _formatCurrency(distributed),
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
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFFDCF1EB),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class SavedWillExecutorInfoCard extends StatelessWidget {
  const SavedWillExecutorInfoCard({
    required this.basicInfo,
    super.key,
  });

  final DigitalWillBasicInfoResponse basicInfo;

  String _displayValue(String value) {
    if (value.trim().isEmpty) {
      return 'Not provided';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Executor Details',
      icon: Icons.assignment_ind_outlined,
      child: Column(
        children: [
          _ExecutorInfoRow(
            label: 'Executor',
            value: _displayValue(basicInfo.executorName),
          ),
          _ExecutorInfoRow(
            label: 'Contact',
            value: _displayValue(basicInfo.executorContact),
          ),
        ],
      ),
    );
  }
}

class _ExecutorInfoRow extends StatelessWidget {
  const _ExecutorInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: const Color(0xFF58776C),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: const Color(0xFF174A3B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.shares, required this.countryName});

  final List<_ShareEntry> shares;
  final String countryName;

  @override
  Widget build(BuildContext context) {
    final double total =
        shares.fold<double>(0, (double prev, _ShareEntry share) {
      return prev + share.amount;
    });

    return _CardShell(
      title: 'Distribution Chart',
      icon: Icons.pie_chart,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: CustomPaint(
              painter: _PieChartPainter(shares: shares),
              size: const Size(200, 200),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: const Color(0xFF58776C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatCurrency(total, countryName: countryName),
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: const Color(0xFF174A3B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
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
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            share.label,
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: const Color(0xFF36574D),
            ),
          ),
        ),
        Text(
          '${(ratio * 100).toStringAsFixed(1)}%',
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: const Color(0xFF174A3B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({required this.shares});

  final List<_ShareEntry> shares;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    double startAngle = -3.14159 / 2;
    final double total =
        shares.fold<double>(0, (double prev, _ShareEntry share) {
      return prev + share.amount;
    });

    for (final _ShareEntry share in shares) {
      final double sweepAngle = (share.amount / total) * 2 * 3.14159;
      paint.color = share.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) => false;
}

class _SharesCard extends StatelessWidget {
  const _SharesCard({
    required this.shares,
    required this.estate,
    required this.distribution,
    required this.countryName,
  });

  final List<_ShareEntry> shares;
  final double estate;
  final List<DigitalWillDistributionItemResponse> distribution;
  final String countryName;

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
                countryName: countryName,
              ),
            ),
        ],
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.share,
    required this.estate,
    required this.countryName,
  });

  final _ShareEntry share;
  final double estate;
  final String countryName;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      share.label.toUpperCase(),
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF174A3B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (share.ruleText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        share.ruleText!,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: const Color(0xFF58776C),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                _formatCurrency(share.amount, countryName: countryName),
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: share.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFDDEAE5),
              valueColor: AlwaysStoppedAnimation<Color>(share.color),
            ),
          ),
        ],
      ),
    );
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
                  fontSize: 16,
                  color: const Color(0xFF36574D),
                ),
              ),
            ),
          if (heirSummary.excludedHeirs.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Excluded Heirs:',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF174A3B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              heirSummary.excludedHeirs.join(', '),
              style: GoogleFonts.roboto(
                fontSize: 14,
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
                      fontSize: 16,
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
                                fontSize: 14,
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

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes, this.title = 'Rule Notes'});

  final List<String> notes;
  final String title;

  @override
  Widget build(BuildContext context) {
    final List<String> uniqueNotes = notes.toSet().toList();

    return _CardShell(
      title: title,
      icon: Icons.auto_awesome_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final String note in uniqueNotes)
            LayoutBuilder(
              builder: (context, constraints) {
                final textPainter = TextPainter(
                  text: TextSpan(
                    text: note,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      height: 1.8,
                    ),
                  ),
                  maxLines: null,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth);

                final isMultiLine = textPainter.computeLineMetrics().length > 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: isMultiLine
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: isMultiLine ? 6 : 0,
                        ),
                        child: const Icon(
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
                            fontSize: 15,
                            color: const Color(0xFF36574D),
                            height: 1.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
                  fontSize: 16,
                  color: const Color(0xFF174A3B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  method,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: const Color(0xFF36574D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Adjustment: ',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF174A3B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  adjustment.toString(),
                  style: GoogleFonts.roboto(
                    fontSize: 14,
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

class _EstateBreakdownCard extends StatelessWidget {
  const _EstateBreakdownCard({
    required this.summary,
    required this.wasiyyahDetails,
    required this.countryName,
  });

  final DigitalWillSummaryResponse summary;
  final DigitalWillWasiyyahDetailsResponse wasiyyahDetails;
  final String countryName;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Estate Breakdown',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EstateRow(
            label: 'Total Assets',
            value: summary.totalAssets.toDouble(),
            countryName: countryName,
          ),
          const SizedBox(height: 8),
          _EstateRow(
            label: 'Debts',
            value: summary.debts.toDouble(),
            isDeduction: true,
            countryName: countryName,
          ),
          const SizedBox(height: 8),
          _EstateRow(
            label: 'Funeral Expenses',
            value: summary.funeralExpenses.toDouble(),
            isDeduction: true,
            countryName: countryName,
          ),
          if (summary.mahrDue > 0) ...[
            const SizedBox(height: 8),
            _EstateRow(
              label: 'Mahr Due',
              value: summary.mahrDue.toDouble(),
              isDeduction: true,
              countryName: countryName,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(height: 1, color: const Color(0xFFDDEAE5)),
          ),
          _EstateRow(
            label: 'Net Estate',
            value: summary.netEstate.toDouble(),
            isHighlight: true,
            countryName: countryName,
          ),
          const SizedBox(height: 8),
          _EstateRow(
            label: 'Wasiyyah Applied',
            value: summary.wasiyyahAmount.toDouble(),
            isDeduction: true,
            countryName: countryName,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(height: 1, color: const Color(0xFFDDEAE5)),
          ),
          _EstateRow(
            label: 'Final Estate for Distribution',
            value: summary.finalEstateForDistribution.toDouble(),
            isHighlight: true,
            isFinal: true,
            countryName: countryName,
          ),
        ],
      ),
    );
  }
}

class _EstateRow extends StatelessWidget {
  const _EstateRow({
    required this.label,
    required this.value,
    required this.countryName,
    this.isDeduction = false,
    this.isHighlight = false,
    this.isFinal = false,
  });

  final String label;
  final double value;
  final String countryName;
  final bool isDeduction;
  final bool isHighlight;
  final bool isFinal;

  String _formatCurrency(double amount) {
    return _formatCurrencyGlobal(amount, countryName: countryName);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = GoogleFonts.roboto(
      fontSize: isFinal ? 18 : 16,
      color: isHighlight || isFinal
          ? const Color(0xFF174A3B)
          : const Color(0xFF36574D),
      fontWeight: isHighlight || isFinal ? FontWeight.w700 : FontWeight.w500,
    );
    final TextStyle valueStyle = GoogleFonts.roboto(
      fontSize: isFinal ? 17 : 14,
      color: isDeduction
          ? const Color(0xFFD32F2F)
          : (isHighlight || isFinal
              ? const Color(0xFF1A5B48)
              : const Color(0xFF36574D)),
      fontWeight: isHighlight || isFinal ? FontWeight.w700 : FontWeight.w500,
    );
    final String valueText =
        isDeduction ? '- ${_formatCurrency(value)}' : _formatCurrency(value);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isFinal && constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: labelStyle,
                softWrap: true,
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    valueText,
                    style: valueStyle,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: labelStyle,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    valueText,
                    style: valueStyle,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
        color: const Color(0xFFFFF3CD),
        border: Border.all(color: const Color(0xFFFFE082)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFF57F17),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: const Color(0xFF6D4C41),
                height: 1.4,
              ),
            ),
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
        border: Border.all(color: const Color(0xFFDDEAE5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3428).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1A5B48), size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF174A3B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ShareEntry {
  _ShareEntry({
    required this.label,
    required this.amount,
    required this.color,
    required this.ruleText,
  });

  final String label;
  final double amount;
  final Color color;
  final String? ruleText;
}

// ─── Generate PDF FAB ────────────────────────────────────────────────────────

class _GeneratePdfFab extends StatelessWidget {
  const _GeneratePdfFab({required this.response, required this.countryName});

  final DigitalWillCalculationResponse response;
  final String countryName;

  Future<void> _openPdfBottomSheet(BuildContext context) async {
    if (!await BillingGateHelper.ensureFeatureAccess(
      BillingFeatureKeys.digitalWillPdfReport,
    )) {
      return;
    }
    final String recordId = response.savedRecordId ?? '';
    final String firebaseUserId = response.basicInfo.firebaseUserId.isNotEmpty
        ? response.basicInfo.firebaseUserId
        : (FirebaseAuth.instance.currentUser?.uid ?? '');
    final String deceasedName = response.basicInfo.fullName;

    if (recordId.isEmpty) {
      PLoaders.errorSnackBar(
        title: 'PDF Error',
        message: 'Record ID is missing. Cannot generate PDF.',
        context: context,
      );
      return;
    }

    // Initialize or get the PDF controller
    final PdfGenerationController pdfController =
        Get.isRegistered<PdfGenerationController>()
            ? Get.find<PdfGenerationController>()
            : Get.put(PdfGenerationController());

    pdfController.initializeForRecord(
      recordId: recordId,
      firebaseUserId: firebaseUserId,
      deceasedName: deceasedName,
      countryName: countryName,
    );

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
      final bool enabled = billingController.isFeatureEnabled(
        BillingFeatureKeys.digitalWillPdfReport,
      );
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () => _openPdfBottomSheet(context),
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
