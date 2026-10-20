import 'package:flutter/material.dart';

/// Reusable chat history tile for drawer chat list.
class ChatHistoryTile extends StatelessWidget {
  const ChatHistoryTile({
    super.key,
    required this.chatName,
    required this.onTap,
  });

  final String chatName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((255 * 0.2).toInt()),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            chatName,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
