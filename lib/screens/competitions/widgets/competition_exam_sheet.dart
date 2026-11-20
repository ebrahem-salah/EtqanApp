import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';

class CompetitionExamSheet extends StatefulWidget {
  final int competitionId;
  final int studentId;
  final String studentName;
  final VoidCallback? onEvaluationSubmitted;

  const CompetitionExamSheet({
    super.key,
    required this.competitionId,
    required this.studentId,
    this.studentName = 'المتسابق',
    this.onEvaluationSubmitted,
  });

  static void show(
    BuildContext context, {
    required int competitionId,
    required int studentId,
    String studentName = 'المتسابق',
    VoidCallback? onEvaluationSubmitted,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.92,
        child: CompetitionExamSheet(
          competitionId: competitionId,
          studentId: studentId,
          studentName: studentName,
          onEvaluationSubmitted: onEvaluationSubmitted,
        ),
      ),
    );
  }

  @override
  State<CompetitionExamSheet> createState() => _CompetitionExamSheetState();
}

class _CompetitionExamSheetState extends State<CompetitionExamSheet> {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  bool _isSubmitting = false;

  int _scopeJuz = 30; // 10, 15, or 30
  int _questionCount = 10; // 5 or 10
  int _versesCount = 10; // 10, 15, or 30

  List<Map<String, dynamic>> _questions = [];
  int _activeQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchExistingQuestions();
  }

  @override
  void dispose() {
    for (var q in _questions) {
      final ctrl = q['notes_controller'] as TextEditingController?;
      ctrl?.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchExistingQuestions() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.getStudentCompetitionQuestions(
        competitionId: widget.competitionId,
        studentId: widget.studentId,
      );

      if (res.statusCode == 200 && res.data != null && res.data['data'] != null) {
        final List list = res.data['data'];
        if (list.isNotEmpty) {
          _questions = list.map<Map<String, dynamic>>((q) {
            double err = double.tryParse(q['error_deduction']?.toString() ?? '0') ?? 0;
            double hes = double.tryParse(q['hesitation_deduction']?.toString() ?? '0') ?? 0;
            return {
              'id': q['id'],
              'from_surah_name': q['from_surah_name'] ?? 'سورة',
              'from_ayah': q['from_ayah'] ?? 1,
              'to_ayah': q['to_ayah'] ?? 10,
              'notes': q['notes'] ?? '',
              'errors': (err / 1.0).round(),
              'hesitations': (hes / 0.25).round(),
              'notes_controller': TextEditingController(text: q['notes'] ?? ''),
            };
          }).toList();
        }
      }
    } catch (_) {
      // If error or empty, will allow generating
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateQuestions() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.generateCompetitionQuestions(
        competitionId: widget.competitionId,
        studentId: widget.studentId,
        scopeJuz: _scopeJuz,
        questionCount: _questionCount,
        versesCount: _versesCount,
      );

      if (res.statusCode == 200 && res.data != null && res.data['data'] != null) {
        final List list = res.data['data'];
        setState(() {
          _questions = list.map<Map<String, dynamic>>((q) {
            return {
              'id': q['id'],
              'from_surah_name': q['from_surah_name'] ?? 'سورة',
              'from_ayah': q['from_ayah'] ?? 1,
              'to_ayah': q['to_ayah'] ?? 10,
              'notes': q['notes'] ?? '',
              'errors': 0,
              'hesitations': 0,
              'notes_controller': TextEditingController(text: q['notes'] ?? ''),
            };
          }).toList();
          _activeQuestionIndex = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎲 تم توليد ${_questions.length} أسئلة بنجاح موزعة بالتساوي على $_scopeJuz جزءاً دون تكرار!'),
            backgroundColor: const Color(0xFF00875A),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل توليد الأسئلة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _getQuestionScore(Map<String, dynamic> q) {
    int errors = q['errors'] ?? 0;
    int hesitations = q['hesitations'] ?? 0;
    double score = 10.0 - (errors * 1.0) - (hesitations * 0.25);
    return score < 0 ? 0 : score;
  }

  double _getTotalScore() {
    if (_questions.isEmpty) return 0.0;
    double sum = 0.0;
    for (var q in _questions) {
      sum += _getQuestionScore(q);
    }
    return sum;
  }

  double _getMaxScore() {
    return _questions.isEmpty ? 100.0 : (_questions.length * 10.0);
  }

  Future<void> _submitEvaluation() async {
    if (_questions.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final List<Map<String, dynamic>> evaluations = _questions.map((q) {
        int errors = q['errors'] ?? 0;
        int hesitations = q['hesitations'] ?? 0;
        final ctrl = q['notes_controller'] as TextEditingController?;

        return {
          'question_id': q['id'],
          'error_deduction': errors * 1.0,
          'hesitation_deduction': hesitations * 0.25,
          'notes': ctrl?.text ?? '',
        };
      }).toList();

      final res = await _apiClient.submitCompetitionEvaluation(
        competitionId: widget.competitionId,
        studentId: widget.studentId,
        evaluations: evaluations,
      );

      if (res.statusCode == 200) {
        widget.onEvaluationSubmitted?.call();

        if (mounted) {
          final totalScore = _getTotalScore();
          final maxScore = _getMaxScore();
          final pct = (totalScore / maxScore * 100).toStringAsFixed(1);

          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.stars_rounded, color: Color(0xFF00875A), size: 28),
                  SizedBox(width: 8),
                  Text('اعتماد نتيجة المتسابق 🏆', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('تم تثبيت درجات المتسابق: ${widget.studentName}'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$totalScore / $maxScore',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00875A),
                          ),
                        ),
                        Text(
                          'النسبة المئوية: $pct%',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'تم تحديث الترتيب العام في لوحة المتصدرين تلقائياً.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('إغلاق', style: TextStyle(color: Colors.white, fontFamily: 'Dubai')),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ التقييم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Color(0xFF00875A), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'استمارة تحكيم واختبار المتسابق',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'المتسابق: ${widget.studentName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontFamily: 'Dubai',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(),

          // Main body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Generator Controls Box
                        _buildGeneratorConfigCard(),
                        const SizedBox(height: 16),

                        if (_questions.isNotEmpty) ...[
                          // Questions Tabs
                          _buildQuestionsSelector(),
                          const SizedBox(height: 14),

                          // Active Question Card
                          _buildActiveQuestionCard(),
                          const SizedBox(height: 14),

                          // Live Rubric Scoring
                          _buildRubricScoringBox(),
                          const SizedBox(height: 20),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FBF9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.auto_stories_rounded, size: 48, color: Color(0xFF00875A)),
                                const SizedBox(height: 12),
                                const Text(
                                  'لم يتم توليد نموذج اختبار لهذا المتسابق بعد',
                                  style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'اضغط على زر "توليد أسئلة الاختبار آلياً" بالأعلى لتقسيم نطاق الحفظ بالتساوي وتوليد أسئلة عشوائية فريدة لكل طالب دون تكرار.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),

          // Bottom Bar (Total Score & Submit)
          if (_questions.isNotEmpty) _buildBottomEvaluationBar(),
        ],
      ),
    );
  }

  Widget _buildGeneratorConfigCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD0EADB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune_rounded, color: Color(0xFF00875A), size: 18),
              SizedBox(width: 6),
              Text(
                'إعدادات توليد نموذج الاختبار الذكي:',
                style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // نطاق الحفظ (10, 15, 30)
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _scopeJuz,
                  decoration: InputDecoration(
                    labelText: 'نطاق الأجزاء',
                    labelStyle: const TextStyle(fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('10 أجزاء (1-10)', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 15, child: Text('15 جزءاً (1-15)', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 30, child: Text('30 جزءاً (كامل)', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (v) => setState(() => _scopeJuz = v ?? 30),
                ),
              ),
              const SizedBox(width: 8),

              // عدد الأسئلة
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _questionCount,
                  decoration: InputDecoration(
                    labelText: 'عدد الأسئلة',
                    labelStyle: const TextStyle(fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 أسئلة', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 10, child: Text('10 أسئلة', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (v) => setState(() => _questionCount = v ?? 10),
                ),
              ),
              const SizedBox(width: 8),

              // عدد آيات السؤال
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _versesCount,
                  decoration: InputDecoration(
                    labelText: 'طول الموضع',
                    labelStyle: const TextStyle(fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('10 آيات', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 15, child: Text('15 آية', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 30, child: Text('30 آية', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (v) => setState(() => _versesCount = v ?? 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00875A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: _isLoading ? null : _generateQuestions,
              icon: const Icon(Icons.casino_rounded, size: 18),
              label: Text(
                _questions.isEmpty ? 'توليد أسئلة الاختبار آلياً 🎲' : 'إعادة توليد نموذج جديد 🔄',
                style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_questions.length, (idx) {
          final isSelected = idx == _activeQuestionIndex;
          final q = _questions[idx];
          final score = _getQuestionScore(q);

          return GestureDetector(
            onTap: () => setState(() => _activeQuestionIndex = idx),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00875A) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFF00875A) : Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'سؤال ${idx + 1}',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '${score.toStringAsFixed(1)} / 10',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFFFDF73) : const Color(0xFF00875A),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveQuestionCard() {
    final q = _questions[_activeQuestionIndex];
    final surahName = q['from_surah_name'];
    final fromAyah = q['from_ayah'];
    final toAyah = q['to_ayah'];
    final notes = q['notes']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: const Color(0xFF00875A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'السؤال (${_activeQuestionIndex + 1} / ${_questions.length})',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'سورة $surahName (الآيات $fromAyah - $toAyah)',
                style: const TextStyle(
                  fontFamily: 'Dubai',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF6D4C41),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Text(
              notes.isNotEmpty
                  ? notes
                  : 'اقرأ من قوله تعالى في سورة $surahName من الآية ($fromAyah) حتى الآية ($toAyah)',
              style: const TextStyle(
                fontFamily: 'Dubai',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.6,
                color: Color(0xFF1E2822),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRubricScoringBox() {
    final q = _questions[_activeQuestionIndex];
    int errors = q['errors'] ?? 0;
    int hesitations = q['hesitations'] ?? 0;
    double score = _getQuestionScore(q);
    final notesCtrl = q['notes_controller'] as TextEditingController?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'لوحة رصد أخطاء السؤال الحالي:',
                style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: score >= 8
                      ? const Color(0xFFE8F5E9)
                      : (score >= 5 ? const Color(0xFFFFF8E1) : const Color(0xFFFFEBEE)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'درجة السؤال: ${score.toStringAsFixed(2)} / 10',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: score >= 8
                        ? const Color(0xFF00875A)
                        : (score >= 5 ? Colors.orange.shade800 : Colors.red),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. أخطاء الحفظ الجلية (-1.00)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '❌ خطأ حفظ أو نسيان جلي',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red),
                  ),
                  Text(
                    'خصم (-1.00) درجة لكل خطأ',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: errors > 0
                        ? () => setState(() => q['errors'] = errors - 1)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$errors',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.red),
                    onPressed: () => setState(() => q['errors'] = errors + 1),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // 2. التردد والتلعثم والفتح (-0.25)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '⚠️ تلعثم / تردد / فتح الشيخ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
                  ),
                  Text(
                    'خصم (-0.25) درجة لكل تنبيه',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                    onPressed: hesitations > 0
                        ? () => setState(() => q['hesitations'] = hesitations - 1)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$hesitations',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.orange),
                    onPressed: () => setState(() => q['hesitations'] = hesitations + 1),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // ملاحظات المحكم
          TextField(
            controller: notesCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'ملاحظات المحكم على الأداء والتجويد والمخارج...',
              hintStyle: const TextStyle(fontSize: 12),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomEvaluationBar() {
    final total = _getTotalScore();
    final max = _getMaxScore();
    final pct = (total / max * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('المجموع الإجمالي:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                Row(
                  children: [
                    Text(
                      '${total.toStringAsFixed(1)} / $max',
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF00875A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$pct%',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00875A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isSubmitting ? null : _submitEvaluation,
                icon: _isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'اعتماد النتيجة وتحديث الترتيب 🏆',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
