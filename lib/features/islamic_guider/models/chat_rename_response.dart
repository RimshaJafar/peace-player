class ChatRenameResponse {
  final int chatId;
  final String chatName;

  ChatRenameResponse({
    required this.chatId,
    required this.chatName,
  });

  factory ChatRenameResponse.fromJson(Map<String, dynamic> json) {
    final rawId = json['chat_id'] ?? 0;
    final id =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
    final name = (json['chat_name'] ?? '')?.toString() ?? '';
    return ChatRenameResponse(chatId: id, chatName: name);
  }
}
