class MaxMessageIdResponse {
  final int maxMessageId;

  MaxMessageIdResponse({
    required this.maxMessageId,
  });

  factory MaxMessageIdResponse.fromJson(Map<String, dynamic> json) {
    return MaxMessageIdResponse(
      maxMessageId: json['max_message_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'max_message_id': maxMessageId,
      };
}
