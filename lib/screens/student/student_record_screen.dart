import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_client.dart';
import '../../core/services/student_rating_service.dart';
import '../../core/utils/app_feedback.dart';
import '../../providers/auth_provider.dart';
import '../appreciations/appreciations_screen.dart';

class StudentRecordScreen extends StatefulWidget {
  final int? studentId;
  final String? studentName;

  const StudentRecordScreen({
    super.key,
    this.studentId,
    this.studentName,
  });

  @override
  State<StudentRecordScreen> createState() => _StudentRecordScreenState();
}

class _StudentRecordScreenState extends State<StudentRecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = true;
  StudentRatingSummary _rating = StudentRatingSummary.empty;
  List<Map<String, dynamic>> _classes = [];
  int? _targetStudentId;
  String _targetStudentName = 'الطالب';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecordData();
  }

  Future<void> _loadRecordData() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.currentUser;
      _targetStudentId = widget.studentId ?? user?.id;
      _targetStudentName = widget.studentName ?? user?.name ?? 'الطالب';

      if (_targetStudentId != null) {
        _rating = await StudentRatingService.instance.fetchStudentRating(_targetStudentId!);
      }

      if (widget.studentId == null) {
        final List<Map<String, dynamic>> loadedClasses = [];
        final Set<int> seenIds = {};
        for (final future in [_apiClient.getMyJoinedClasses(), _apiClient.getMyClasses()]) {
          try {
            final res = await future;
            if (res.statusCode == 200 && res.data != null) {
              final List list = res.data['data'] is List ? res.data['data'] : [];
              for (final c in list) {
                final int? cid = int.tryParse('${c['id'] ?? ''}');
                if (cid != null && !seenIds.add(cid)) continue;
                final sheikhObj = c['sheikh'] ?? c['creator']?['user'] ?? c['creator'];
                loadedClasses.add({
                  'id': cid,
                  'name': (c['name'] ?? 'حلقة تسميع').toString(),
                  'sheikh': (sheikhObj?['name'] ?? 'مشرف الحلقة').toString(),
                  'starts_at': (c['starts_at'] ?? '').toString(),
                  'is_finished': c['is_finished'] == true || c['status'] == 'completed',
                });
              }
            }
          } catch (_) {}
        }
        _classes = loadedClasses;
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'جلب سجل الطالب', e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2822)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.studentName != null ? 'سجل $_targetStudentName' : 'سجل الطالب والتقييم العام 📖',
          style: const TextStyle(
            fontFamily: 'Dubai',
            color: Color(0xFF1E2822),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00875A),
          labelColor: const Color(0xFF00875A),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'التقييم العام والأداء 🏅'),
            Tab(text: 'الحلقات والجلسات 📝'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRecordTab(),
                _buildClassesTab(),
              ],
            ),
    );
  }

  Widget _buildRecordTab() {
    final finishedClassesCount = _classes.where((c) => c['is_finished'] == true).length;

    return RefreshIndicator(
      onRefresh: _loadRecordData,
      color: const Color(0xFF00875A),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // التقييم العام الحقيقي التراكمي
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00875A), Color(0xFF0E5039)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'التقييم العام — $_targetStudentName',
                    style: const TextStyle(
                      fontFamily: 'Dubai',
                      color: Color(0xFFFFDF73),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _rating.gradeLabel,
                    style: const TextStyle(fontFamily: 'Dubai', color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTopStat(
                        'المتوسط العام',
                        _rating.evaluatedCount > 0 ? '${_rating.averageOutOf10.toStringAsFixed(1)} / 10' : 'غير مقيم',
                      ),
                      _buildTopStat('نسبة الإتقان', '${_rating.percentage}% ⭐'),
                      _buildTopStat(
                        'الحلقات المقيّمة',
                        '${_rating.evaluatedCount > 0 ? _rating.evaluatedCount : finishedClassesCount} 🎙️',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'آخر تقييمات الحلقات:',
                      style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    if (_rating.records.isEmpty)
                      Text(
                        'لم تُسجل تقييمات بعد — يتحدث التقييم العام تلقائياً بعد كل تسميع يقيمه الشيخ.',
                        style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600),
                      )
                    else
                      ..._rating.records.take(6).map((r) {
                        final double sc = (r['score'] as num?)?.toDouble() ?? 0;
                        final bool isWarning = r['type'] == 'warning';
                        return Column(
                          children: [
                            _buildEvaluationRow(
                              r['circle_name'].toString(),
                              r['message'].toString(),
                              '${sc.toStringAsFixed(1)} / 10',
                              isWarning: isWarning,
                            ),
                            const Divider(),
                          ],
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00875A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AppreciationsScreen(
                      studentId: _targetStudentId,
                      studentName: _targetStudentName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.workspace_premium_rounded, color: Colors.white),
              label: const Text(
                'عرض كل التقديرات والتفاصيل 🏆',
                style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStat(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontFamily: 'Dubai', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Dubai', color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildEvaluationRow(String title, String details, String grade, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            color: isWarning ? Colors.orange : const Color(0xFF00875A),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                Text(details, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isWarning ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              grade,
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 11,
                color: isWarning ? Colors.deepOrange : const Color(0xFF00875A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesTab() {
    final List<Map<String, String>> homeworks = [];
    for (final r in _rating.records) {
      final msg = (r['message'] ?? '').toString();
      final match = RegExp(r'المقرر القادم:\s*(.+)$').firstMatch(msg);
      if (match != null && (match.group(1) ?? '').trim().isNotEmpty) {
        homeworks.add({
          'homework': match.group(1)!.trim(),
          'circle': (r['circle_name'] ?? 'حلقة تسميع').toString(),
          'date': (r['created_at'] ?? '').toString(),
        });
      }
    }

    if (_classes.isEmpty && homeworks.isEmpty) {
      return Center(
        child: Text(
          'لا توجد حلقات أو واجبات مسجلة حالياً',
          style: TextStyle(fontFamily: 'Dubai', fontSize: 14, color: Colors.grey.shade600),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (homeworks.isNotEmpty) ...[
          const Text(
            '📌 المقررات والواجبات القادمة:',
            style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 8),
          ...homeworks.map((hw) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: const Color(0xFFFFFDF5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: const Color(0xFF00875A).withOpacity(0.35)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hw['homework'] ?? '',
                        style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00875A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'من حلقة: ${hw['circle']}',
                        style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 12),
        ],
        if (_classes.isNotEmpty) ...[
          const Text(
            '🎙️ سجل الحلقات:',
            style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 8),
          ..._classes.map((c) {
            final bool done = c['is_finished'] == true;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            c['name'].toString(),
                            style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00875A)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: done ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            done ? 'منتهية ✅' : 'جارية ⏳',
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: done ? const Color(0xFF00875A) : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('المشرف: ${c['sheikh']}', style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.black87)),
                    if ((c['starts_at'] ?? '').toString().isNotEmpty)
                      Text('الموعد: ${c['starts_at']}', style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
