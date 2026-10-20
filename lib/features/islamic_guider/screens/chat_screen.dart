import 'package:ecommerce_app/common/widgets/chat/chat_search_bar.dart';
import 'package:ecommerce_app/features/islamic_guider/controllers/islamic_guider_controller.dart';
import 'package:ecommerce_app/features/islamic_guider/models/message_model.dart';
import 'package:ecommerce_app/features/islamic_guider/screens/chat_drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/chat/chat_message_container.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/widgets/billing_usage_button.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final IslamicGuiderController controller = Get.put(IslamicGuiderController());
  final ScrollController _scrollController = ScrollController();
  late AnimationController _questionController;
  late Animation<Offset> _questionSlide;
  final List<String> _placeholderQuestions = const [
    "What Qur'an says about patience (sabr)?",
    "What are the rewards of helping the poor and orphans?",
    "How can I strengthen my daily dhikr?",
  ];
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    // Always reset to default chat page when entering this screen
    controller.selectedChatId.value = 0;
    controller.selectedChatName.value = "";

    super.initState();
    _questionController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _questionSlide = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-1.5, 0),
    ).animate(CurvedAnimation(
      parent: _questionController,
      curve: Curves.easeInOut,
    ));

    _questionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentQuestionIndex =
              (_currentQuestionIndex + 1) % _placeholderQuestions.length;
        });
        _questionController.reset();
        Future.delayed(const Duration(seconds: 7), () {
          if (mounted) {
            _questionController.forward();
          }
        });
      }
    });

    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        _questionController.forward();
      }
    });
  }

  Future<void> _showNewChatDialog(BuildContext context) async {
    final chatNameController = TextEditingController();
    String? validationError;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              void submit() {
                final name = chatNameController.text.trim();
                if (name.isEmpty) {
                  setDialogState(() {
                    validationError = 'Please enter a chat name.';
                  });
                  return;
                }

                controller.createNewChat(name);
                Navigator.of(dialogContext).pop();
              }

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 22, 16, 20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF58BDA4), Color(0xFF17664F)],
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start a new chat',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Give your conversation a clear, memorable name.',
                                    style: TextStyle(
                                      color: Color(0xD9FFFFFF),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              icon: const Icon(Icons.close_rounded),
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Chat name',
                              style: TextStyle(
                                color: Color(0xFF293530),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: chatNameController,
                              autofocus: true,
                              maxLength: 60,
                              textInputAction: TextInputAction.done,
                              onChanged: (_) {
                                if (validationError != null) {
                                  setDialogState(() => validationError = null);
                                }
                              },
                              onSubmitted: (_) => submit(),
                              decoration: InputDecoration(
                                hintText: 'e.g. Daily Islamic Guidance',
                                errorText: validationError,
                                counterText: '',
                                filled: true,
                                fillColor: const Color(0xFFF4F8F6),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD8E5E0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF329070),
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD95C5C),
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD95C5C),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF315E51),
                                      minimumSize: const Size(0, 50),
                                      side: const BorderSide(
                                        color: Color(0xFFBFD2CA),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: submit,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF258A67),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 50),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    child: const Text('Create Chat'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNewChatButton(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 270),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF58BDA4), Color(0xFF17664F)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1C5D4E).withValues(alpha: 0.24),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showNewChatDialog(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  SizedBox(width: 21),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New Chat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Start a new conversation',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xD9FFFFFF),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 190),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF1F8F5)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF1C5D4E).withValues(alpha: 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF173E32).withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: Stack(
            children: [
              Positioned(
                top: -34,
                right: -24,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF60BEA8).withValues(alpha: 0.09),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 15, 18, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF329070).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_outlined,
                            color: Color(0xFF258A67),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Suggested question',
                            style: TextStyle(
                              color: Color(0xFF1C5D4E),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${_currentQuestionIndex + 1}/${_placeholderQuestions.length}',
                          style: const TextStyle(
                            color: Color(0xFF77847F),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ClipRect(
                        child: Center(
                          child: SlideTransition(
                            position: _questionSlide,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                _placeholderQuestions[_currentQuestionIndex],
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF202A26),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _placeholderQuestions.length,
                        (index) {
                          final isActive = index == _currentQuestionIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF258A67)
                                  : const Color(0xFFB7CEC5),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMessageTile(MessageModel msg, bool isUser) {
    final bubble = FractionallySizedBox(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      widthFactor: isUser ? 0.85 : 1.0,
      child: ChatMessageContainer(msg: msg, isUser: isUser),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: PSizes.isTablet(context)
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: bubble,
              )
            : bubble,
      ),
    );
  }

  String capitalizeEachWord(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildRetryState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PAppBar(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF60BEA8),
            Color(0xFF329070),
            Color(0xFF1C5D4E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 32),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        title: Obx(() => Text(
              controller.selectedChatName.value.isEmpty
                  ? "Peace Guider"
                  : capitalizeEachWord(controller.selectedChatName.value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )),
        actions: const <Widget>[
          BillingUsageButton(
            featureKey: BillingFeatureKeys.peaceGuiderAiChat,
            featureLabel: 'Peace Guider AI',
            unitLabel: 'messages',
            relatedUsageItems: <BillingUsageItem>[
              BillingUsageItem(
                featureKey: BillingFeatureKeys.imageAiChat,
                featureLabel: 'Image-Based AI Chat',
                unitLabel: 'images',
                icon: Icons.image_search_rounded,
              ),
            ],
          ),
          SizedBox(width: 8),
        ],
      ),
      drawer: ChatDrawerWidget(
        onNewChat: () {
          Get.back();
          _showNewChatDialog(context);
        },
        onSelectChat: (int chatId, String chatName) {
          controller.selectChat(chatId, chatName);
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              // Auto-scroll to bottom when messages change
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });

              if (controller.isLoadingChats.value &&
                  controller.selectedChatId.value == 0) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.selectedChatId.value == 0 &&
                  controller.chatError.value.isNotEmpty) {
                return _buildRetryState(
                  message: controller.chatError.value,
                  onRetry: controller.fetchUserChats,
                );
              }

              if (controller.selectedChatId.value == 0) {
                return Column(
                  children: [
                    /// Top spacer for greeting
                    const Spacer(flex: 2),

                    /// Greeting
                    const Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        "السلام عليكم",
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF1C5D4E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// New Chat button
                    _buildNewChatButton(context),

                    const Spacer(flex: 1),

                    /// Question card - flexible height
                    Flexible(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(child: _buildSuggestionCard()),
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                );
              }

              if (controller.isLoadingMessages.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messageError.value.isNotEmpty &&
                  controller.messages.isEmpty) {
                return _buildRetryState(
                  message: controller.messageError.value,
                  onRetry: () => controller.fetchChatMessages(
                    controller.selectedChatId.value,
                  ),
                );
              }

              if (controller.messages.isEmpty) {
                // Chat selected, but no messages
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No messages yet in this chat.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              // Show messages for the selected chat
              return ListView.builder(
                controller: _scrollController,
                itemCount: controller.messages.length,
                itemBuilder: (_, index) {
                  final msg = controller.messages[index];
                  final isUser = msg.sender == "user";
                  return buildMessageTile(msg, isUser);
                },
              );
            }),
          ),
          const SizedBox(height: 8),
          ChatSearchBar()
        ],
      ),
    );
  }
}
