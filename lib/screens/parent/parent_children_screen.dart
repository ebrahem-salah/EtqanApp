import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/parent_children_service.dart';
import '../../core/services/student_rating_service.dart';
import '../../core/utils/app_feedback.dart';
import '../../providers/auth_provider.dart';
import '../student/student_record_screen.dart';

class ParentChildrenScreen extends StatefulWidget {
  const ParentChildrenScreen({super.key});

  @override
  State<ParentChildrenScreen> createState() => _ParentChildrenScreenState();
}

class _ParentChildrenScreenState extends State<ParentChildrenScreen> {
  bool _isLoading = true;
  List<LinkedChildItem> _children = [];
  final Map<int, StudentRatingSummary> _summaries = {};

  @override
  void initState() {
    super.initState();
    _loadChildrenData();
  }

  int get _parentId => Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? 0;

  Future<void> _loadChildrenData() async {
    setState(() => _isLoading = true);
    try {
      final parentId = _parentId;
      final list = await ParentChildrenService.instance.getChildren(parentId);
      final Map<int, StudentRatingSummary> nextSummaries = {};

      for (final child in list) {
        try {
          final summary = await StudentRatingService.instance.fetchStudentRating(child.studentId);
          nextSummaries[child.studentId] = summary;
          await ParentChildrenService.instance.checkAndNotifyNewAlert(
            parentUserId: parentId,
            child: child,
            summary: summary,
          );
        } catch (_) {
          nextSummaries[child.studentId] = StudentRatingSummary.empty;
        }
      }

      if (mounted) {
        setState(() {
          _children = list;
          _summaries
            ..clear()
            ..addAll(nextSummaries);
        });
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'تحميل بيانات الأبناء', e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddChildDialog() async {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'إضافة ابن / طالب للمتابعة 👨‍👧‍👦',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'أدخل كود المتابعة الموجود في صفحة سجل الطالب (مثل ETQ-138 أو الرقم 138):',
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: codeCtrl,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'ETQ-138',
                hintStyle: const TextStyle(fontFamily: 'Dubai'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameCtrl,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'اسم الابن في حسابك (اختياري، مثل: يوسف)',
                hintStyle: const TextStyle(fontFamily: 'Dubai', fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Dubai', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ربط الحساب', style: TextStyle(fontFamily: 'Dubai', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final int? parsedId = ParentChildrenService.parseStudentId(codeCtrl.text);
    if (parsedId == null) {
      AppFeedback.showError(context, 'كود غير صالح', 'يرجى كتابة كود صحيح مثل ETQ-138 أو رقم الطالب');
      return;
    }

    try {
      await ParentChildrenService.instance.addChild(
        _parentId,
        studentId: parsedId,
        name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
      );
      if (mounted) {
        AppFeedback.showSuccess(context, 'تم ربط الطالب (${ParentChildrenService.buildFollowCode(parsedId)}) بمتابعتك بنجاح ✅');
      }
      await _loadChildrenData();
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'ربط الطالب', e);
      }
    }
  }

  Future<void> _confirmRemoveChild(LinkedChildItem child) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إزالة من القائمة', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
        content: Text(
          'هل تريد إلغاء ربط "${child.name}" (${child.followCode}) من قائمة المتابعة؟',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Dubai'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Dubai'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('إزالة', style: TextStyle(fontFamily: 'Dubai', color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ParentChildrenService.instance.removeChild(_parentId, child.studentId);
      await _loadChildrenData();
    }
  }

  String? _extractNextHomework(StudentRatingSummary summary) {
    for (final r in summary.records) {
      final msg = (r['message'] ?? '').toString();
      final m = RegExp(r'المقرر القادم:\s*(.+)$').firstMatch(msg);
      if (m != null && (m.group(1) ?? '').trim().isNotEmpty) {
        return m.group(1)!.trim();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFBE8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF191919)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'متابعة الأبناء والحضور 👨‍👧‍👦',
            style: TextStyle(
              fontFamily: 'Dubai',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF191919),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00875A)),
              onPressed: _loadChildrenData,
              tooltip: 'تحديث',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF00875A),
          onPressed: _showAddChildDialog,
          icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
          label: const Text(
            'إضافة ابن بالكود',
            style: TextStyle(fontFamily: 'Dubai', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)))
            : RefreshIndicator(
                onRefresh: _loadChildrenData,
                color: const Color(0xFF00875A),
                child: _children.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 50),
                          Icon(Icons.family_restroom_rounded, size: 72, color: const Color(0xFF00875A).withOpacity(0.7)),
                          const SizedBox(height: 16),
                          const Text(
                            'لم تقم بإضافة أي طالب لمتابعته بعد',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF191919)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'اطلب من ابنك فتح صفحة "سجل الطالب وكود ولي الأمر" في تطبيقه ونسخ كود المتابعة (مثل ETQ-138)، ثم أضفه هنا لتصلك إشعارات الحضور والغياب ومستوى الحفظ.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.grey.shade700, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00875A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _showAddChildDialog,
                            icon: const Icon(Icons.add_rounded, color: Colors.white),
                            label: const Text(
                              'إضافة أول طالب الآن',
                              style: TextStyle(fontFamily: 'Dubai', fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                        itemCount: _children.length,
                        itemBuilder: (ctx, i) {
                          final child = _children[i];
                          final summary = _summaries[child.studentId] ?? StudentRatingSummary.empty;
                          final alert = summary.latestAlert;
                          final nextHw = _extractNextHomework(summary);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: const Color(0xFF00875A).withOpacity(0.12),
                                        child: const Icon(Icons.school_rounded, color: Color(0xFF00875A)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              child.name,
                                              style: const TextStyle(
                                                fontFamily: 'Dubai',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF191919),
                                              ),
                                            ),
                                            Text(
                                              'كود المتابعة: ${child.followCode} • ${summary.gradeLabel}',
                                              style: TextStyle(fontFamily: 'Dubai', fontSize: 11.5, color: Colors.grey.shade700),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                        onPressed: () => _confirmRemoveChild(child),
                                        tooltip: 'إزالة',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (alert != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: alert['attendance_status'] == 'absent'
                                            ? Colors.red.shade50
                                            : Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: alert['attendance_status'] == 'absent'
                                              ? Colors.red.shade200
                                              : Colors.orange.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            alert['attendance_status'] == 'absent'
                                                ? Icons.notification_important_rounded
                                                : Icons.warning_amber_rounded,
                                            color: alert['attendance_status'] == 'absent'
                                                ? Colors.red.shade700
                                                : Colors.orange.shade800,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  alert['attendance_status'] == 'absent'
                                                      ? 'آخر تنبيه: غياب عن الحلقة ❌'
                                                      : 'آخر تنبيه: حضر ولم يُسمّع ⚠️',
                                                  style: TextStyle(
                                                    fontFamily: 'Dubai',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: alert['attendance_status'] == 'absent'
                                                        ? Colors.red.shade800
                                                        : Colors.orange.shade900,
                                                  ),
                                                ),
                                                Text(
                                                  (alert['message'] ?? '').toString(),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.black87),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  Row(
                                    children: [
                                      _buildChildStat(
                                        'التقييم العام',
                                        summary.evaluatedCount > 0
                                            ? '${summary.averageOutOf10.toStringAsFixed(1)}/10'
                                            : '--',
                                        const Color(0xFF00875A),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildChildStat(
                                        'نسبة الحضور',
                                        summary.evaluatedCount > 0 ? '${summary.attendanceRate}%' : '--',
                                        summary.absentCount > 0 ? Colors.deepOrange : Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildChildStat(
                                        'حاضر / غياب',
                                        '${summary.presentCount} / ${summary.absentCount}',
                                        Colors.black87,
                                      ),
                                    ],
                                  ),
                                  if (nextHw != null) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '📌 المقرر القادم: $nextHw',
                                        style: const TextStyle(
                                          fontFamily: 'Dubai',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0E5039),
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF191919),
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => StudentRecordScreen(
                                            studentId: child.studentId,
                                            studentName: child.name,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.menu_book_rounded, size: 17, color: Colors.white),
                                    label: const Text(
                                      'فتح سجل الطالب الكامل 📖',
                                      style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
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

  Widget _buildChildStat(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            Text(label, style: TextStyle(fontFamily: 'Dubai', fontSize: 10.5, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
