import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';

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
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  final List<String> _quickReplies = [
    'السلام عليكم ورحمة الله',
    'جزاكم الله خيراً يا شيخنا',
    'متى موعد حلقة التسميع القادمة؟',
    'تمت مراجعة ورد اليوم بحمد الله',
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _storageKey => 'chat_${widget.userName.replaceAll(' ', '_')}';

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_storageKey);
      if (cachedJson != null) {
        final List decoded = jsonDecode(cachedJson);
        _messages.addAll(decoded.map((m) => Map<String, dynamic>.from(m)));
      }
    } catch (_) {}

    if (_messages.isEmpty) {
      // Initial default welcome conversation with sheikh
      _messages.addAll([
        {
          'text': 'السلام عليكم ورحمة الله وبركاته يا بني، مرحباً بك في حلقة إتقان القرآن الكريم.',
          'isMe': false,
          'time': '09:00 ص',
          'status': 'read',
        },
        {
          'text': 'وعليكم السلام ورحمة الله وبركاته فضيلة الشيخ، متى نبدأ تسميع سورة مريم؟',
          'isMe': true,
          'time': '09:05 ص',
          'status': 'read',
        },
        {
          'text': 'اليوم بإذن الله في تمام الساعة الخامسة والنصف مساءً، حضّر الآيات من 1 إلى 30 جيداً.',
          'isMe': false,
          'time': '09:10 ص',
          'status': 'read',
        },
      ]);
      _saveMessages();
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_messages));
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'م' : 'ص';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  void _sendMessage([String? quickText]) {
    final text = quickText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    final newMsg = {
      'text': text,
      'isMe': true,
      'time': _formatCurrentTime(),
      'status': 'delivered',
    };

    setState(() {
      _messages.add(newMsg);
      if (quickText == null) _messageController.clear();
    });

    _saveMessages();
    _scrollToBottom();

    // Auto smart response from sheikh / supervisor if addressed
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      String replyText = 'بارك الله فيك وجعلك من أهل القرآن الذين هم أهل الله وخاصته 🌿';
      if (text.contains('موعد') || text.contains('حلقة')) {
        replyText = 'موعد حلقتنا اليوم في تمام الساعة 5:30 م إن شاء الله، نلقاك على خير.';
      } else if (text.contains('السلام')) {
        replyText = 'وعليكم السلام ورحمة الله وبركاته ومغفرته، أهلاً بك يا بني.';
      } else if (text.contains('واجب') || text.contains('ورد')) {
        replyText = 'ما شاء الله تبارك الله، زادك الله حرصاً وإتقاناً وتثبيتاً في صدرك.';
      }

      setState(() {
        _messages.add({
          'text': replyText,
          'isMe': false,
          'time': _formatCurrentTime(),
          'status': 'read',
        });
      });
      _saveMessages();
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFBE8),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Color(0xFF1E2822),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Dubai',
                  ),
                ),
                Row(
                  children: const [
                    CircleAvatar(radius: 4, backgroundColor: Color(0xFF00875A)),
                    SizedBox(width: 4),
                    Text(
                      'متصل الآن',
                      style: TextStyle(
                        color: Color(0xFF00875A),
                        fontSize: 11,
                        fontFamily: 'Dubai',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)))
          : Column(
              children: [
                // Messages List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['isMe'] == true;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF00875A) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['text'] ?? '',
                                style: TextStyle(
                                  color: isMe ? Colors.white : const Color(0xFF1E2822),
                                  fontSize: 14,
                                  fontFamily: 'Dubai',
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    msg['time'] ?? '',
                                    style: TextStyle(
                                      color: isMe ? Colors.white70 : Colors.grey.shade500,
                                      fontSize: 10,
                                      fontFamily: 'Dubai',
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.done_all, color: Colors.white70, size: 14),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Quick Replies Bar
                Container(
                  height: 38,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickReplies.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final reply = _quickReplies[index];
                      return ActionChip(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: const Color(0xFF00875A).withOpacity(0.3)),
                        label: Text(
                          reply,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00875A),
                          ),
                        ),
                        onPressed: () => _sendMessage(reply),
                      );
                    },
                  ),
                ),

                // Bottom Input Bar
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
                        // Green Circular Send Button
                        GestureDetector(
                          onTap: () => _sendMessage(),
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

                        // Rounded Input Field
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.grey.shade300, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.mic_none_rounded, color: Color(0xFF00875A), size: 22),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('🎙️ جاري تفعيل التسجيل الصوتي للرسالة...'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      hintText: '...اكتب رسالتك لفضيلة الشيخ',
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
