import 'dart:async';

import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/widgets/history_access_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/islamic_guider/controllers/islamic_guider_controller.dart';
import 'package:ecommerce_app/common/widgets/chat/chat_drawer_header.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';

class ChatDrawerWidget extends StatefulWidget {
  final VoidCallback onNewChat;
  final Function(int chatId, String chatName) onSelectChat;

  const ChatDrawerWidget({
    super.key,
    required this.onNewChat,
    required this.onSelectChat,
  });

  @override
  State<ChatDrawerWidget> createState() => _ChatDrawerWidgetState();
}

class _ChatDrawerWidgetState extends State<ChatDrawerWidget> {
  String searchQuery = '';
  int? editingChatId;
  final Map<int, TextEditingController> editControllers = {};
  late final BillingController _billingController;

  @override
  void initState() {
    super.initState();
    _billingController = Get.isRegistered<BillingController>()
        ? Get.find<BillingController>()
        : Get.put(BillingController(), permanent: true);
    unawaited(_billingController.loadBillingProfile());
  }

  String capitalizeEachWord(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  void dispose() {
    for (var controller in editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IslamicGuiderController controller = Get.find();

    return Drawer(
      backgroundColor: const Color(0xFFEEEEEE),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatDrawerHeader(
              onNewChat: widget.onNewChat,
              onSearchChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.only(left: 24, top: 8, bottom: 8),
              child: Text(
                "History",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const HistoryAccessBanner(
              freeLabel: 'Latest 5 chats',
              proLabel: 'Full chat history',
              freeDescription: 'Upgrade for your complete chat history.',
              proDescription: 'Your complete chat history is available.',
              upgradeMessage:
                  'Free Plan keeps the latest 5 chats. Upgrade to Pro to access all chats and full chat history.',
              margin: EdgeInsets.fromLTRB(16, 0, 16, 10),
              accentColor: Color(0xFF1C5D4E),
            ),
            Expanded(
              child: controller.isLoadingChats.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.chatError.value.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  controller.chatError.value,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: controller.fetchUserChats,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.zero,
                          children: (_billingController.isPro
                                  ? controller.chats.entries.toList()
                                  : controller.chats.entries.take(5).toList())
                              .where((entry) {
                  if (searchQuery.isEmpty) return true;
                  return entry.value.toLowerCase().contains(searchQuery);
                }).map<Widget>((entry) {
                  final chatId = entry.key;
                  final chatName = entry.value;
                  final isEditing = editingChatId == chatId;

                  if (!editControllers.containsKey(chatId)) {
                    editControllers[chatId] =
                        TextEditingController(text: chatName);
                  }

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Card(
                      elevation: 4,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Chat Name or TextField
                            Expanded(
                              child: isEditing
                                  ? TextField(
                                      controller: editControllers[chatId],
                                      autofocus: true,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (value) async {
                                        final newName = value.trim();
                                        if (newName.isNotEmpty &&
                                            newName != chatName) {
                                          try {
                                            await controller.updateChatName(
                                              chatId,
                                              newName,
                                            );
                                            PLoaders.successSnackBar(
                                              title: 'Updated',
                                              message:
                                                  'Chat name updated successfully',
                                            );
                                          } catch (_) {}
                                        }
                                        if (!mounted) return;
                                        setState(() {
                                          editingChatId = null;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 12),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF1C5D4E),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF1C5D4E),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF329070),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12.0, right: 8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.onSelectChat(chatId, chatName);
                                          Get.back();
                                        },
                                        child: Text(
                                          capitalizeEachWord(chatName),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),

                            // Edit/Save Button
                            IconButton(
                              onPressed: () async {
                                if (isEditing) {
                                  // Save
                                  final newName =
                                      editControllers[chatId]!.text.trim();
                                  if (newName.isNotEmpty &&
                                      newName != chatName) {
                                    try {
                                      await controller.updateChatName(
                                        chatId,
                                        newName,
                                      );
                                      PLoaders.successSnackBar(
                                        title: 'Updated',
                                        message:
                                            'Chat name updated successfully',
                                      );
                                    } catch (_) {}
                                  }
                                  if (!mounted) return;
                                  setState(() {
                                    editingChatId = null;
                                  });
                                } else {
                                  // Edit
                                  setState(() {
                                    editingChatId = chatId;
                                    editControllers[chatId]!.text = chatName;
                                  });
                                }
                              },
                              icon: isEditing
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 22,
                                    )
                                  : Image.asset(
                                      "assets/icons/edit.png",
                                      width: 22,
                                      height: 22,
                                    ),
                            ),

                            // Delete Button
                            IconButton(
                              onPressed: () async {
                                final confirm = await Get.dialog<bool>(
                                  Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    backgroundColor: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "Are you sure you want to delete this chat?",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              // Delete Button (red)
                                              ElevatedButton(
                                                focusNode: FocusNode(
                                                    skipTraversal: true,
                                                    canRequestFocus: false),
                                                autofocus: false,
                                                style: ButtonStyle(
                                                  padding:
                                                      WidgetStateProperty.all(
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 32,
                                                        vertical: 16),
                                                  ),
                                                  shape:
                                                      WidgetStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      WidgetStateProperty.all(
                                                          const Color(
                                                              0xFFE53935)),
                                                  elevation:
                                                      WidgetStateProperty.all(
                                                          0),
                                                  overlayColor:
                                                      WidgetStateProperty
                                                          .resolveWith((_) =>
                                                              Colors
                                                                  .transparent),
                                                  splashFactory:
                                                      NoSplash.splashFactory,
                                                  enableFeedback: false,
                                                  side: WidgetStateProperty
                                                      .resolveWith((_) =>
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 0)),
                                                ),
                                                onPressed: () =>
                                                    Get.back(result: true),
                                                child: const Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),

                                              // Cancel Button (grey)
                                              ElevatedButton(
                                                focusNode: FocusNode(
                                                    skipTraversal: true,
                                                    canRequestFocus: false),
                                                autofocus: false,
                                                style: ButtonStyle(
                                                  padding:
                                                      WidgetStateProperty.all(
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 32,
                                                        vertical: 16),
                                                  ),
                                                  shape:
                                                      WidgetStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      WidgetStateProperty.all(
                                                          Colors.grey[300]),
                                                  elevation:
                                                      WidgetStateProperty.all(
                                                          0),
                                                  overlayColor:
                                                      WidgetStateProperty
                                                          .resolveWith((_) =>
                                                              Colors
                                                                  .transparent),
                                                  splashFactory:
                                                      NoSplash.splashFactory,
                                                  enableFeedback: false,
                                                  side: WidgetStateProperty
                                                      .resolveWith((_) =>
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 0)),
                                                ),
                                                onPressed: () =>
                                                    Get.back(result: false),
                                                child: const Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1C5D4E),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  barrierDismissible: true,
                                );

                                if (confirm == true) {
                                  await controller.deleteChat(chatId);
                                  editControllers[chatId]?.dispose();
                                  editControllers.remove(chatId);
                                  if (editingChatId == chatId) {
                                    setState(() {
                                      editingChatId = null;
                                    });
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
