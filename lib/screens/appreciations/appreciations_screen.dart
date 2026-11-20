import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';

class AppreciationsScreen extends StatefulWidget {
  const AppreciationsScreen({super.key});

  @override
  State<AppreciationsScreen> createState() => _AppreciationsScreenState();
}

class _AppreciationsScreenState extends State<AppreciationsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _appreciations = [
    {
      'id': 1,
      'student_name': 'أحمد محمود الدوسري',
      'title': 'شهادة تفوق وإتقان لحفظ سورة البقرة',
      'sheikh_name': 'الشيخ عبد الله السويسي',
      'date': '18/11/2026',
      'grade': 'ممتاز مرتفع (100%)',
    },
    {
      'id': 2,
      'student_name': 'عمر عبد العزيز المصري',
      'title': 'شهادة إتقان مخارج الحروف وأحكام النون الساكنة',
      'sheikh_name': 'الشيخ الدكتور إبراهيم المنشاوي',
      'date': '15/11/2026',
      'grade': 'إتقان تام (99%)',
    },
    {
      'id': 3,
      'student_name': 'ياسين خالد الكندري',
      'title': 'وسام الفارس القرآني لحفظ 15 جزءاً متتالياً',
      'sheikh_name': 'فضيلة الشيخ سعد علي',
      'date': '10/11/2026',
      'grade': 'جيد جداً مرتفع (98.5%)',
    },
  ];

  void _showSendAppreciationDialog() {
    final studentCtrl = TextEditingController();
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Color(0xFFD4AF37)),
            SizedBox(width: 8),
            Text('منح شهادة شكر وتقدير 🏆', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: studentCtrl,
              decoration: InputDecoration(
                labelText: 'اسم الطالب المتميز',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'موضوع التقدير أو السورة المتقنة',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00875A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (studentCtrl.text.isNotEmpty) {
                setState(() {
                  _appreciations.insert(0, {
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'student_name': studentCtrl.text,
                    'title': titleCtrl.text.isEmpty ? 'شهادة إتقان وتفوق قرآني' : titleCtrl.text,
                    'sheikh_name': 'فضيلة الشيخ المشرف',
                    'date': 'اليوم',
                    'grade': 'امتياز 100%',
                  });
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 تم إصدار وتوثيق شهادة الشكر والتقدير وإرسالها للطالب بنجاح!'),
                    backgroundColor: Color(0xFF00875A),
                  ),
                );
              }
            },
            child: const Text('إصدار الشهادة', style: TextStyle(color: Colors.white, fontFamily: 'Dubai')),
          ),
        ],
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
          'شهادات الشكر والتقدير 🏆',
          style: TextStyle(
            fontFamily: 'Dubai',
            color: Color(0xFF1E2822),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'إصدار شهادة تقدير',
            icon: const Icon(Icons.add_moderator_rounded, color: Color(0xFF00875A)),
            onPressed: _showSendAppreciationDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _appreciations.length,
        itemBuilder: (ctx, idx) {
          final a = _appreciations[idx];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFDF5), Colors.white],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
                        color: const Color(0xFFD4AF37).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Color(0xFFD4AF37), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            a['grade']!,
                            style: const TextStyle(color: Color(0xFF8C6D14), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text(a['date']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'تمنح منصة إتقان ومقرأتها الإلكترونية هذه الشهادة للطالب:',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  a['student_name']!,
                  style: const TextStyle(
                    fontFamily: 'Dubai',
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFF00875A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  a['title']!,
                  style: const TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2822),
                  ),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Color(0xFF00875A), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'توقيع: ${a['sheikh_name']}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD4AF37), size: 28),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
