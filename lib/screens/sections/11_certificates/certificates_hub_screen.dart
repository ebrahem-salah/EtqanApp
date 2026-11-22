import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CertificatesHubScreen extends StatefulWidget {
  const CertificatesHubScreen({super.key});

  @override
  State<CertificatesHubScreen> createState() => _CertificatesHubScreenState();
}

class _CertificatesHubScreenState extends State<CertificatesHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = ['الكل', 'إجازات القرآن', 'شهادات السنة', 'القاعدة النورانية', 'الدورات'];

  final List<Map<String, dynamic>> _certificates = [
    {
      'id': 'cert_1',
      'title': 'إجازة في القرآن الكريم بالسند المتصل إلى رسول الله ﷺ',
      'studentName': 'إبراهيم صلاح',
      'type': 'إجازات القرآن',
      'riwayah': 'برواية حفص عن عاصم من طريق الشاطبية',
      'sheikh': 'فضيلة الشيخ المقرئ د. أحمد عبد المنعم',
      'date': '2025-11-10',
      'certNumber': 'ETQ-QR-2025-0841',
      'badge': 'إجازة مسندة',
      'color': const Color(0xFFD4AF37),
    },
    {
      'id': 'cert_2',
      'title': 'شهادة اجتياز دورة إتقان مخارج وصفات الحروف',
      'studentName': 'إبراهيم صلاح',
      'type': 'الدورات',
      'riwayah': 'الدورة التأصيلية المعتمدة',
      'sheikh': 'هيئة كبار المقرئين بتطبيق إتقان',
      'date': '2025-09-15',
      'certNumber': 'ETQ-CRS-2025-0329',
      'badge': 'شهادة دورة',
      'color': const Color(0xFF00875A),
    },
    {
      'id': 'cert_3',
      'title': 'إجازة في متن الأربعين النووية وسماعها بالسند المتصل',
      'studentName': 'إبراهيم صلاح',
      'type': 'شهادات السنة',
      'riwayah': 'عن الإمام يحيى بن شرف النووي بالسند المتصل',
      'sheikh': 'العلامة المحدث د. عبد الكريم الخضير',
      'date': '2025-07-20',
      'certNumber': 'ETQ-SN-2025-0158',
      'badge': 'إجازة حديثية',
      'color': const Color(0xFF1E88E5),
    },
    {
      'id': 'cert_4',
      'title': 'شهادة إتمام المستويات الثلاثة للقاعدة النورانية',
      'studentName': 'إبراهيم صلاح',
      'type': 'القاعدة النورانية',
      'riwayah': 'بتقدير ممتاز مع مرتبة الشرف',
      'sheikh': 'المركز العالمي للفرقان لتعليم القرآن',
      'date': '2025-05-04',
      'certNumber': 'ETQ-NR-2025-0072',
      'badge': 'شهادة نورانية',
      'color': const Color(0xFF8E24AA),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCertificateViewer(BuildContext context, Map<String, dynamic> cert) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF00875A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(cert['certNumber'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                  ],
                ),
                const SizedBox(height: 10),

                // Certificate Frame
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDE7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.military_tech_rounded, size: 50, color: Color(0xFFD4AF37)),
                      const SizedBox(height: 8),
                      const Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', style: TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('شهادة إجازة علمية معتمدة', style: TextStyle(fontFamily: 'Dubai', fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                      const Divider(color: Color(0xFFD4AF37), thickness: 1, indent: 40, endIndent: 40),
                      const SizedBox(height: 8),
                      const Text('تشهد إدارة منصة إتقان العالمية بأن الدارس المبارك:', style: TextStyle(fontFamily: 'Dubai', fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(cert['studentName'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
                      const SizedBox(height: 6),
                      const Text('قد أتم بنجاح متطلبات نيل:', style: TextStyle(fontFamily: 'Dubai', fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(cert['title'], textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Dubai', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB78103))),
                      const SizedBox(height: 6),
                      Text(cert['riwayah'], style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('المجيز / المشرف:', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey)),
                              Text(cert['sheikh'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('تاريخ الإصدار:', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey)),
                              Text(cert['date'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_2_rounded, size: 24, color: Color(0xFF00875A)),
                            SizedBox(width: 8),
                            Text('وثيقة رقمية معتمدة ومؤمنة بالـ QR', style: TextStyle(fontFamily: 'Dubai', fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Download & Share
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00875A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم حفظ الشهادة بصيغة PDF عالية الدقة بجهازك.'), backgroundColor: Color(0xFF00875A)),
                          );
                        },
                        icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                        label: const Text('تحميل PDF', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00875A),
                          side: const BorderSide(color: Color(0xFF00875A)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ رابط التحقق من الشهادة لمشاركته.'), backgroundColor: Color(0xFF00875A)),
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text('مشاركة', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
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
          'الشهادات والإجازات العلمية',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((cat) {
          final list = _certificates.where((c) {
            if (cat == 'الكل') return true;
            return c['type'] == cat;
          }).toList();

          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.military_tech_outlined, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text('لا توجد شهادات في قسم $cat حتى الآن', style: const TextStyle(fontFamily: 'Dubai', color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, idx) {
              final cert = list[idx];
              final Color badgeColor = cert['color'] as Color;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
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
                          decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                          child: Text(cert['badge'], style: TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor)),
                        ),
                        Text(cert['date'], style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(cert['title'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(cert['riwayah'], style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700)),
                    const SizedBox(height: 4),
                    Text('المجيز: ${cert['sheikh']}', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00875A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showCertificateViewer(context, cert),
                        icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 16),
                        label: const Text('عرض الإجازة وتحميل الوثيقة الرسمية', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
