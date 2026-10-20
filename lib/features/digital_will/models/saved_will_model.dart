class SavedWillHistoryResponse {
  const SavedWillHistoryResponse({required this.items});

  final List<SavedWillItemResponse> items;

  factory SavedWillHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SavedWillHistoryResponse(
      items: _asList(json['items'])
          .map((item) => SavedWillItemResponse.fromJson(_asMap(item)))
          .toList(),
    );
  }
}

class SavedWillItemResponse {
  const SavedWillItemResponse({
    required this.savedRecordId,
    required this.firebaseUserId,
    required this.userName,
    required this.userEmail,
    required this.deceasedFullName,
    required this.deceasedGender,
    required this.countryJurisdiction,
    required this.executorName,
    required this.executorContact,
    required this.status,
    required this.createdAt,
    required this.finalEstateForDistribution,
    required this.totalDistributed,
  });

  final String savedRecordId;
  final String firebaseUserId;
  final String userName;
  final String userEmail;
  final String deceasedFullName;
  final String deceasedGender;
  final String countryJurisdiction;
  final String? executorName;
  final String? executorContact;
  final String status;
  final String createdAt;
  final double finalEstateForDistribution;
  final double totalDistributed;

  factory SavedWillItemResponse.fromJson(Map<String, dynamic> json) {
    return SavedWillItemResponse(
      savedRecordId: _asString(json['saved_record_id']),
      firebaseUserId: _asString(json['firebase_user_id']),
      userName: _asString(json['user_name']),
      userEmail: _asString(json['user_email']),
      deceasedFullName: _asString(json['deceased_full_name']),
      deceasedGender: _asString(json['deceased_gender']),
      countryJurisdiction: _asString(json['country_jurisdiction']),
      executorName: _asNullableString(json['executor_name']),
      executorContact: _asNullableString(json['executor_contact']),
      status: _asString(json['status']),
      createdAt: _asString(json['created_at']),
      finalEstateForDistribution:
          _asDouble(json['final_estate_for_distribution']),
      totalDistributed: _asDouble(json['total_distributed']),
    );
  }
}

// Helper functions for safe JSON deserialization
List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return <dynamic>[];
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) return value.cast<String, dynamic>();
  return <String, dynamic>{};
}

String _asString(dynamic value) {
  if (value is String) return value;
  if (value is num) return value.toString();
  return '';
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
