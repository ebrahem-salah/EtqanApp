import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ChatConversationScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;

  const ChatConversationScreen({
    super.key,
    required this.userName,
    this.userAvatar = 'assets/images/profile.png',
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': 'الآن',
      });
      _messageController.clear();
    });

    // Auto simulated response from sheikh
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'text': 'وعليكم السلام ورحمة الله وبركاته، مرحباً بك أخي الكريم في منصة إتقان 🌿',
            'isMe': false,
            'time': 'الآن',
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFBE8), // Exact light yellow from header
        elevation: 0.5,
        leading: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00875A), size: 18),
              ),
            ),
          ),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF00875A).withOpacity(0.2),
              backgroundImage: widget.userAvatar.startsWith('assets/')
                  ? AssetImage(widget.userAvatar) as ImageProvider
                  : NetworkImage(widget.userAvatar),
            ),
            const SizedBox(width: 10),
            Text(
              widget.userName,
              style: const TextStyle(
                color: Color(0xFF1E2822),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Dubai',
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Messages Area
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد رسائل حالياً',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontFamily: 'Dubai',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['isMe'] == true;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF00875A) : const Color(0xFFF1F1E6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            msg['text'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 14,
                              fontFamily: 'Dubai',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Input Bar (Matching Image 6 Exactly)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Green Circular Send Button on the Left (Matching Image 6)
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00875A),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Rounded Input Container with Emoji & Link (Matching Image 6)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade300, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          // Emoji and Attachment Icons
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(Icons.sentiment_satisfied_alt_outlined, color: Colors.grey, size: 22),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(Icons.link_rounded, color: Colors.grey, size: 22),
                          ),
                          const SizedBox(width: 8),

                          // Text Input Field
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: '...اكتب رسالتك',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Dubai'),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
