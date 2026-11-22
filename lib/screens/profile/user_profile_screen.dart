import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../chat/chat_conversation_screen.dart';
import '../call/live_recitation_room.dart';

class UserProfileScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final int episodesCount;
  final int videosCount;
  final int friendsCount;

  const UserProfileScreen({
    super.key,
    this.userName = 'Fahd saad',
    this.userAvatar = 'assets/images/profile.png',
    this.episodesCount = 4,
    this.videosCount = 1,
    this.friendsCount = 5,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFriend = false;
  late int _currentFriendsCount;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _currentFriendsCount = widget.friendsCount;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFriend() {
    setState(() {
      _isFriend = !_isFriend;
      if (_isFriend) {
        _currentFriendsCount += 1;
      } else {
        _currentFriendsCount -= 1;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFriend ? '✅ تمت إضافة ${widget.userName} إلى قائمة أصدقائك' : 'تم إلغاء المتابعة'),
        backgroundColor: const Color(0xFF00875A),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showSheikhInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.black54, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'معلومات عن الشيخ',
              style: TextStyle(fontFamily: 'Dubai', fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.userName,
              style: const TextStyle(fontFamily: 'Dubai', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
            ),
            const SizedBox(height: 8),
            Text(
              'تاريخ الميلاد: 2026-10-08',
              style: TextStyle(fontFamily: 'Dubai', fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFBE8), // Exact cream header
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF191919), size: 20),
            onPressed: () => _showSheikhInfoSheet(context),
          ),
        ),
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
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Top Profile Hero (Matching Images 4 & 5)
              Container(
                width: double.infinity,
                color: const Color(0xFFFCFBE8),
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    // Avatar with Green Add-Friend Badge
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 44,
                            backgroundImage: widget.userAvatar.startsWith('assets/')
                                ? AssetImage(widget.userAvatar) as ImageProvider
                                : NetworkImage(widget.userAvatar),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleFriend,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _isFriend ? Colors.grey : const Color(0xFF00875A),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              _isFriend ? Icons.check : Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // User Name
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2822),
                        fontFamily: 'Dubai',
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Institution Badge من الصورة 20
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF81C784)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.business_rounded, size: 14, color: Color(0xFF00875A)),
                          SizedBox(width: 6),
                          Text(
                            'مؤسسة التعاون',
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00875A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Counters Row: الحلقات | الفيديوهات | الاصدقاء
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFEFEECB), width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCounterItem('الاصدقاء', _currentFriendsCount.toString()),
                          Container(width: 1, height: 26, color: const Color(0xFFEFEECB)),
                          _buildCounterItem('الفيديوهات', widget.videosCount.toString()),
                          Container(width: 1, height: 26, color: const Color(0xFFEFEECB)),
                          _buildCounterItem('الحلقات', widget.episodesCount.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Tab Bar: الفيديوهات | الحلقات (Matching Images 4 & 5)
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFECECE0), width: 1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF00875A),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF00875A),
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('الفيديوهات'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chrome_reader_mode_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('الحلقات'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: الفيديوهات (Grid - Image 4)
                    _buildVideosTab(),

                    // Tab 2: الحلقات (List of Circles - Image 5)
                    _buildCirclesTab(),
                  ],
                ),
              ),
            ],
          ),

          // 4. Floating Animated Chat Button at Bottom Left (Matching Images 4 & 5)
          Positioned(
            bottom: 24,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatConversationScreen(
                      userName: widget.userName,
                      userAvatar: widget.userAvatar,
                    ),
                  ),
                );
              },
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Color(0xFF00875A),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2822),
            fontFamily: 'Dubai',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'Dubai',
          ),
        ),
      ],
    );
  }

  Widget _buildVideosTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Center(
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 12,
                child: Row(
                  children: const [
                    Text('2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.favorite, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCirclesTab() {
    final circles = [
      {
        'title': 'حلقة المواعظ',
        'sheikh': widget.userName,
        'time': '11:18AM - 21/09/2026',
        'subscribers': '0 / 1',
        'price': '20 دولار',
        'status': 'جارية الان',
      },
      {
        'title': 'حلقة الذكر',
        'sheikh': widget.userName,
        'time': '10:16AM - 21/09/2026',
        'subscribers': '0 / 1',
        'price': '60 دولار',
        'status': 'جارية الان',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: circles.length,
      itemBuilder: (context, index) {
        final c = circles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        c['time']!,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Dubai'),
                      ),
                      Text(
                        c['sheikh']!,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'سعر الحلقة: ${c['price']}',
                    style: const TextStyle(color: Color(0xFF00875A), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people_outline, size: 14, color: Color(0xFF00875A)),
                        const SizedBox(width: 4),
                        Text(
                          'المشتركين ${c['subscribers']}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF00875A), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  // Green "دفع" button
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00875A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LiveRecitationRoom(
                                roomId: 'circle_${c['title'].hashCode}',
                                circleTitle: c['title']!,
                              ),
                            ),
                          );
                        },
                        child: const Text('دفع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // "جارية الان" status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF00875A), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          c['status']!,
                          style: const TextStyle(color: Color(0xFF00875A), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
