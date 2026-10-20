class NotificationItem {
  final String notificationId;
  final String firebaseUserId;
  final String? userName;
  final String? userEmail;
  final String title;
  final String message;
  final String type;
  final String source;
  final Map<String, dynamic> metadata;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationItem({
    this.notificationId = '',
    this.firebaseUserId = '',
    this.userName,
    this.userEmail,
    this.title = '',
    this.message = '',
    this.type = '',
    this.source = '',
    this.metadata = const {},
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      notificationId: json['notification_id']?.toString() ?? '',
      firebaseUserId: json['firebase_user_id']?.toString() ?? '',
      userName: json['user_name']?.toString(),
      userEmail: json['user_email']?.toString(),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      metadata: _parseMap(json['metadata']),
      isRead: json['is_read'] == true,
      createdAt: _parseDate(json['created_at']),
    );
  }

  NotificationItem copyWith({
    bool? isRead,
  }) {
    return NotificationItem(
      notificationId: notificationId,
      firebaseUserId: firebaseUserId,
      userName: userName,
      userEmail: userEmail,
      title: title,
      message: message,
      type: type,
      source: source,
      metadata: metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

class NotificationListResponse {
  final List<NotificationItem> items;

  const NotificationListResponse({required this.items});

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is List) {
      return NotificationListResponse(
        items: rawItems
            .whereType<Map<String, dynamic>>()
            .map(NotificationItem.fromJson)
            .toList(),
      );
    }
    return const NotificationListResponse(items: []);
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

Map<String, dynamic> _parseMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}
