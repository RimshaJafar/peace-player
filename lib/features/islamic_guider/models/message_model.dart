class MessageModel {
  final int chatId;
  final String chatName;
  final String sender; // user | assistant
  final int messageId;
  final String content;
  final String? imageUrl;
  final String timestamp;
  final bool isStreaming; // 🔥 IMPORTANT

  MessageModel({
    required this.chatId,
    required this.chatName,
    required this.sender,
    required this.messageId,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.isStreaming = false,
  });

  MessageModel copyWith({
    String? content,
    String? imageUrl,
    bool? isStreaming,
  }) {
    return MessageModel(
      chatId: chatId,
      chatName: chatName,
      sender: sender,
      messageId: messageId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  // factory MessageModel.fromJson(Map<String, dynamic> json) {
  //   final message = json['message'] ?? {};
  //   final chat = json['chat'] ?? {};

  //   return MessageModel(
  //     chatId: chat['chat_id'] ?? 0,
  //     chatName: chat['chat_name'] ?? '',
  //     sender: message['sender'] ?? 'assistant',
  //     messageId: message['message_id'] ?? 0,
  //     content: message['content'] ?? '',
  //     imageUrl: message['image_url'],
  //     timestamp: message['time_stamp'] ?? '',
  //     isStreaming: false,
  //   );
  // }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError(
      'Use fetchChatMessages() mapping for split messages',
    );
  }
}
