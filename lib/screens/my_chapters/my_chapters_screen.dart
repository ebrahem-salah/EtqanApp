import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/services/share_service.dart';
import '../../core/services/user_chapters_service.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../call/live_recitation_room.dart';
import '../chapters/circle_replay_screen.dart';

class MyChaptersScreen extends StatefulWidget {
  final int refreshTick;
  const MyChaptersScreen({super.key, this.refreshTick = 0});

  @override
  State<MyChaptersScreen> createState() => _MyChaptersScreenState();
}

class _MyChaptersScreenState extends State<MyChaptersScreen> {
  final ApiClient _apiClient = ApiClient();
  int _selectedTab = 0; // 0: الجارية, 1: المنتهية
  bool _isLoading = false;

  List<Map<String, dynamic>> _ongoingChapters = [];
  List<Map<String, dynamic>> _finishedChapters = [];

  @override
  void initState() {
    super.initState();
    UserChaptersService.instance.changeNotifier.addListener(_onLocalChaptersChanged);
    _loadMyChapters();
  }

  @override
  void didUpdateWidget(covariant MyChaptersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTick != oldWidget.refreshTick) {
      _loadMyChapters();
    }
  }

  @override
  void dispose() {
    UserChaptersService.instance.changeNotifier.removeListener(_onLocalChaptersChanged);
    super.dispose();
  }

  void _onLocalChaptersChanged() {
    if (mounted) _loadMyChapters();
  }

  Future<void> _loadMyChapters() async {
    setState(() => _isLoading = true);
    await UserChaptersService.instance.init();

    final List<Map<String, dynamic>> userOngoing = [];
    final List<Map<String, dynamic>> userFinished = [];
    final Set<int> seenIds = {};

    try {
      // 1. الحلقات التي أنشأها الشيخ / المستخدم
      final resMy = await _apiClient.getMyClasses();
      // 2. الحلقات التي انضم إليها الطالب
      dynamic resJoined;
      try {
        resJoined = await _apiClient.getMyJoinedClasses();
      } catch (_) {}

      final List allServerItems = [
        ...(resMy.statusCode == 200 && resMy.data != null ? (resMy.data['data'] ?? []) : []),
        ...(resJoined != null && resJoined.statusCode == 200 && resJoined.data != null ? (resJoined.data['data'] ?? []) : []),
      ];

      for (var c in allServerItems) {
        final int? cid = c['id'] is int ? c['id'] as int : int.tryParse('${c['id']}');
        if (cid != null && !seenIds.add(cid)) continue;

        final isFinished = c['is_finished'] == true || c['status'] == 'completed';
        final sheikhObj = c['sheikh'] ?? c['creator']?['user'] ?? c['creator'];
        final rawSupervisor = sheikhObj?['name']?.toString() ?? c['supervisor']?['name']?.toString() ?? '';
        final supervisorName = (rawSupervisor.isNotEmpty && !rawSupervisor.contains('???'))
            ? rawSupervisor
            : 'الشيخ المقرئ';
        final studentsCount = int.tryParse('${c['students_count'] ?? 0}') ?? 0;
        final capacity = int.tryParse('${c['capacity'] ?? c['max_students'] ?? 30}') ?? 30;

        final mapItem = {
          'id': cid ?? 1,
          'title': c['name'] ?? 'حلقة تلاوة',
          'supervisor': supervisorName,
          'time': c['starts_at'] ?? '',
          'duration': c['duration_formatted'] ?? '00:00:00',
          'studentsCount': studentsCount,
          'capacity': capacity,
          'subscribers': '$capacity / $studentsCount',
          'avatar': sheikhObj?['avatar_url'] ?? c['image_url'],
          'fromServer': true,
        };
        if (isFinished) {
          userFinished.add(mapItem);
        } else {
          userOngoing.add(mapItem);
        }
      }
    } catch (_) {}

    // دمج الحلقات المحلية التي لم تُحفظ بعد على السيرفر فقط
    for (final local in UserChaptersService.instance.ongoingChapters) {
      final exists = userOngoing.any((s) => s['title'] == local['title']);
      if (!exists) userOngoing.add(local);
    }
    for (final local in UserChaptersService.instance.finishedChapters) {
      final exists = userFinished.any((s) => s['title'] == local['title']);
      if (!exists) userFinished.add(local);
    }

    _ongoingChapters = userOngoing;
    _finishedChapters = userFinished;

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteChapter(Map<String, dynamic> chapter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الحلقة', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من حذف حلقة "${chapter['title']}"؟', textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Dubai')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Dubai', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Dubai', color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _finishedChapters.removeWhere((c) => c['id'] == chapter['id']);
        _ongoingChapters.removeWhere((c) => c['id'] == chapter['id']);
      });

      try {
        await _apiClient.deleteClass(chapter['id']);
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الحلقة بنجاح', style: TextStyle(fontFamily: 'Dubai')),
            backgroundColor: Color(0xFF00875A),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar matching the screenshot
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none, color: Color(0xFF191919), size: 22),
                      onPressed: () {},
                    ),
                  ),
                  const Text(
                    'حلقاتي',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                ],
              ),
            ),

            // Segmented Tabs Bar (media_1795163173913_74f64438.jpg & media_1795163235290_e7d27c64.png)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: Row(
                children: [
                  // Tab 1: الحلقات المنتهية
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? const Color(0xFF00875A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'الحلقات المنتهية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _selectedTab == 1 ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Tab 0: الحلقات الجارية
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? const Color(0xFF00875A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'الحلقات الجارية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _selectedTab == 0 ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Content List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _loadMyChapters,
                      child: _selectedTab == 0
                          ? _buildOngoingList()
                          : _buildFinishedList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Ongoing Chapters List
  Widget _buildOngoingList() {
    if (_ongoingChapters.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.28),
          const Center(
            child: Text(
              'لا توجد حلقات جارية حالياً',
              style: TextStyle(fontFamily: 'Dubai', color: Colors.grey, fontSize: 15),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _ongoingChapters.length,
      itemBuilder: (context, index) {
        final item = _ongoingChapters[index];
        return GestureDetector(
          onTap: () {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final isSheikh = (auth.currentUser?.role ?? UserRole.student) != UserRole.student;
            final int? classId = item['id'] is int ? item['id'] as int : int.tryParse('${item['id']}');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LiveRecitationRoom(
                  roomId: classId != null ? 'room_srv_$classId' : 'room_${item['id']}',
                  circleTitle: item['title'],
                  isSheikh: isSheikh,
                  classRoomId: classId,
                  sheikhName: item['supervisor']?.toString(),
                  subscribersCount: item['studentsCount'] is int ? item['studentsCount'] as int : 1,
                  capacity: item['capacity'] is int ? item['capacity'] as int : 30,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EFE9), // الخلفية الخضراء الفاتحة من الصورة 2
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD6E6DC)),
            ),
            child: Column(
              children: [
                // Top row: Left action buttons, Right time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Power off button
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.power_settings_new, size: 20, color: Color(0xFF191919)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تسجيل الخروج من الجلسة', style: TextStyle(fontFamily: 'Dubai')),
                                  backgroundColor: Colors.black87,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Share button
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF00875A)),
                            onPressed: () {
                              ShareService.shareText(
                                title: item['title'],
                                text: 'انضم الآن إلى حلقة "${item['title']}" على تطبيق إتقان: https://etqan.site/classes/${item['id']}',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item['time'],
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Middle: Title, Supervisor, Avatar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['title'],
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191919),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['supervisor'],
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFE0E0E0),
                      backgroundImage: item['avatar'] != null ? NetworkImage(item['avatar']) : null,
                      child: item['avatar'] == null
                          ? const Icon(Icons.person, size: 30, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom row: Subscribers pill + Status badge (جارية الان)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Subscribers pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9ECC9), // اللون الأصفر الفاتح من الصورة
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'المشتركين ${item['subscribers']}',
                            style: const TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191919),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.person_outline, size: 16, color: Color(0xFF191919)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Badge: جارية الان ✔
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3EADB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'جارية الان',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00875A),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.check_circle, size: 16, color: Color(0xFF00875A)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Finished Chapters List
  Widget _buildFinishedList() {
    if (_finishedChapters.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.28),
          const Center(
            child: Text(
              'لا توجد حلقات منتهية حالياً',
              style: TextStyle(fontFamily: 'Dubai', color: Colors.grey, fontSize: 15),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _finishedChapters.length,
      itemBuilder: (context, index) {
        final item = _finishedChapters[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CircleReplayScreen(chapter: item),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
              // Top row: Left share, Right time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF00875A)),
                      onPressed: () {
                        ShareService.shareText(
                          title: item['title'],
                          text: 'حلقة "${item['title']}" على إتقان: https://etqan.site/classes/${item['id']}',
                        );
                      },
                    ),
                  ),
                  Text(
                    item['time'],
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Middle: Title, Supervisor, Avatar
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['title'],
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191919),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['supervisor'],
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFFE0E0E0),
                    backgroundImage: item['avatar'] != null ? NetworkImage(item['avatar']) : null,
                    child: item['avatar'] == null
                        ? const Icon(Icons.person, size: 30, color: Colors.white)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Duration Row: مدة الحلقة : 00:03:00 ⏱
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'مدة الحلقة : ${item['duration']}',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.access_time_outlined, size: 16, color: Color(0xFF191919)),
                ],
              ),
              const SizedBox(height: 8),

              // Subscribers pill
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9ECC9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'المشتركين ${item['subscribers']}',
                        style: const TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.person_outline, size: 16, color: Color(0xFF191919)),
                    ],
                  ),
                ),
              ),

              // Replay Button (مشاهدة تسجيل الحلقة)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CircleReplayScreen(chapter: item),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00875A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'مشاهدة تسجيل الحلقة 🎬',
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Horizontal Divider
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(
                  color: Color(0xFFF0F0F0),
                  thickness: 1,
                  height: 1,
                ),
              ),

              // Bottom Delete Chapter Action (حذف الحلقة 🗑)
              InkWell(
                onTap: () => _deleteChapter(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'حذف الحلقة',
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}
