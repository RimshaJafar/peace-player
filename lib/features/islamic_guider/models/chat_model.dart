class ChatModel {
  final int chatId;
  final String chatName;

  ChatModel({
    required this.chatId,
    required this.chatName,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final chatObj = json['chat'] ?? json;
    final rawId = chatObj['chat_id'] ?? 0;
    final chatId =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
    final chatName = (chatObj['chat_name'] ?? '')?.toString() ?? '';
    return ChatModel(
      chatId: chatId,
      chatName: chatName,
    );
  }
}
