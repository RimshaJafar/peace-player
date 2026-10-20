class ChatDeleteResponse {
  final int chatId;
  final bool deleted;

  ChatDeleteResponse({
    required this.chatId,
    required this.deleted,
  });

  factory ChatDeleteResponse.fromJson(Map<String, dynamic> json) {
    final rawId = json['chat_id'] ?? 0;
    final id =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
    final deleted = json['deleted'] == true;
    return ChatDeleteResponse(chatId: id, deleted: deleted);
  }
}
