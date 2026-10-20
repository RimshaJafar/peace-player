/// Local PDF history record model for caching and history management.
class PdfHistoryRecord {
  PdfHistoryRecord({
    required this.recordId,
    required this.pdfId,
    required this.template,
    required this.language,
    required this.generatedAt,
    required this.downloadUrl,
    this.cachedFilePath,
    this.deceasedName,
    this.narrationStyle,
    this.currencyCode,
  });

  final String recordId;
  final String pdfId;
  final String template;
  final String language;
  final String generatedAt;
  final String downloadUrl;
  String? cachedFilePath;
  final String? deceasedName;
  final String? narrationStyle;
  final String? currencyCode;

  factory PdfHistoryRecord.fromJson(Map<String, dynamic> json) {
    return PdfHistoryRecord(
      recordId: (json['record_id'] ?? '').toString(),
      pdfId: (json['pdf_id'] ?? '').toString(),
      template: (json['template'] ?? 'modern').toString(),
      language: (json['language'] ?? 'en').toString(),
      generatedAt: (json['generated_at'] ?? '').toString(),
      downloadUrl: (json['download_url'] ?? '').toString(),
      cachedFilePath: json['cached_file_path']?.toString(),
      deceasedName: json['deceased_name']?.toString(),
      narrationStyle: json['narration_style']?.toString(),
      currencyCode: json['currency_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'record_id': recordId,
      'pdf_id': pdfId,
      'template': template,
      'language': language,
      'generated_at': generatedAt,
      'download_url': downloadUrl,
      'cached_file_path': cachedFilePath,
      'deceased_name': deceasedName,
      'narration_style': narrationStyle,
      'currency_code': currencyCode,
    };
  }

  String get displayLanguage {
    switch (language) {
      case 'ur':
        return 'Urdu';
      case 'ar':
        return 'Arabic';
      default:
        return 'English';
    }
  }

  String get displayTemplate {
    switch (template) {
      case 'islamic':
        return 'Islamic';
      case 'legal':
        return 'Legal';
      case 'minimal':
        return 'Minimal';
      default:
        return 'Modern';
    }
  }

  bool get isCached => cachedFilePath != null && cachedFilePath!.isNotEmpty;
}
