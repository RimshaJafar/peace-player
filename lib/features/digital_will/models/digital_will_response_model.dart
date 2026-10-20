class DigitalWillCalculationResponse {
  const DigitalWillCalculationResponse({
    required this.success,
    required this.error,
    required this.basicInfo,
    required this.report,
    required this.savedToDb,
    required this.savedRecordId,
    required this.calculationCompleted,
    required this.message,
  });

  final bool success;
  final String? error;
  final DigitalWillBasicInfoResponse basicInfo;
  final DigitalWillReportResponse report;
  final bool savedToDb;
  final String? savedRecordId;
  final bool calculationCompleted;
  final String message;

  factory DigitalWillCalculationResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> step1BasicInfo =
        _asMap(json['step1_basic_info']);
    return DigitalWillCalculationResponse(
      success: _asBool(json['success']),
      error: _asNullableString(json['error']),
      basicInfo: DigitalWillBasicInfoResponse.fromJson(
        step1BasicInfo.isNotEmpty ? step1BasicInfo : _asMap(json['basic_info']),
      ),
      report: DigitalWillReportResponse.fromJson(
        _asMap(json['report']),
      ),
      savedToDb: _asBool(json['saved_to_db']),
      savedRecordId: _asNullableString(json['saved_record_id']),
      calculationCompleted: _asBool(json['calculation_completed']),
      message: _asString(json['message']),
    );
  }
}

class DigitalWillBasicInfoResponse {
  const DigitalWillBasicInfoResponse({
    required this.firebaseUserId,
    required this.userName,
    required this.userEmail,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.dateOfDeath,
    required this.countryJurisdiction,
    required this.executorName,
    required this.executorContact,
  });

  final String firebaseUserId;
  final String userName;
  final String userEmail;
  final String fullName;
  final String gender;
  final String dateOfBirth;
  final String dateOfDeath;
  final String countryJurisdiction;
  final String executorName;
  final String executorContact;

  factory DigitalWillBasicInfoResponse.fromJson(Map<String, dynamic> json) {
    return DigitalWillBasicInfoResponse(
      firebaseUserId: _asString(json['firebase_user_id']),
      userName: _asString(json['user_name']),
      userEmail: _asString(json['user_email']),
      fullName: _asString(json['full_name']),
      gender: _asString(json['gender']),
      dateOfBirth: _asString(json['date_of_birth']),
      dateOfDeath: _asString(json['date_of_death']),
      countryJurisdiction: _asString(json['country_jurisdiction']),
      executorName: _asString(json['executor_name']),
      executorContact: _asString(json['executor_contact']),
    );
  }
}

class DigitalWillReportResponse {
  const DigitalWillReportResponse({
    required this.summary,
    required this.assetsSummary,
    required this.liabilitiesSummary,
    required this.wasiyyahDetails,
    required this.wasiyyahWarning,
    required this.distribution,
    required this.edgeCasesApplied,
    required this.excludedHeirs,
    required this.residueCalculation,
    required this.heirSummary,
    required this.blockedByRules,
    required this.caseType,
    required this.rulesApplied,
    required this.roundingPolicy,
    required this.calculationSteps,
    required this.totalDistributed,
    required this.validationNotes,
  });

  final DigitalWillSummaryResponse summary;
  final DigitalWillAssetsSummaryResponse assetsSummary;
  final DigitalWillLiabilitiesSummaryResponse liabilitiesSummary;
  final DigitalWillWasiyyahDetailsResponse wasiyyahDetails;
  final String? wasiyyahWarning;
  final List<DigitalWillDistributionItemResponse> distribution;
  final List<String> edgeCasesApplied;
  final List<String> excludedHeirs;
  final DigitalWillResidueCalculationResponse residueCalculation;
  final DigitalWillHeirSummaryResponse heirSummary;
  final Map<String, List<String>> blockedByRules;
  final String caseType;
  final List<String> rulesApplied;
  final Map<String, dynamic> roundingPolicy;
  final List<String> calculationSteps;
  final double totalDistributed;
  final List<String> validationNotes;

  factory DigitalWillReportResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> blocked = _asMap(json['blocked_by_rules']);
    return DigitalWillReportResponse(
      summary: DigitalWillSummaryResponse.fromJson(_asMap(json['summary'])),
      assetsSummary: DigitalWillAssetsSummaryResponse.fromJson(
          _asMap(json['assets_summary'])),
      liabilitiesSummary: DigitalWillLiabilitiesSummaryResponse.fromJson(
        _asMap(json['liabilities_summary']),
      ),
      wasiyyahDetails: DigitalWillWasiyyahDetailsResponse.fromJson(
        _asMap(json['wasiyyah_details']),
      ),
      wasiyyahWarning: _asNullableString(json['wasiyyah_warning']),
      distribution: _asList(json['distribution'])
          .map((entry) =>
              DigitalWillDistributionItemResponse.fromJson(_asMap(entry)))
          .toList(),
      edgeCasesApplied:
          _asList(json['edge_cases_applied']).map(_asString).toList(),
      excludedHeirs: _asList(json['excluded_heirs']).map(_asString).toList(),
      residueCalculation: DigitalWillResidueCalculationResponse.fromJson(
        _asMap(json['residue_calculation']),
      ),
      heirSummary:
          DigitalWillHeirSummaryResponse.fromJson(_asMap(json['heir_summary'])),
      blockedByRules: blocked.map(
        (key, value) => MapEntry(
          key,
          _asList(value).map(_asString).toList(),
        ),
      ),
      caseType: _asString(json['case_type']),
      rulesApplied: _asList(json['rules_applied']).map(_asString).toList(),
      roundingPolicy: _asMap(json['rounding_policy']),
      calculationSteps:
          _asList(json['calculation_steps']).map(_asString).toList(),
      totalDistributed: _asDouble(json['total_distributed']),
      validationNotes:
          _asList(json['validation_notes']).map(_asString).toList(),
    );
  }
}

class DigitalWillSummaryResponse {
  const DigitalWillSummaryResponse({
    required this.totalAssets,
    required this.debts,
    required this.mahrDue,
    required this.funeralExpenses,
    required this.totalLiabilities,
    required this.netEstate,
    required this.wasiyyahAmount,
    required this.finalEstateForDistribution,
  });

  final double totalAssets;
  final double debts;
  final double mahrDue;
  final double funeralExpenses;
  final double totalLiabilities;
  final double netEstate;
  final double wasiyyahAmount;
  final double finalEstateForDistribution;

  factory DigitalWillSummaryResponse.fromJson(Map<String, dynamic> json) {
    return DigitalWillSummaryResponse(
      totalAssets: _asDouble(json['total_assets']),
      debts: _asDouble(json['debts']),
      mahrDue: _asDouble(json['mahr_due']),
      funeralExpenses: _asDouble(json['funeral_expenses']),
      totalLiabilities: _asDouble(json['total_liabilities']),
      netEstate: _asDouble(json['net_estate']),
      wasiyyahAmount: _asDouble(json['wasiyyah_amount']),
      finalEstateForDistribution:
          _asDouble(json['final_estate_for_distribution']),
    );
  }
}

class DigitalWillAssetsSummaryResponse {
  const DigitalWillAssetsSummaryResponse({
    required this.realEstate,
    required this.vehicles,
    required this.financialAssets,
    required this.businessAssets,
    required this.preciousMetals,
    required this.otherAssets,
  });

  final double realEstate;
  final double vehicles;
  final double financialAssets;
  final double businessAssets;
  final double preciousMetals;
  final double otherAssets;

  factory DigitalWillAssetsSummaryResponse.fromJson(Map<String, dynamic> json) {
    return DigitalWillAssetsSummaryResponse(
      realEstate: _asDouble(json['real_estate']),
      vehicles: _asDouble(json['vehicles']),
      financialAssets: _asDouble(json['financial_assets']),
      businessAssets: _asDouble(json['business_assets']),
      preciousMetals: _asDouble(json['precious_metals']),
      otherAssets: _asDouble(json['other_assets']),
    );
  }
}

class DigitalWillLiabilitiesSummaryResponse {
  const DigitalWillLiabilitiesSummaryResponse({
    required this.debts,
    required this.mahrDue,
    required this.funeralExpenses,
  });

  final double debts;
  final double mahrDue;
  final double funeralExpenses;

  factory DigitalWillLiabilitiesSummaryResponse.fromJson(
      Map<String, dynamic> json) {
    return DigitalWillLiabilitiesSummaryResponse(
      debts: _asDouble(json['debts']),
      mahrDue: _asDouble(json['mahr_due']),
      funeralExpenses: _asDouble(json['funeral_expenses']),
    );
  }
}

class DigitalWillWasiyyahDetailsResponse {
  const DigitalWillWasiyyahDetailsResponse({
    required this.type,
    required this.requestedAmount,
    required this.appliedAmount,
  });

  final String type;
  final double requestedAmount;
  final double appliedAmount;

  factory DigitalWillWasiyyahDetailsResponse.fromJson(
      Map<String, dynamic> json) {
    return DigitalWillWasiyyahDetailsResponse(
      type: _asString(json['type']),
      requestedAmount: _asDouble(json['requested_amount']),
      appliedAmount: _asDouble(json['applied_amount']),
    );
  }
}

class DigitalWillDistributionItemResponse {
  const DigitalWillDistributionItemResponse({
    required this.heirType,
    required this.heirName,
    required this.count,
    required this.fixedShare,
    required this.shareFraction,
    required this.fractionBreakdown,
    required this.amountEach,
    required this.totalAmount,
    required this.notes,
  });

  final String heirType;
  final String? heirName;
  final int count;
  final String fixedShare;
  final double shareFraction;
  final DigitalWillFractionBreakdownResponse? fractionBreakdown;
  final double amountEach;
  final double totalAmount;
  final String? notes;

  factory DigitalWillDistributionItemResponse.fromJson(
      Map<String, dynamic> json) {
    return DigitalWillDistributionItemResponse(
      heirType: _asString(json['heir_type']),
      heirName: _asNullableString(json['heir_name']),
      count: _asInt(json['count']),
      fixedShare: _asString(json['fixed_share']),
      shareFraction: _asDouble(json['share_fraction']),
      fractionBreakdown: json['fraction_breakdown'] == null
          ? null
          : DigitalWillFractionBreakdownResponse.fromJson(
              _asMap(json['fraction_breakdown']),
            ),
      amountEach: _asDouble(json['amount_each']),
      totalAmount: _asDouble(json['total_amount']),
      notes: _asNullableString(json['notes']),
    );
  }
}

class DigitalWillFractionBreakdownResponse {
  const DigitalWillFractionBreakdownResponse({
    required this.fixedFraction,
    required this.fixedAmount,
    required this.residueAmount,
    required this.totalAmount,
  });

  final double fixedFraction;
  final double fixedAmount;
  final double residueAmount;
  final double totalAmount;

  factory DigitalWillFractionBreakdownResponse.fromJson(
      Map<String, dynamic> json) {
    return DigitalWillFractionBreakdownResponse(
      fixedFraction: _asDouble(json['fixed_fraction']),
      fixedAmount: _asDouble(json['fixed_amount']),
      residueAmount: _asDouble(json['residue_amount']),
      totalAmount: _asDouble(json['total_amount']),
    );
  }
}

class DigitalWillResidueCalculationResponse {
  const DigitalWillResidueCalculationResponse({
    required this.initialResidue,
    required this.method,
    required this.distributedTo,
    required this.finalResidue,
  });

  final double initialResidue;
  final String method;
  final List<String> distributedTo;
  final double finalResidue;

  factory DigitalWillResidueCalculationResponse.fromJson(
      Map<String, dynamic> json) {
    return DigitalWillResidueCalculationResponse(
      initialResidue: _asDouble(json['initial_residue']),
      method: _asString(json['method']),
      distributedTo: _asList(json['distributed_to']).map(_asString).toList(),
      finalResidue: _asDouble(json['final_residue']),
    );
  }
}

class DigitalWillHeirSummaryResponse {
  const DigitalWillHeirSummaryResponse({
    required this.totalCandidates,
    required this.candidatesByType,
    required this.blockedTypes,
    required this.excludedHeirs,
  });

  final int totalCandidates;
  final Map<String, int> candidatesByType;
  final List<String> blockedTypes;
  final List<String> excludedHeirs;

  factory DigitalWillHeirSummaryResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawCandidates =
        _asMap(json['candidates_by_type']);
    return DigitalWillHeirSummaryResponse(
      totalCandidates: _asInt(json['total_candidates']),
      candidatesByType: rawCandidates.map(
        (key, value) => MapEntry(key, _asInt(value)),
      ),
      blockedTypes: _asList(json['blocked_types']).map(_asString).toList(),
      excludedHeirs: _asList(json['excluded_heirs']).map(_asString).toList(),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, dynamic item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List<dynamic>) {
    return value;
  }
  if (value is List) {
    return value.toList();
  }
  return <dynamic>[];
}

String _asString(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

String? _asNullableString(dynamic value) {
  if (value == null) {
    return null;
  }
  final String text = value.toString();
  return text.isEmpty ? null : text;
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  return (value?.toString().toLowerCase() ?? '') == 'true';
}
