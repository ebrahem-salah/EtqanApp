import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/category_mapping.dart';
import '../../core/network/api_client.dart';
import '../../core/services/share_service.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../call/live_recitation_room.dart';
import '../sections/dialogs/create_section_session_dialog.dart';

/// شاشة الحلقات الخاصة بقسم فرعي محدد (تطابق تصميم التطبيق القديم: بطاقات الحلقات الحية أو شاشة فارغة نظيفة)
class SectionCirclesScreen extends StatefulWidget {
  final String mainSection;
  final String subSection;

  const SectionCirclesScreen({
    super.key,
    required this.mainSection,
    required this.subSection,
  });

  @override
  State<SectionCirclesScreen> createState() => _SectionCirclesScreenState();
}

class _SectionCirclesScreenState extends State<SectionCirclesScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<Map<String, dynamic>> _circles = [];

  @override
  void initState() {
    super.initState();
    _loadCircles();
  }

  Future<void> _loadCircles() async {
    setState(() => _isLoading = true);
    final List<Map<String, dynamic>> loaded = [];
    final Set<int> seenIds = {};

    final int targetCatId = CategoryMapping.resolveCategoryId(
      widget.mainSection,
      widget.subSection,
    );

    try {
      // 1. جلب الحلقات المفلترة بمعرف القسم على السيرفر
      final resFiltered = await _apiClient.getClasses(categoryId: targetCatId);
      if (resFiltered.statusCode == 200 && resFiltered.data != null) {
        final List items = resFiltered.data['data'] ?? [];
        for (final item in items) {
          final map = Map<String, dynamic>.from(item);
          final id = int.tryParse('${map['id']}');
          if (id != null && seenIds.add(id)) {
            loaded.add(map);
          }
        }
      }

      // 2. جلب كل الحلقات الجارية ومطابقتها بالاسم أو المعرف (احتياطاً)
      final resAll = await _apiClient.getClasses();
      if (resAll.statusCode == 200 && resAll.data != null) {
        final List items = resAll.data['data'] ?? [];
        for (final item in items) {
          final map = Map<String, dynamic>.from(item);
          final id = int.tryParse('${map['id']}');
          if (id != null &&
              !seenIds.contains(id) &&
              CategoryMapping.matchesClass(
                map,
                mainSection: widget.mainSection,
                subSection: widget.subSection,
              )) {
            seenIds.add(id);
            loaded.add(map);
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _circles = loaded;
        _isLoading = false;
      });
    }
  }

  Future<void> _enterCircle(Map<String, dynamic> cls) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userRole = auth.currentUser?.role ?? UserRole.student;
    final bool isCreatorOrSheikh = userRole != UserRole.student || cls['is_owner'] == true;

    final int? classId = cls['id'] is int ? cls['id'] as int : int.tryParse('${cls['id']}');
    final String title = cls['name']?.toString() ?? widget.subSection;

    final sheikhObj = cls['sheikh'] ?? cls['creator']?['user'] ?? cls['creator'];
    final String rawSheikhName = sheikhObj?['name']?.toString() ?? '';
    final String sheikhName = (rawSheikhName.isNotEmpty && !rawSheikhName.contains('???'))
        ? rawSheikhName
        : 'الشيخ المقرئ';

    final int studentsCount = int.tryParse('${cls['students_count'] ?? 1}') ?? 1;
    final int capacity = int.tryParse('${cls['capacity'] ?? cls['max_students'] ?? 30}') ?? 30;

    // إذا كان طالباً وغير منضم بعد -> انضمام للحلقة أولاً عبر السيرفر
    if (!isCreatorOrSheikh && classId != null && cls['is_enrolled'] != true) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            'طلب الانضمام للحلقة',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل ترغب في الانضمام إلى حلقة "$title" مع $sheikhName؟',
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Dubai', fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Dubai', color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00875A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'انضمام ودخول',
                style: TextStyle(fontFamily: 'Dubai', color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      if (confirm != true) return;

      try {
        await _apiClient.joinClass(classId);
      } catch (_) {}
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveRecitationRoom(
          roomId: classId != null ? 'room_srv_$classId' : 'room_${widget.subSection.hashCode}',
          circleTitle: title,
          isSheikh: userRole != UserRole.student,
          classRoomId: classId,
          sheikhName: sheikhName,
          subscribersCount: studentsCount,
          capacity: capacity,
        ),
      ),
    );
    _loadCircles();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isSheikhOrSupervisor = (auth.currentUser?.role ?? UserRole.student) != UserRole.student;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Cream Header matching Screenshots 1 & 2
          Container(
            color: const Color(0xFFFAF7DF),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 14,
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    widget.subSection,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF00875A),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body: Circles or Clean Empty State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)))
                : RefreshIndicator(
                    color: const Color(0xFF00875A),
                    onRefresh: _loadCircles,
                    child: _circles.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.34),
                              const Center(
                                child: Text(
                                  'لا توجد حلقات في هذا القسم حالياً',
                                  style: TextStyle(
                                    fontFamily: 'Dubai',
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _circles.length,
                            itemBuilder: (context, index) => _buildCircleCard(_circles[index]),
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: isSheikhOrSupervisor
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF00875A),
              foregroundColor: Colors.white,
              onPressed: () async {
                await CreateSectionSessionDialog.show(
                  context,
                  initialSection: widget.mainSection,
                  initialSubSection: widget.subSection,
                );
                _loadCircles();
              },
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }

  Widget _buildCircleCard(Map<String, dynamic> cls) {
    final String title = cls['name']?.toString() ?? 'حلقة تلاوة';
    final sheikhObj = cls['sheikh'] ?? cls['creator']?['user'] ?? cls['creator'];
    final String rawSheikh = sheikhObj?['name']?.toString() ?? '';
    final String sheikhName = (rawSheikh.isNotEmpty && !rawSheikh.contains('???'))
        ? rawSheikh
        : 'الشيخ المقرئ';
    final int studentsCount = int.tryParse('${cls['students_count'] ?? 0}') ?? 0;
    final int capacity = int.tryParse('${cls['capacity'] ?? cls['max_students'] ?? 30}') ?? 30;
    final String startsAt = cls['starts_at']?.toString() ?? '';
    final bool isOngoing = cls['is_ongoing'] == true || cls['status'] == 'ongoing';
    final String? avatarUrl = sheikhObj?['avatar_url']?.toString() ?? cls['image_url']?.toString();

    return GestureDetector(
      onTap: () => _enterCircle(cls),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE5EFE9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD6E6DC)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Details column (left side in RTL -> expanded)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (startsAt.isNotEmpty)
                        Text(
                          startsAt,
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF00875A)),
                        onPressed: () {
                          ShareService.shareText(
                            title: title,
                            text: 'انضم إلى حلقة "$title" على تطبيق إتقان: https://etqan.site/classes/${cls['id']}',
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sheikhName,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subscribers pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9ECC9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'المشتركين $capacity / $studentsCount',
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191919),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.person_outline, size: 15, color: Color(0xFF191919)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status badge: جارية الآن
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3EADB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isOngoing ? 'جارية الآن' : 'مجدولة',
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00875A),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          isOngoing ? Icons.check_circle : Icons.schedule,
                          size: 15,
                          color: const Color(0xFF00875A),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE0E0E0),
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? const Icon(Icons.person, size: 32, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
