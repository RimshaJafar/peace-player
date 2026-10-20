class NavigationResponse {
  final bool success;
  final String action;
  final String? route;
  final List<String>? routes;
  final double confidence;
  final String message;
  final String transcription;

  NavigationResponse({
    required this.success,
    required this.action,
    this.route,
    this.routes,
    required this.confidence,
    required this.message,
    required this.transcription,
  });

  factory NavigationResponse.fromJson(Map<String, dynamic> json) {
    return NavigationResponse(
      success: json['success'] ?? false,
      action: json['action'] ?? '',
      route: json['route'],
      routes: (json['routes'] as List?)?.map((e) => e.toString()).toList(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] ?? '',
      transcription: json['transcription'] ?? '',
    );
  }
}
