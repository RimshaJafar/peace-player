/// Response model from PDF generation API.
///
/// Matches the response from:
/// POST /digital-will/generate-pdf
/// GET /digital-will/pdf/{record_id}
class PdfGenerationResponse {
  const PdfGenerationResponse({
    required this.success,
    required this.recordId,
    required this.pdfId,
    required this.downloadUrl,
    required this.language,
    required this.template,
    required this.generatedAt,
    this.htmlContent,
    this.base64Pdf,
    this.error,
  });

  final bool success;
  final String recordId;
  final String pdfId;
  final String downloadUrl;
  final String language;
  final String template;
  final String generatedAt;
  final String? htmlContent;
  final String? base64Pdf;
  final String? error;

  factory PdfGenerationResponse.fromJson(Map<String, dynamic> json) {
    return PdfGenerationResponse(
      success: json['success'] == true,
      recordId: (json['record_id'] ?? '').toString(),
      pdfId: (json['pdf_id'] ?? '').toString(),
      downloadUrl: (json['download_url'] ?? '').toString(),
      language: (json['language'] ?? 'en').toString(),
      template: (json['template'] ?? 'modern').toString(),
      generatedAt: (json['generated_at'] ?? '').toString(),
      htmlContent: json['html_content']?.toString(),
      base64Pdf: json['base64_pdf']?.toString(),
      error: json['error']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'record_id': recordId,
      'pdf_id': pdfId,
      'download_url': downloadUrl,
      'language': language,
      'template': template,
      'generated_at': generatedAt,
      if (htmlContent != null) 'html_content': htmlContent,
      if (base64Pdf != null) 'base64_pdf': base64Pdf,
      if (error != null) 'error': error,
    };
  }
}
