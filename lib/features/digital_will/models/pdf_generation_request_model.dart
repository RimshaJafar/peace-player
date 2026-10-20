/// Request model for PDF generation API.
///
/// Matches the exact payload structure required by:
/// POST /digital-will/generate-pdf
class PdfGenerationRequest {
  const PdfGenerationRequest({
    required this.recordId,
    required this.firebaseUserId,
    required this.options,
    this.forceRegenerate = false,
    this.includeHtml = false,
    this.includeBase64Pdf = false,
  });

  final String recordId;
  final String firebaseUserId;
  final PdfGenerationOptions options;
  final bool forceRegenerate;
  final bool includeHtml;
  final bool includeBase64Pdf;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'record_id': recordId,
      'firebase_user_id': firebaseUserId,
      'options': options.toJson(),
      'force_regenerate': forceRegenerate,
      'include_html': includeHtml,
      'include_base64_pdf': includeBase64Pdf,
    };
  }
}

/// PDF generation options configuration.
class PdfGenerationOptions {
  const PdfGenerationOptions({
    this.language = 'en',
    this.template = 'modern',
    this.currencyCode = 'PKR',
    this.narrationStyle = 'formal',
    this.timezone = 'Asia/Karachi',
    this.locale = 'en_PK',
    this.includeIslamicExplanation = true,
    this.includeLegalNarration = true,
    this.includeRules = true,
    this.includeValidationNotes = true,
    this.includeWarnings = true,
    this.includeReferences = true,
    this.includeSignatures = true,
    this.includeTables = true,
  });

  final String language;
  final String template;
  final String currencyCode;
  final String narrationStyle;
  final String timezone;
  final String locale;
  final bool includeIslamicExplanation;
  final bool includeLegalNarration;
  final bool includeRules;
  final bool includeValidationNotes;
  final bool includeWarnings;
  final bool includeReferences;
  final bool includeSignatures;
  final bool includeTables;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'language': language,
      'template': template,
      'currency_code': currencyCode,
      'narration_style': narrationStyle,
      'timezone': timezone,
      'locale': locale,
      'include_islamic_explanation': includeIslamicExplanation,
      'include_legal_narration': includeLegalNarration,
      'include_rules': includeRules,
      'include_validation_notes': includeValidationNotes,
      'include_warnings': includeWarnings,
      'include_references': includeReferences,
      'include_signatures': includeSignatures,
      'include_tables': includeTables,
    };
  }

  PdfGenerationOptions copyWith({
    String? language,
    String? template,
    String? currencyCode,
    String? narrationStyle,
    String? timezone,
    String? locale,
    bool? includeIslamicExplanation,
    bool? includeLegalNarration,
    bool? includeRules,
    bool? includeValidationNotes,
    bool? includeWarnings,
    bool? includeReferences,
    bool? includeSignatures,
    bool? includeTables,
  }) {
    return PdfGenerationOptions(
      language: language ?? this.language,
      template: template ?? this.template,
      currencyCode: currencyCode ?? this.currencyCode,
      narrationStyle: narrationStyle ?? this.narrationStyle,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      includeIslamicExplanation:
          includeIslamicExplanation ?? this.includeIslamicExplanation,
      includeLegalNarration:
          includeLegalNarration ?? this.includeLegalNarration,
      includeRules: includeRules ?? this.includeRules,
      includeValidationNotes:
          includeValidationNotes ?? this.includeValidationNotes,
      includeWarnings: includeWarnings ?? this.includeWarnings,
      includeReferences: includeReferences ?? this.includeReferences,
      includeSignatures: includeSignatures ?? this.includeSignatures,
      includeTables: includeTables ?? this.includeTables,
    );
  }
}
