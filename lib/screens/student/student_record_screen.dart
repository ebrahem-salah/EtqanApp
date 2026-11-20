import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../appreciations/appreciations_screen.dart';

class StudentRecordScreen extends StatefulWidget {
  const StudentRecordScreen({super.key});

  @override
  State<StudentRecordScreen> createState() => _StudentRecordScreenState();
}

class _StudentRecordScreenState extends State<StudentRecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _homeworkList = [
    {
      'surah': 'سورة البقرة (الآيات 200 إلى 225)',
      'due': 'غداً بعد صلاة العصر',
      'sheikh': 'الشيخ عبد الله السويسي',
      'status': 'مطلوب التسميع ⏳',
      'is_done': false,
    },
    {
      'surah': 'سورة آل عمران (أول 50 آية)',
      'due': 'الخميس القادم',
      'sheikh': 'الشيخ الدكتور إبراهيم المنشاوي',
      'status': 'مكتمل ومجاز ✅',
      'is_done': true,
    },
    {
      'surah': 'مراجعة الجزء الثلاثين كاملاً',
      'due': 'منتهي',
      'sheikh': 'الشيخ سعد علي',
      'status': 'إتقان 100% 🌟',
      'is_done': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text(
          'سجل الطالب والواجبات 📖',
          style: TextStyle(
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
            Tab(text: 'مسيرة الحفظ والإنجاز 🏅'),
            Tab(text: 'الواجبات والتسميع 📝'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. مسيرة الإنجاز
          _buildRecordTab(),

          // 2. الواجبات والتسميع
          _buildHomeworkTab(),
        ],
      ),
    );
  }

  Widget _buildRecordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الإحصائيات العامة
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
                const Text('المسيرة القرآنية المباركة', style: TextStyle(color: Color(0xFFFFDF73), fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTopStat('الأجزاء المتقنة', '18 جزءاً 📖'),
                    _buildTopStat('نسبة الإتقان', '98.5% ⭐'),
                    _buildTopStat('الحلقات المنجزة', '42 حلقة 🎙️'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // السور المكتملة
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('آخر السور المتقنة والمجازة:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  _buildSurahRow('سورة البقرة', '286 آية', 'إتقان تام 100%'),
                  const Divider(),
                  _buildSurahRow('سورة آل عمران', '200 آية', 'إتقان تام 99%'),
                  const Divider(),
                  _buildSurahRow('سورة مريم', '98 آية', 'إتقان تام 100%'),
                  const Divider(),
                  _buildSurahRow('جزء عمّ (كاملاً)', '37 سورة', 'مجاز بالإتقان'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // زر الانتقال للشهادات
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00875A),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppreciationsScreen()),
              );
            },
            icon: const Icon(Icons.workspace_premium_rounded, color: Colors.white),
            label: const Text(
              'عرض شهادات الشكر والتقدير المعتمدة 🏆',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStat(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildSurahRow(String name, String ayahs, String grade) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF00875A), size: 18),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 6),
              Text('($ayahs)', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(grade, style: const TextStyle(fontSize: 11, color: Color(0xFF00875A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _homeworkList.length,
      itemBuilder: (ctx, idx) {
        final h = _homeworkList[idx];
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
                    Text(
                      h['surah'],
                      style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00875A)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: h['is_done'] ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        h['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: h['is_done'] ? const Color(0xFF00875A) : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('فضيلة المشرف: ${h['sheikh']}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 4),
                Text('موعد التسميع: ${h['due']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}
