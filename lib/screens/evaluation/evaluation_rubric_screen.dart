import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EvaluationRubricScreen extends StatefulWidget {
  final String studentName;
  final String sheikhName;
  final String surahTested;

  const EvaluationRubricScreen({
    super.key,
    this.studentName = 'أحمد عبد المنعم موسى',
    this.sheikhName = 'الشيخ عبد الله السويسي',
    this.surahTested = 'سورة الفاتحة وأول سورة البقرة (1-20)',
  });

  @override
  State<EvaluationRubricScreen> createState() => _EvaluationRubricScreenState();
}

class _EvaluationRubricScreenState extends State<EvaluationRubricScreen> {
  double _makharijScore = 24.0; // out of 25
  double _ahkamScore = 23.0;    // out of 25
  double _mudoodScore = 25.0;   // out of 25
  double _waqfScore = 23.0;     // out of 25

  final TextEditingController _notesController = TextEditingController(
    text: 'تلاوة طيبة ومتقنة، تميز الطالب في ضبط أزمنة المدود ومخارج الحروف الحلقية. يرجى التركيز أكثر على ترقيق الراء المكسورة عند الوقف.',
  );

  bool _isVoiceMemoRecorded = true;

  double get _totalScore => _makharijScore + _ahkamScore + _mudoodScore + _waqfScore;

  String get _gradeTier {
    if (_totalScore >= 95) return 'ممتاز مرتفع مع مرتبة الشرف 🏆';
    if (_totalScore >= 85) return 'ممتاز ⭐';
    if (_totalScore >= 75) return 'جيد جداً 👍';
    return 'جيد (بحاجة لتدريب إضافي)';
  }

  Color get _tierColor {
    if (_totalScore >= 90) return const Color(0xFF00875A);
    if (_totalScore >= 75) return const Color(0xFFB78103);
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'استمارة تقييم التلاوة والتجويد',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student & Session Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E0C8)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('👨‍🎓', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.studentName,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF191919),
                          ),
                        ),
                        Text(
                          'المقرر: ${widget.surahTested}',
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'المشرف: ${widget.sheikhName}',
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Score Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _tierColor,
                    _tierColor.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _tierColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الدرجة الإجمالية للتلاوة:',
                        style: TextStyle(fontFamily: 'Dubai', color: Colors.white, fontSize: 13),
                      ),
                      Text(
                        _gradeTier,
                        style: const TextStyle(
                          fontFamily: 'Dubai',
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _totalScore.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        ' / 100',
                        style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4 Criteria Rubric
            const Text(
              'معايير التقييم وأحكام التجويد:',
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 10),

            _buildRubricSlider(
              title: '1. مخارج الحروف وصفاتها الذاتية',
              subtitle: 'الحلق، اللسان، الشفتان، الاستعلاء، الهمس، القلقلة',
              val: _makharijScore,
              onChanged: (v) => setState(() => _makharijScore = v),
            ),

            _buildRubricSlider(
              title: '2. أحكام النون الساكنة والتنوين والميم',
              subtitle: 'الإظهار، الإدغام بغنة وبغير غنة، الإقلاب، الإخفاء',
              val: _ahkamScore,
              onChanged: (v) => setState(() => _ahkamScore = v),
            ),

            _buildRubricSlider(
              title: '3. أزمنة المدود والغنن',
              subtitle: 'المد الطبيعي، المتصل والمنفصل، اللازم، العارض للسكون',
              val: _mudoodScore,
              onChanged: (v) => setState(() => _mudoodScore = v),
            ),

            _buildRubricSlider(
              title: '4. الوقف والابتداء وحسن الصوت والترتيل',
              subtitle: 'الوقف التام والكافي والحسن، تجنب القبيح، والتنغيم',
              val: _waqfScore,
              onChanged: (v) => setState(() => _waqfScore = v),
            ),
            const SizedBox(height: 12),

            // Sheikh Feedback / Notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E0C8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ملاحظات وتوجيهات المقرئ:',
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isVoiceMemoRecorded = !_isVoiceMemoRecorded;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isVoiceMemoRecorded
                                    ? '🎙️ تم تسجيل ملاحظة صوتية بصوت الشيخ (0:45 ثانية)'
                                    : 'تم حذف الملاحظة الصوتية',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isVoiceMemoRecorded ? AppColors.primary : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.mic,
                                size: 14,
                                color: _isVoiceMemoRecorded ? Colors.white : Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isVoiceMemoRecorded ? 'صوتية مسجلة ✓' : 'تسجيل صوتي',
                                style: TextStyle(
                                  fontFamily: 'Dubai',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _isVoiceMemoRecorded ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'Dubai', fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9F9F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      hintText: 'اكتب توجيهاتك للطالب ليطلع عليها في ملفه الشخصي...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Issue Certificate Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              icon: const Icon(Icons.workspace_premium, color: AppColors.gold, size: 24),
              label: const Text(
                'إصدار وتوثيق شهادة إتقان التلاوة',
                style: TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () => _showDigitalCertificate(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRubricSlider({
    required String title,
    required String subtitle,
    required double val,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E0C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Dubai',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF191919),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${val.toStringAsFixed(0)} / 25',
                  style: const TextStyle(
                    fontFamily: 'Dubai',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: AppColors.gold,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: val,
              min: 10,
              max: 25,
              divisions: 15,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showDigitalCertificate(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Seal
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'مَنظومة إِتْـقَان العَالَمِيَّة',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'شهادة إتقان وضبط التلاوة',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191919),
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  width: 120,
                  height: 2,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 14),

                const Text(
                  'يشهد فضيلة الشيخ / المقرئ المشرف بأن الدارس:',
                  style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.studentName,
                  style: const TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'قد أتم بنجاح تلاوة واختبار:\n${widget.surahTested}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 13,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF6F1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('التقدير: ', style: TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.black87)),
                      Text(
                        '${_totalScore.toStringAsFixed(0)}% ($_gradeTier)',
                        style: const TextStyle(
                          fontFamily: 'Dubai',
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('توقيع المقرئ:', style: TextStyle(fontFamily: 'Dubai', fontSize: 10, color: Colors.grey)),
                        Text(widget.sheikhName, style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('الرمز التوثيقي:', style: TextStyle(fontFamily: 'Dubai', fontSize: 10, color: Colors.grey)),
                        Text('ETQ-2026-9842', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.gold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Dialog Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.download, color: Colors.white, size: 18),
                        label: const Text('تحميل الشهادة', style: TextStyle(fontFamily: 'Dubai', color: Colors.white)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('📥 تم حفظ الشهادة في معرض الصور بصيغة PDF/PNG')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
