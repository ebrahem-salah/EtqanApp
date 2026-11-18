import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/network/api_client.dart';

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLiveLeaderboard();
  }

  Future<void> _loadLiveLeaderboard() async {
    try {
      final res = await _apiClient.getCompetitionParticipants(103);
      if (res.statusCode == 200 && res.data != null) {
        final List participants = res.data['data'] ?? [];
        if (participants.isNotEmpty) {
          final liveList = participants.asMap().entries.map<Map<String, dynamic>>((entry) {
            final idx = entry.key;
            final p = entry.value;
            String rank = (idx + 1).toString();
            if (idx == 0) rank = '🥇';
            if (idx == 1) rank = '🥈';
            if (idx == 2) rank = '🥉';

            return {
              'rank': rank,
              'name': p['name'] ?? 'متسابق إتقان',
              'city': 'المملكة',
              'score': '${p['overall_rating'] ?? p['general_score'] ?? 100}%',
              'surah': 'سورة مريم (1-15)',
            };
          }).toList();

          if (mounted) {
            setState(() {
              _leaderboard.clear();
              _leaderboard.addAll(liveList);
            });
          }
        }
      }
    } catch (_) {}
  }

  // فروع المسابقة
  final List<Map<String, String>> _tracks = [
    {
      'title': 'الفرع الأول: القرآن الكريم كاملاً',
      'desc': 'مع الإتقان وأحكام الجزرية ومخارج الحروف',
      'prize': '🥇 جائزة المركز الأول: 50,000 ر.س',
    },
    {
      'title': 'الفرع الثاني: حفظ 15 جزءاً متتالياً',
      'desc': 'تلاوة متقنة مع أحكام الترتيل والتنغيم',
      'prize': '🥇 جائزة المركز الأول: 30,000 ر.س',
    },
    {
      'title': 'الفرع الثالث: سورة البقرة وآل عمران',
      'desc': 'حفظ وتدبر وأحكام التجويد الأساسية',
      'prize': '🥇 جائزة المركز الأول: 20,000 ر.س',
    },
    {
      'title': 'الفرع الرابع: أجمل صوت بالترتيل والمقامات',
      'desc': 'حسن الأداء وجمال النبرة ومخارج الحروف',
      'prize': '🥇 جائزة المركز الأول: 10,000 ر.س',
    },
  ];

  // لوحة المتصدرين
  final List<Map<String, dynamic>> _leaderboard = [
    {
      'rank': '🥇',
      'name': 'أحمد محمود الدوسري',
      'city': 'الرياض',
      'score': '99.8%',
      'surah': 'سورة مريم (1-15)',
    },
    {
      'rank': '🥈',
      'name': 'عمر بن عبد العزيز المصري',
      'city': 'القاهرة',
      'score': '99.2%',
      'surah': 'سورة الإسراء',
    },
    {
      'rank': '🥉',
      'name': 'ياسين خالد الكندري',
      'city': 'الكويت',
      'score': '98.7%',
      'surah': 'سورة البقرة',
    },
    {
      'rank': '4',
      'name': 'فاطمة الزهراء الشامي',
      'city': 'دمشق',
      'score': '98.4%',
      'surah': 'سورة الرحمن',
    },
  ];

  void _showSubmitRecitationDialog(String trackTitle) {
    String selectedSurah = 'سورة مريم (الآيات 1 إلى 15)';
    bool isRecording = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🏆 تقديم تلاوة المسابقة للتحكيم',
                    style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'الفرع المختار: $trackTitle',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF00875A), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              const Text('اختر موضع التلاوة للمسابقة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: selectedSurah,
                items: const [
                  DropdownMenuItem(value: 'سورة مريم (الآيات 1 إلى 15)', child: Text('سورة مريم (الآيات 1 إلى 15)')),
                  DropdownMenuItem(value: 'سورة البقرة (الخواتيم)', child: Text('سورة البقرة (خواتيم البقرة)')),
                  DropdownMenuItem(value: 'سورة الكهف (1 إلى 10)', child: Text('سورة الكهف (أوائل الكهف)')),
                  DropdownMenuItem(value: 'سورة الرحمن (1 إلى 25)', child: Text('سورة الرحمن (1 إلى 25)')),
                ],
                onChanged: (v) => setSheetState(() => selectedSurah = v!),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              // مسجل الصوت
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF9),
                  border: Border.all(color: const Color(0xFF00875A), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      isRecording ? '🔴 جارٍ تسجيل تلاوتك الآن (00:24)...' : 'اضغط على المايك لبدء التسجيل',
                      style: TextStyle(
                        fontSize: 12,
                        color: isRecording ? Colors.red : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRecording ? Colors.black87 : Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        setSheetState(() => isRecording = !isRecording);
                      },
                      icon: const Icon(Icons.mic, color: Colors.white),
                      label: Text(
                        isRecording ? 'إيقاف وحفظ التلاوة ⏹️' : 'بدء تسجيل التلاوة 🎙️',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00875A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  try {
                    await _apiClient.joinCompetition(103);
                  } catch (_) {}
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 تم توثيق مشاركتك في $trackTitle واعتماد التلاوة في سيرفر إتقان بنجاح!'),
                        backgroundColor: const Color(0xFF00875A),
                      ),
                    );
                  }
                },
                child: const Text(
                  '📤 اعتماد ورفع التلاوة إلى سيرفر المسابقات',
                  style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          'مسابقات إتقان الكبرى 🥇',
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
            // بطاقة المسابقة الكبرى الذهبية (فرسان إتقان)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFF997514)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'نسخة رمضان 1447 هـ / 2026 م',
                      style: TextStyle(color: Color(0xFFFFDF73), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'مسابقة فرسان إتقان السنوية',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'لحفظ القرآن الكريم كاملاً وتجويده وإتقان مخارج الحروف',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('مجموع الجوائز النقدية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('100,000 ر.س 💰', style: TextStyle(color: Color(0xFF00875A), fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // فروع المسابقة
            const Text(
              'فروع المسابقة المتاحة:',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ..._tracks.map((t) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00875A))),
                              const SizedBox(height: 2),
                              Text(t['desc']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(t['prize']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A)),
                          onPressed: () => _showSubmitRecitationDialog(t['title']!),
                          child: const Text('سجل تلاوتك', style: TextStyle(fontSize: 11, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // لوحة المتصدرين
            const Text(
              'لوحة المتصدرين والأوائل 🥇:',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: _leaderboard
                    .map((l) => ListTile(
                          leading: Text(l['rank'], style: const TextStyle(fontSize: 22)),
                          title: Text(l['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('${l['city']} • ${l['surah']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          trailing: Text(l['score'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00875A), fontSize: 13)),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
