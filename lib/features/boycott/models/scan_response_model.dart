/// Model for the full AI scan response from POST /boycott/scanner/analyze
class ScanResponse {
  final bool success;
  final bool cached;
  final bool scannable;
  final String? productName;
  final String? brand;
  final String? company;
  final String? country;
  final String? category;
  final String? boycottLevel;
  final String? ethicalStatus;
  final double? confidence;
  final String? summary;
  final List<String> alternatives;
  final String? ocrText;
  final String? scanId;
  final String? createdAt;
  final String? message;

  ScanResponse({
    required this.success,
    required this.cached,
    required this.scannable,
    this.productName,
    this.brand,
    this.company,
    this.country,
    this.category,
    this.boycottLevel,
    this.ethicalStatus,
    this.confidence,
    this.summary,
    required this.alternatives,
    this.ocrText,
    this.scanId,
    this.createdAt,
    this.message,
  });

  factory ScanResponse.fromJson(Map<String, dynamic> json) {
    return ScanResponse(
      success: json['success'] as bool? ?? false,
      cached: json['cached'] as bool? ?? false,
      scannable: json['scannable'] as bool? ?? false,
      productName: json['product_name']?.toString(),
      brand: json['brand']?.toString(),
      company: json['company']?.toString(),
      country: json['country']?.toString(),
      category: json['category']?.toString(),
      boycottLevel: json['boycott_level']?.toString(),
      ethicalStatus: json['ethical_status']?.toString(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      summary: json['summary']?.toString(),
      alternatives: List<String>.from(json['alternatives'] ?? []),
      ocrText: json['ocr_text']?.toString(),
      scanId: json['scan_id']?.toString(),
      createdAt: json['created_at']?.toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'cached': cached,
        'scannable': scannable,
        'product_name': productName,
        'brand': brand,
        'company': company,
        'country': country,
        'category': category,
        'boycott_level': boycottLevel,
        'ethical_status': ethicalStatus,
        'confidence': confidence,
        'summary': summary,
        'alternatives': alternatives,
        'ocr_text': ocrText,
        'scan_id': scanId,
        'created_at': createdAt,
        'message': message,
      };
}

/// Model for non-scannable response
class NonScannableResponse {
  final bool success;
  final String reason;
  final String? scannedAt;

  NonScannableResponse({
    required this.success,
    required this.reason,
    this.scannedAt,
  });

  factory NonScannableResponse.fromJson(Map<String, dynamic> json) {
    return NonScannableResponse(
      success: json['success'] as bool? ?? false,
      reason: json['reason']?.toString() ?? 'Unknown error',
      scannedAt: json['scanned_at']?.toString(),
    );
  }
}

/// Model for a single scan history item from GET /boycott/scanner/history/{user_id}
class ScanHistoryItem {
  final String scanId;
  final String? productName;
  final String? brand;
  final String? boycottLevel;
  final double? confidence;
  final String? imageUrl;
  final String? scannedAt;

  ScanHistoryItem({
    required this.scanId,
    this.productName,
    this.brand,
    this.boycottLevel,
    this.confidence,
    this.imageUrl,
    this.scannedAt,
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      scanId: json['scan_id']?.toString() ?? '',
      productName: json['product_name']?.toString(),
      brand: json['brand']?.toString(),
      boycottLevel: json['boycott_level']?.toString(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      imageUrl: json['image_url']?.toString(),
      scannedAt: json['scanned_at']?.toString(),
    );
  }
}

/// Model for the history list response
class ScanHistoryResponse {
  final bool success;
  final int total;
  final List<ScanHistoryItem> history;

  ScanHistoryResponse({
    required this.success,
    required this.total,
    required this.history,
  });

  factory ScanHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ScanHistoryResponse(
      success: json['success'] as bool? ?? false,
      total: json['total'] as int? ?? 0,
      history: (json['history'] as List<dynamic>? ?? [])
          .map((e) => ScanHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
