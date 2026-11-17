import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

class CompetitionsScreen extends StatelessWidget {
  const CompetitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2822)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'المسابقات القرآنية السنوية',
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
                  colors: [Color(0xFF15291D), Color(0xFF09160E)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // الشارة الذهبية الرسمية
                  Image.asset(
                    AppAssets.badgGold,
                    height: 85,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'مسابقة فرسان إتقان 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      color: Color(0xFFD4AF37),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'برعاية منظومة إتقان العالمية لتعليم وتحفيظ القرآن الكريم',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // الجائزة الكبرى
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🏆', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text(
                          'مجموع الجوائز: 100,000 ريال سعودي',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // فروع المسابقة المتاحة
            const Text(
              'فروع المسابقة المتاحة للاشتراك:',
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2822),
              ),
            ),
            const SizedBox(height: 12),

            _buildBranchCard(
              title: 'الفرع الأول: القرآن الكريم كاملاً',
              subtitle: 'مع التجويد وضبط المتشابهات وتفسير المفردات',
              prize: 'المركز الأول: 40,000 ريال',
              icon: '🌟',
              color: const Color(0xFF00875A),
            ),
            const SizedBox(height: 12),

            _buildBranchCard(
              title: 'الفرع الثاني: خمسة عشر جزءاً',
              subtitle: 'من سورة الكهف إلى سورة الناس مع حسن الصوت',
              prize: 'المركز الأول: 25,000 ريال',
              icon: '⭐',
              color: const Color(0xFF191919),
            ),
            const SizedBox(height: 12),

            _buildBranchCard(
              title: 'الفرع الثالث: صغار الحفاظ (تحت 12 سنة)',
              subtitle: 'حفظ جزء عم وتبارك مع أحكام النون والتنوين',
              prize: 'المركز الأول: 15,000 ريال + درع التميز',
              icon: '👦',
              color: const Color(0xFF00875A),
            ),
            const SizedBox(height: 24),

            // لوحة الشرف والمتصدرين
            const Text(
              'لوحة الشرف والمتصدرين الحاليين:',
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2822),
              ),
            ),
            const SizedBox(height: 10),

            _buildLeaderboardItem(1, 'عبد الرحمن أحمد العتيبي', '100% (بدون أي خطأ)', '🥇'),
            _buildLeaderboardItem(2, 'محمد إبراهيم الدوسري', '99.5% (تجويد ممتاز)', '🥈'),
            _buildLeaderboardItem(3, 'عمر خالد المنصور', '99.0% (صوت ندي)', '🥉'),

            const SizedBox(height: 28),

            // زر التسجيل بالمسابقة
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00875A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 تم تسجيل طلب اشتراكك في المسابقة بنجاح! سيتم إخطارك بموعد اختبارك.'),
                      backgroundColor: Color(0xFF00875A),
                    ),
                  );
                },
                child: const Text(
                  'سجّل في المسابقة الآن مجاناً',
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

  Widget _buildBranchCard({
    required String title,
    required String subtitle,
    required String prize,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E2822)),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                const SizedBox(height: 6),
                Text(
                  prize,
                  style: const TextStyle(color: Color(0xFF00875A), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, String name, String score, String medal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(score, style: const TextStyle(color: Color(0xFF00875A), fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
            child: Text('المركز $rank', style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
