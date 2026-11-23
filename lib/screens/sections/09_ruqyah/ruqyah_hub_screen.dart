import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../call/live_recitation_room.dart';
import '../dialogs/create_section_session_dialog.dart';

class RuqyahHubScreen extends StatefulWidget {
  const RuqyahHubScreen({super.key});

  @override
  State<RuqyahHubScreen> createState() => _RuqyahHubScreenState();
}

class _RuqyahHubScreenState extends State<RuqyahHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _raqiProfiles = [
    {
      'id': 'raqi_1',
      'name': 'الراقي د. محمد كمال بو حسين',
      'title': 'خبير الرقية الشرعية المعتمدة والاستشفاء بالقرآن',
      'experience': 'أكثر من 20 عاماً في الرقية الشرعية بالأدلة الصحيحة',
      'sessionsCount': 1420,
      'rating': 4.9,
      'isLiveNow': true,
      'liveRoomId': 'room_ruqyah_direct_202',
      'viewers': 230,
      'icon': '🛡️',
      'audios': [
        'رقية إبطال السحر والعين والحسد كاملة (45 دقيقة)',
        'تحصين البيت والأنفس بآيات الحفظ والسكينة',
        'دعاء فك الكرب ودفع الوسواس والقلق',
      ],
    },
    {
      'id': 'raqi_2',
      'name': 'الراقي د. أحمد عبد المنعم',
      'title': 'استشاري العلاج بالرقية والطب النبوي',
      'experience': 'مدرس القراءات والرقية الشرعية بالأزهر الشريف',
      'sessionsCount': 980,
      'rating': 4.95,
      'isLiveNow': false,
      'viewers': 0,
      'icon': '🌿',
      'audios': [
        'الرقية الشرعية الشاملة للأطفال والرضع للسكينة والنوم',
        'رقية الشفاء من الأمراض المستعصية والآلام المزمنة',
        'أذكار الصباح والمساء المصحوبة بالرقية',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBookSessionDialog(BuildContext context, String raqiName) {
    String selectedSlot = 'اليوم - 8:30 مساءً';
    final List<String> availableSlots = [
      'اليوم - 8:30 مساءً',
      'اليوم - 10:00 مساءً',
      'غداً - 5:00 عصراً',
      'غداً - 9:00 مساءً',
      'بعد غد - 8:00 مساءً',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF00875A).withOpacity(0.12), shape: BoxShape.circle),
                      child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF00875A), size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Text('حجز جلسة رقية خاصة', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                const Divider(height: 22),
                Text('المعالج المعتمد: $raqiName', style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00875A))),
                const SizedBox(height: 6),
                const Text('نوع الجلسة: جلسة استشفاء فردية مشفرة (صوتية أو مرئية مدة 40 دقيقة).', style: TextStyle(fontFamily: 'Dubai', fontSize: 12, height: 1.4, color: Colors.black87)),
                const SizedBox(height: 14),

                const Text('اختر الموعد المناسب:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedSlot,
                      items: availableSlots.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontFamily: 'Dubai', fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedSlot = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00875A).withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.notifications_active_rounded, color: Color(0xFF00875A), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🔔 سيصلك تنبيه إشعار تلقائي على هاتفك قبل الموعد بـ 15 دقيقة مع رابط الدخول.',
                          style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Color(0xFF0F5B46), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00875A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await NotificationService().scheduleSessionReminder(
                        circleTitle: 'جلسة رقية مع $raqiName',
                        timeSlot: selectedSlot,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🎉 تم تأكيد حجز جلستك مع $raqiName ($selectedSlot)! تم تفعيل إشعار التذكير قبلها بـ 15 دقيقة.'),
                            backgroundColor: const Color(0xFF00875A),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                    child: const Text('تأكيد الحجز وتفعيل التذكير', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'الرقية الشرعية',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_rounded),
            tooltip: 'بدء بث رقية شرعية في الريلز',
            onPressed: () {
              CreateSectionSessionDialog.show(
                context,
                initialSection: 'الرقية الشرعية',
                initialSubSection: 'رقية مباشرة',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'رقية مباشرة حية'),
            Tab(text: 'د. محمد كمال بو حسين'),
            Tab(text: 'د. أحمد عبد المنعم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. رقية مباشرة
          _buildLiveRuqyahView(),
          // 2. د. محمد كمال بو حسين
          _buildRaqiView(_raqiProfiles[0]),
          // 3. د. أحمد عبد المنعم
          _buildRaqiView(_raqiProfiles[1]),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.live_tv_rounded),
        label: const Text('بدء بث رقية في الريلز', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
        onPressed: () {
          CreateSectionSessionDialog.show(
            context,
            initialSection: 'الرقية الشرعية',
            initialSubSection: 'رقية مباشرة',
          );
        },
      ),
    );
  }

  Widget _buildLiveRuqyahView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live Active Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE53935).withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xFFE53935), size: 7),
                        SizedBox(width: 4),
                        Text('جلسة رقية مباشرة الآن', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                      ],
                    ),
                  ),
                  const Text('👁️ 230 مستمع', style: TextStyle(fontFamily: 'Dubai', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'الرقية الشرعية العامة للتحصين والشفاء ودفع الأذى بالقرآن',
                style: TextStyle(fontFamily: 'Dubai', fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'الراقي: فضيلة د. محمد كمال بو حسين • آيات السكينة والشفاء والمعوذات',
                style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LiveRecitationRoom(
                          roomId: 'room_ruqyah_direct_202',
                          circleTitle: 'جلسة رقية شرعية عامة ومباشرة للتحصين والشفاء',
                          isSheikh: false,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  label: const Text('انضم إلى جلسة الرقية الحية الآن', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Rules of Ruqyah
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8E9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFC8E6C9)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF00875A), size: 20),
                  SizedBox(width: 8),
                  Text('شروط الرقية الشرعية المعتمدة بإتقان:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00875A))),
                ],
              ),
              SizedBox(height: 6),
              Text(
                '1. أن تكون بكلام الله تعالى وأسمائه وصفاته والمأثور عن النبي ﷺ.\n'
                '2. أن تكون باللسان العربي الواضح وبما يعرف معناه بغير طلاسم.\n'
                '3. أن يُعتقد أن الرقية لا تؤثر بذاتها بل بتقدير الله تعالى وحده.',
                style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.black87, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRaqiView(Map<String, dynamic> raqi) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFF1F8E9),
                child: Text(raqi['icon'] ?? '🛡️', style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 10),
              Text(raqi['name'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(raqi['title'], textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoCol('الجلسات المنجزة', '${raqi['sessionsCount']}+'),
                  _infoCol('التقييم', '⭐ ${raqi['rating']}'),
                  _infoCol('الحالة', raqi['isLiveNow'] ? '🔴 مباشر' : 'متاح للحجز'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showBookSessionDialog(context, raqi['name']),
                  icon: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                  label: const Text('حجز جلسة رقية شرعية خاصة', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Recorded Audios
        const Text('مقاطع الرقية الشرعية الصوتية المعتمدة:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        ...(raqi['audios'] as List<String>).map((audio) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1))],
            ),
            child: ListTile(
              leading: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF00875A), size: 32),
              title: Text(audio, style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.download_rounded, color: Colors.grey, size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('جارٍ تشغيل: $audio'), backgroundColor: const Color(0xFF00875A)),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _infoCol(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00875A))),
        Text(label, style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}
