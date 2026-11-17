import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../call/live_recitation_room.dart';

class CircleBookingScreen extends StatefulWidget {
  final String circleTitle;
  final String sheikhName;
  final String categoryName;

  const CircleBookingScreen({
    super.key,
    this.circleTitle = 'حلقة تصحيح سورة البقرة وأحكام التجويد',
    this.sheikhName = 'الشيخ عبد الله السويسي',
    this.categoryName = 'سورة البقرة',
  });

  @override
  State<CircleBookingScreen> createState() => _CircleBookingScreenState();
}

class _CircleBookingScreenState extends State<CircleBookingScreen> {
  int _selectedDayIndex = 0;
  int _selectedTimeIndex = 0;
  String _selectedEdition = 'الشمرلي';
  bool _isVideoCall = false;

  final List<Map<String, String>> _availableDays = [
    {'day': 'اليوم', 'date': '17 نوفمبر'},
    {'day': 'الأربعاء', 'date': '18 نوفمبر'},
    {'day': 'الخميس', 'date': '19 نوفمبر'},
    {'day': 'الجمعة', 'date': '20 نوفمبر'},
  ];

  final List<String> _availableTimes = [
    '04:00 م - 04:30 م',
    '05:30 م - 06:00 م',
    '07:00 م - 07:30 م',
    '09:00 م - 09:30 م',
  ];

  void _confirmBooking() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ تم تأكيد حجز موعدك مع ${widget.sheikhName} بنجاح!'),
        backgroundColor: const Color(0xFF00875A),
      ),
    );

    // الانتقال لغرفة التسميع
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LiveRecitationRoom(
          roomId: 'room_${DateTime.now().millisecondsSinceEpoch}',
          circleTitle: widget.circleTitle,
          isSheikh: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الأصلية
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2822)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'حجز جلسة تسميع',
          style: TextStyle(
            fontFamily: 'Dubai',
            color: Color(0xFF1E2822),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة الشيخ المشرف
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF00875A).withOpacity(0.15),
                    child: const Text('👳‍♂️', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.sheikhName,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2822),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'مجاز في القراءات العشر | مقرأة الحرمين',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            SizedBox(width: 4),
                            Text('4.9 (140 تقييم)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // عنوان الجلسة
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF00875A).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00875A).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: Color(0xFF00875A)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('موضوع الجلسة المقررة:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(
                          widget.circleTitle,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF00875A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 1. اختيار اليوم
            const Text(
              '1. اختر موعد الجلسة:',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_availableDays.length, (index) {
                  final isSelected = _selectedDayIndex == index;
                  final item = _availableDays[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDayIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00875A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? const Color(0xFF00875A) : Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(
                              item['day']!,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['date']!,
                              style: TextStyle(
                                color: isSelected ? Colors.white70 : Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // 2. اختيار الساعة
            const Text(
              '2. اختر وقت الجلسة المتاح:',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_availableTimes.length, (index) {
                final isSelected = _selectedTimeIndex == index;
                return InkWell(
                  onTap: () => setState(() => _selectedTimeIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF191919) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? const Color(0xFF191919) : Colors.grey.shade300),
                    ),
                    child: Text(
                      _availableTimes[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 22),

            // 3. نمط الجلسة في ZEGOCLOUD (صوتية أو فيديو)
            const Text(
              '3. نوع الاتصال المفضل:',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('🎙️ مكالمة صوتية عالية النقاء'),
                    selected: !_isVideoCall,
                    selectedColor: const Color(0xFF00875A),
                    labelStyle: TextStyle(
                      color: !_isVideoCall ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (val) => setState(() => _isVideoCall = !val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('📹 مكالمة فيديو كول'),
                    selected: _isVideoCall,
                    selectedColor: const Color(0xFF00875A),
                    labelStyle: TextStyle(
                      color: _isVideoCall ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (val) => setState(() => _isVideoCall = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 4. طبعة المصحف
            const Text(
              '4. طبعة المصحف المعتمدة للتسميع:',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _selectedEdition == 'الشمرلي' ? const Color(0xFF00875A).withOpacity(0.12) : Colors.white,
                      side: BorderSide(color: _selectedEdition == 'الشمرلي' ? const Color(0xFF00875A) : Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => setState(() => _selectedEdition = 'الشمرلي'),
                    child: const Text('📖 طبعة الشمرلي (المصرية)', style: TextStyle(color: Color(0xFF00875A), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _selectedEdition == 'مجمع الملك فهد' ? const Color(0xFF00875A).withOpacity(0.12) : Colors.white,
                      side: BorderSide(color: _selectedEdition == 'مجمع الملك فهد' ? const Color(0xFF00875A) : Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => setState(() => _selectedEdition = 'مجمع الملك فهد'),
                    child: const Text('📖 مجمع الملك فهد', style: TextStyle(color: Color(0xFF00875A), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // زر تأكيد الحجز
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00875A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _confirmBooking,
                child: const Text(
                  'تأكيد الحجز ودخول الجلسة المباشرة',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
