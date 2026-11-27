import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/student_rating_service.dart';
import '../../core/utils/app_feedback.dart';
import '../../providers/auth_provider.dart';

class AppreciationsScreen extends StatefulWidget {
  final int? studentId;
  final String? studentName;

  const AppreciationsScreen({
    super.key,
    this.studentId,
    this.studentName,
  });

  @override
  State<AppreciationsScreen> createState() => _AppreciationsScreenState();
}

class _AppreciationsScreenState extends State<AppreciationsScreen> {
  bool _isLoading = true;
  StudentRatingSummary _summary = StudentRatingSummary.empty;
  String _targetName = 'الطالب';

  @override
  void initState() {
    super.initState();
    _loadAppreciations();
  }

  Future<void> _loadAppreciations() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.currentUser;
      final int? targetId = widget.studentId ?? user?.id;
      _targetName = widget.studentName ?? user?.name ?? 'الطالب';

      if (targetId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final res = await StudentRatingService.instance.fetchStudentRating(targetId);
      if (mounted) {
        setState(() {
          _summary = res;
        });
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'جلب التقديرات والتقييمات', e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        title: const Text(
          'التقييم العام والتقديرات 🏆',
          style: TextStyle(
            fontFamily: 'Dubai',
            color: Color(0xFF1E2822),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAppreciations,
        color: const Color(0xFF00875A),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // بطاقة التقييم العام التراكمي
                  Container(
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00875A), Color(0xFF0E5039)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _targetName,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _summary.evaluatedCount > 0
                              ? '${_summary.averageOutOf10.toStringAsFixed(1)} / 10  (${_summary.percentage}%)'
                              : 'لم يُقيّم بعد',
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFFFFDF73),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _summary.gradeLabel,
                          style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatChip('الحلقات المقيّمة', '${_summary.evaluatedCount}'),
                            _buildStatChip('تقديرات إيجابية', '${_summary.thankCount}'),
                            _buildStatChip('تنبيهات', '${_summary.warningCount}'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (_summary.records.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.workspace_premium_outlined, size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text(
                            'لا توجد تقييمات أو شهادات تقدير مسجلة حتى الآن',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Dubai', fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._summary.records.map((a) {
                      final bool isWarning = a['type'] == 'warning';
                      final double score = (a['score'] as num?)?.toDouble() ?? 0.0;
                      final rawDate = (a['created_at'] ?? '').toString();
                      final String dateText = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isWarning
                                ? Colors.orange.withOpacity(0.5)
                                : const Color(0xFFD4AF37).withOpacity(0.45),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isWarning
                                        ? const Color(0xFFFFF3E0)
                                        : const Color(0xFFD4AF37).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isWarning ? Icons.warning_amber_rounded : Icons.stars_rounded,
                                        color: isWarning ? Colors.deepOrange : const Color(0xFFD4AF37),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${score.toStringAsFixed(1)} / 10',
                                        style: TextStyle(
                                          fontFamily: 'Dubai',
                                          color: isWarning ? Colors.deepOrange : const Color(0xFF8C6D14),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(dateText, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              (a['circle_name'] ?? 'حلقة تسميع').toString(),
                              style: const TextStyle(
                                fontFamily: 'Dubai',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF00875A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (a['message'] ?? '').toString(),
                              style: const TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: 13,
                                height: 1.5,
                                color: Color(0xFF1E2822),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
      ),
    );
  }

  Widget _buildStatChip(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontFamily: 'Dubai', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(fontFamily: 'Dubai', color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
