/// Constants for PDF generation feature.
class PdfConstants {
  PdfConstants._();

  // ─── Languages ───────────────────────────────────────────────────────
  static const List<PdfLanguageOption> languages = <PdfLanguageOption>[
    PdfLanguageOption(code: 'en', label: 'English', isRtl: false),
    PdfLanguageOption(code: 'ur', label: 'Urdu', isRtl: true),
    PdfLanguageOption(code: 'ar', label: 'Arabic', isRtl: true),
  ];

  // ─── Templates ───────────────────────────────────────────────────────
  static const List<PdfTemplateOption> templates = <PdfTemplateOption>[
    PdfTemplateOption(
      code: 'modern',
      label: 'Modern',
      description: 'Clean, contemporary design with elegant typography',
      icon: 'auto_awesome',
    ),
    PdfTemplateOption(
      code: 'islamic',
      label: 'Islamic',
      description: 'Traditional Islamic calligraphy and ornamental borders',
      icon: 'mosque',
    ),
    PdfTemplateOption(
      code: 'legal',
      label: 'Legal',
      description: 'Formal legal document format with structured sections',
      icon: 'gavel',
    ),
    PdfTemplateOption(
      code: 'minimal',
      label: 'Minimal',
      description: 'Simple, distraction-free layout focused on content',
      icon: 'article',
    ),
  ];

  // ─── Narration Styles ────────────────────────────────────────────────
  static const List<PdfNarrationOption> narrationStyles =
      <PdfNarrationOption>[
    PdfNarrationOption(
      code: 'formal',
      label: 'Formal',
      description: 'Professional legal language',
    ),
    PdfNarrationOption(
      code: 'casual',
      label: 'Casual',
      description: 'Easy-to-read conversational tone',
    ),
    PdfNarrationOption(
      code: 'detailed',
      label: 'Detailed',
      description: 'Comprehensive with full explanations',
    ),
    PdfNarrationOption(
      code: 'concise',
      label: 'Concise',
      description: 'Brief and to the point',
    ),
  ];

  // ─── Currencies ──────────────────────────────────────────────────────
  static const List<PdfCurrencyOption> currencies = <PdfCurrencyOption>[
    PdfCurrencyOption(code: 'PKR', label: 'Pakistani Rupee', symbol: '₨'),
    PdfCurrencyOption(code: 'USD', label: 'US Dollar', symbol: '\$'),
    PdfCurrencyOption(code: 'EUR', label: 'Euro', symbol: '€'),
    PdfCurrencyOption(code: 'GBP', label: 'British Pound', symbol: '£'),
    PdfCurrencyOption(code: 'SAR', label: 'Saudi Riyal', symbol: '﷼'),
    PdfCurrencyOption(code: 'AED', label: 'UAE Dirham', symbol: 'د.إ'),
  ];

  // ─── Timezones ───────────────────────────────────────────────────────
  static const List<PdfTimezoneOption> timezones = <PdfTimezoneOption>[
    PdfTimezoneOption(code: 'UTC', label: 'UTC (Coordinated Universal Time)'),
    PdfTimezoneOption(code: 'Asia/Karachi', label: 'Asia/Karachi (PKT +5:00)'),
    PdfTimezoneOption(
        code: 'Asia/Riyadh', label: 'Asia/Riyadh (AST +3:00)'),
    PdfTimezoneOption(
        code: 'Europe/London', label: 'Europe/London (GMT/BST)'),
    PdfTimezoneOption(
        code: 'America/New_York', label: 'America/New_York (EST/EDT)'),
  ];

  // ─── Locale Mapping ──────────────────────────────────────────────────
  static String localeForLanguage(String language) {
    switch (language) {
      case 'ur':
        return 'ur_PK';
      case 'ar':
        return 'ar_SA';
      default:
        return 'en_PK';
    }
  }

  // ─── Storage Keys ────────────────────────────────────────────────────
  static const String pdfHistoryStorageKey = 'pdf_generation_history';
  static const String pdfCacheDirectoryName = 'digital_will_pdfs';
}

/// Language option model.
class PdfLanguageOption {
  const PdfLanguageOption({
    required this.code,
    required this.label,
    required this.isRtl,
  });

  final String code;
  final String label;
  final bool isRtl;
}

/// Template option model.
class PdfTemplateOption {
  const PdfTemplateOption({
    required this.code,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String code;
  final String label;
  final String description;
  final String icon;
}

/// Narration style option model.
class PdfNarrationOption {
  const PdfNarrationOption({
    required this.code,
    required this.label,
    required this.description,
  });

  final String code;
  final String label;
  final String description;
}

/// Currency option model.
class PdfCurrencyOption {
  const PdfCurrencyOption({
    required this.code,
    required this.label,
    required this.symbol,
  });

  final String code;
  final String label;
  final String symbol;
}

/// Timezone option model.
class PdfTimezoneOption {
  const PdfTimezoneOption({
    required this.code,
    required this.label,
  });

  final String code;
  final String label;
}
