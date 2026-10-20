import 'package:flutter/material.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';

class ChatDrawerHeader extends StatelessWidget {
  const ChatDrawerHeader({
    super.key,
    required this.onNewChat,
    required this.onSearchChanged,
  });

  final VoidCallback onNewChat;
  final Function(String) onSearchChanged;

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 150;
    const double buttonSize = 55;

    return SizedBox(
      height: headerHeight + buttonSize / 2, // make room for half overlapping
      child: Stack(
        clipBehavior: Clip.none, // Important: allows overflow
        children: [
          // Gradient header background
          Container(
            height: headerHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF60BEA8),
                  Color(0xFF329070),
                  Color(0xFF1C5D4E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
           child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const SizedBox(height: 12),
    Row(
      children: [
        Image.asset(
          "assets/logos/peace_logo.png",
          height: 30,
          width: 30,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        const Text(
          "Peace Player",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),
                // Search bar
                Container(
                  height: 40,
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    onChanged: (value) => onSearchChanged(value),
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Circular button half overlapping
          Positioned(
            right: 16,
            top: headerHeight - (buttonSize / 2), // Position so it overlaps half
            child: GestureDetector(
              onTap: onNewChat,
              child: Container(
                height: buttonSize,
                width: buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF60BEA8),
                      Color(0xFF329070),
                      Color(0xFF1C5D4E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    "assets/icons/chat-bubble.png",
                    color: Colors.white,
                    height: 32,
                    width: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}