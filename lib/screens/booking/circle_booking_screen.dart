import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/supabase_service.dart';
import '../call/live_recitation_room.dart';

class CircleBookingScreen extends StatefulWidget {
  final String circleTitle;
  final String sheikhName;
  final String categoryName;

  const CircleBookingScreen({
    super.key,
    this.circleTitle = 'حلقة تصحيح سورة مريم وأحكام التجويد',
    this.sheikhName = 'الشيخ عبد الله السويسي',
    this.categoryName = 'سورة مريم',
  });

  @override
  State<CircleBookingScreen> createState() => _CircleBookingScreenState();
}

class _CircleBookingScreenState extends State<CircleBookingScreen> {
  int _selectedDayIndex = 0;
  int _selectedTimeIndex = 0;
  String _selectedEdition = 'الشمرلي';
  bool _isVideoCall = false;

  // نوع الجلسة: مجانية (0 ر.س - بدون خصم) أو مدفوعة خاصة (35 ر.س من المحفظة)
  bool _isPaidSession = false;
  double _walletCashBalance = 150.00; // رصيد المحفظة النقدي المتاح

  late final List<Map<String, String>> _availableDays;

  @override
  void initState() {
    super.initState();
    _availableDays = _generateUpcomingDays();
  }

  List<Map<String, String>> _generateUpcomingDays() {
    final now = DateTime.now();
    final List<String> arabicWeekdays = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
    ];
    final List<String> arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];

    return List.generate(7, (i) {
      final date = now.add(Duration(days: i));
      String dayName;
      if (i == 0) {
        dayName = 'اليوم';
      } else if (i == 1) {
        dayName = 'غداً';
      } else {
        dayName = arabicWeekdays[date.weekday - 1];
      }
      final dateString = '${date.day} ${arabicMonths[date.month - 1]}';
      return {
        'day': dayName,
        'date': dateString,
        'fullDate': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      };
    });
  }

  final List<String> _availableTimes = [
    '04:00 م - 04:30 م',
    '05:30 م - 06:00 م',
    '07:00 م - 07:30 م',
    '09:00 م - 09:30 م',
  ];

  void _confirmBooking() async {
    final selectedDay = _availableDays[_selectedDayIndex]['day']!;
    final selectedTime = _availableTimes[_selectedTimeIndex];

    if (!_isPaidSession) {
      // حلقة عامة مجانية: بدون أي خصم من رصيد المحفظة
      await SupabaseService().createBooking(
        studentName: 'الطالب (أحمد)',
        sheikhName: 'الشيخ محمد السويسي',
        circleTitle: 'حلقة إتقان القرآن الكريم',
        timeSlot: '$selectedDay - $selectedTime',
        roomId: 'circle_free_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ تم تأكيد حجز الحلقة العامة بنجاح مجاناً!\nالموعد: $selectedDay $selectedTime\nرصيدك بالمحفظة لم يتأثر (${_walletCashBalance.toStringAsFixed(2)} ر.س)',
          ),
          backgroundColor: const Color(0xFF00875A),
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LiveRecitationRoom(
            roomId: 'room_${DateTime.now().millisecondsSinceEpoch}',
            circleTitle: widget.circleTitle,
            isSheikh: false,
          ),
        ),
      );
    } else {
      // حلقة مدفوعة خاصة: تتطلب خصم 35 ر.س من المحفظة
      const sessionFee = 35.00;
      if (_walletCashBalance < sessionFee) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('⚠️ رصيد المحفظة غير كافٍ'),
            content: Text(
              'رصيدك الحالي (${_walletCashBalance.toStringAsFixed(2)} ر.س) لا يكفي لحجز الجلسة الخاصة (${sessionFee.toStringAsFixed(2)} ر.س).\nيرجى شحن محفظتك أولاً.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // فتح شحن المحفظة
                },
                child: const Text('شحن المحفظة الآن', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        _walletCashBalance -= sessionFee;
      });

      await SupabaseService().createBooking(
        studentName: 'الطالب (أحمد)',
        sheikhName: 'الشيخ محمد السويسي',
        circleTitle: 'جلسة خاصة VIP',
        timeSlot: '$selectedDay - $selectedTime',
        roomId: 'circle_vip_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ تم تأكيد حجز الجلسة الخاصة بنجاح!\nتم خصم ${sessionFee.toStringAsFixed(2)} ر.س من المحفظة.\nرصيدك المتبقي: ${_walletCashBalance.toStringAsFixed(2)} ر.س',
          ),
          backgroundColor: const Color(0xFF00875A),
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LiveRecitationRoom(
            roomId: 'room_vip_${DateTime.now().millisecondsSinceEpoch}',
            circleTitle: 'جلسة خاصة 1-on-1: ${widget.circleTitle}',
            isSheikh: false,
          ),
        ),
      );
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
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'إجازة بالسند المتصل برواية حفص عن عاصم',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 12,
                            color: Color(0xFF00875A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            SizedBox(width: 4),
                            Text(
                              '4.9 (184 تقييم) • 1,240 ساعة تدريس',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // نوع الجلسة (مجانية بدون خصم vs خاصة بخصم 35 ر.س)
            const Text(
              'اختر نوع الجلسة والرسوم:',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // كارت الحلقة العامة المجانية
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isPaidSession = false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: !_isPaidSession ? const Color(0xFFE8F5E9) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_isPaidSession ? const Color(0xFF00875A) : Colors.grey.shade300,
                          width: !_isPaidSession ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('🟢', style: TextStyle(fontSize: 18)),
                              Text(
                                'مجاناً 100%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF00875A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'حلقة عامة مفتوحة',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'بدون خصم من المحفظة',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // كارت الجلسة الخاصة المدفوعة
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isPaidSession = true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isPaidSession ? const Color(0xFFFFFDF5) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isPaidSession ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                          width: _isPaidSession ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('⭐', style: TextStyle(fontSize: 18)),
                              Text(
                                'خاصة VIP',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'جلسة فردية خاصة',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'خصم 35 ر.س من المحفظة',
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // الأيام المتاحة
            const Text(
              'اختر اليوم المناسب:',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableDays.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = _availableDays[index];
                  final isSelected = index == _selectedDayIndex;
                  return InkWell(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00875A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00875A) : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day['day']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            day['date']!,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // المواعيد المتاحة
            const Text(
              'اختر الموعد المتاح:',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 3,
              ),
              itemCount: _availableTimes.length,
              itemBuilder: (context, index) {
                final time = _availableTimes[index];
                final isSelected = index == _selectedTimeIndex;
                return InkWell(
                  onTap: () => setState(() => _selectedTimeIndex = index),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00875A).withOpacity(0.12) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00875A) : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF00875A) : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // زر تأكيد الحجز
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00875A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _confirmBooking,
              child: Text(
                !_isPaidSession
                    ? '✓ تأكيد حجز الموعد مجاناً (بدون خصم من المحفظة)'
                    : '🔒 تأكيد حجز الجلسة الخاصة (35.00 ر.س من المحفظة)',
                style: const TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
