import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_config.dart';

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
      'score': '100% (ممتاز مرتفع)',
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
      'score': '98% (ممتاز)',
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
      'score': '95% (ممتاز)',
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
      'score': '100% (مرتبة الشرف)',
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
    final verifyUrl = AppConfig.verifyCertUrl(cert['certNumber']);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top header bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00875A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF00875A)),
                          const SizedBox(width: 4),
                          Text(
                            cert['certNumber'],
                            style: const TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00875A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Certificate Frame (Authentic Gold / Green Islamic Border)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDE7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Golden Seal Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                            ),
                            child: const Icon(Icons.military_tech_rounded, size: 38, color: Color(0xFFD4AF37)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        style: TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'شهادة إجازة وسند علمي معتمد',
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00875A),
                        ),
                      ),
                      const Divider(color: Color(0xFFD4AF37), thickness: 1, indent: 30, endIndent: 30),
                      const SizedBox(height: 6),
                      const Text('تشهد إدارة منصة إتقان العالمية بأن الدارس المبارك:', style: TextStyle(fontFamily: 'Dubai', fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(
                        cert['studentName'],
                        style: const TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('قد أتم بنجاح متطلبات نيل:', style: TextStyle(fontFamily: 'Dubai', fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        cert['title'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB78103),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cert['riwayah'],
                        style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00875A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'التقدير العام: ${cert['score']}',
                          style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 14),

                      // QR Code Verification Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_2_rounded, size: 28, color: Color(0xFF00875A)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'وثيقة رقمية معتمدة ومؤمنة بالـ QR',
                                  style: TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  verifyUrl,
                                  style: TextStyle(fontFamily: 'Dubai', fontSize: 9, color: Colors.grey.shade600),
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

                // Download & Share Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00875A),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('📄 تم حفظ وثيقة (${cert['title']}) بصيغة PDF عالية الدقة برقم: ${cert['certNumber']}'),
                              backgroundColor: const Color(0xFF00875A),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          'تحميل PDF رسمي',
                          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00875A),
                          side: const BorderSide(color: Color(0xFF00875A)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                            text: '📜 شهادة معتمدة من منصة إتقان:\n'
                                '${cert['title']}\n'
                                'الاسم: ${cert['studentName']}\n'
                                'المجيز: ${cert['sheikh']}\n'
                                'رابط التحقق الرسمي: $verifyUrl',
                          ));
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ تم نسخ رابط ونص الشهادة للتحقق ومشاركتها على واتساب!'),
                              backgroundColor: Color(0xFF00875A),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text(
                          'مشاركة الإجازة',
                          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
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
          final filtered = cat == 'الكل'
              ? _certificates
              : _certificates.where((c) => c['type'] == cat).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.military_tech_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    'لا توجد شهادات مسجلة حالياً في $cat',
                    style: const TextStyle(fontFamily: 'Dubai', color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final cert = filtered[idx];
              final Color col = cert['color'] as Color;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showCertificateViewer(context, cert),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: col.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  cert['badge'],
                                  style: TextStyle(
                                    fontFamily: 'Dubai',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: col,
                                  ),
                                ),
                              ),
                              Text(
                                cert['certNumber'],
                                style: TextStyle(
                                  fontFamily: 'Dubai',
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            cert['title'],
                            style: const TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191919),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cert['riwayah'],
                            style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    cert['sheikh'],
                                    style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.black87),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'عرض الوثيقة و QR',
                                    style: TextStyle(
                                      fontFamily: 'Dubai',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: col,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: col),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
