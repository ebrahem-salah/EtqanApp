import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();

  List<dynamic> _faqs = [];
  bool _isLoadingFaqs = false;

  final _ticketSubjectCtrl = TextEditingController();
  final _ticketMessageCtrl = TextEditingController();
  bool _isSubmittingTicket = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFaqs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ticketSubjectCtrl.dispose();
    _ticketMessageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFaqs() async {
    setState(() => _isLoadingFaqs = true);
    try {
      final res = await _apiClient.getFaqs();
      if (res.statusCode == 200 && res.data != null) {
        setState(() {
          _faqs = res.data['data'] ?? [];
        });
      }
    } catch (_) {
      _faqs = [
        {
          'question': 'كيف يمكنني الانضمام لحلقة تسميع مباشرة؟',
          'answer': 'من تبويب الحلقات بالأسفل، اختر الحلقة المناسبة لك ثم اضغط "انضمام الآن" لتفتح لك غرفة التسميع المباشرة بالصوت والصورة.',
        },
        {
          'question': 'كيف أطلب التسميع أمام الشيخ أثناء الدرس؟',
          'answer': 'اضغط على زر (رفع اليد ✋) في شاشة الدرس المباشر، وسيصل تنبيه فوري لفضيلة الشيخ ليأذن لك ويفتح المايكروفون للتسميع.',
        },
        {
          'question': 'هل جلسات التسميع والتحفيظ مسجلة؟',
          'answer': 'افتراضياً تكون الجلسات خاصة وغير مسجلة حفاظاً على خصوصية الطلاب، وإذا رغب الشيخ بتسجيل الدرس يظهر شريط تنبيه أحمر للجميع.',
        },
        {
          'question': 'كيف يتم احتساب درجات مسابقات إتقان؟',
          'answer': 'يتم تقييم كل سؤال من 10 درجات، ويتم خصم درجات للأخطاء التجويدية والتلعثم بحسب لائحة التحكيم، وتحدث لوحة الأوائل تلقائياً.',
        },
      ];
    } finally {
      if (mounted) setState(() => _isLoadingFaqs = false);
    }
  }

  Future<void> _submitTicket() async {
    if (_ticketSubjectCtrl.text.isEmpty || _ticketMessageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء عنوان الرسالة وتفاصيلها')),
      );
      return;
    }

    setState(() => _isSubmittingTicket = true);
    await Future.delayed(const Duration(seconds: 1)); // simulated api call
    if (mounted) {
      setState(() {
        _isSubmittingTicket = false;
        _ticketSubjectCtrl.clear();
        _ticketMessageCtrl.clear();
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.mark_email_read_rounded, color: Color(0xFF00875A)),
              SizedBox(width: 8),
              Text('تم استلام تذكرتك 📨', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'شكراً لتواصلك مع الدعم الفني لإتقان. سيقوم أحد مسؤولي الدعم بالرد على استفسارك خلال 24 ساعة.',
            style: TextStyle(fontFamily: 'Dubai'),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00875A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('حسناً', style: TextStyle(color: Colors.white, fontFamily: 'Dubai')),
            ),
          ],
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
          'الدعم الفني والمساعدة 💡',
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
            Tab(text: 'تواصل معنا ✉️'),
            Tab(text: 'الأسئلة الشائعة ❓'),
            Tab(text: 'الشروط والأحكام 📜'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. تواصل معنا
          _buildContactTab(),

          // 2. الأسئلة الشائعة
          _buildFaqsTab(),

          // 3. الشروط والأحكام
          _buildTermsTab(),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('فريق الدعم الفني في خدمتكم دائماً', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('أرسل استفسارك أو مشكلتك التقنية وسيقوم الفريق بحلها بأسرع وقت.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),

                const Text('عنوان الاستفسار أو المشكلة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _ticketSubjectCtrl,
                  decoration: InputDecoration(
                    hintText: 'مثال: مشكلة في الصوت أثناء المكالمة',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),

                const Text('تفاصيل الرسالة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _ticketMessageCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'اشرح المشكلة بالتفصيل لنتمكن من مساعدتك...',
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00875A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isSubmittingTicket ? null : _submitTicket,
                    child: _isSubmittingTicket
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'إرسال التذكرة للدعم الفني 🚀',
                            style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Direct contacts
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const [
                Icon(Icons.headset_mic_rounded, color: Color(0xFF00875A), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('البريد الإلكتروني المباشر:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('support@etqan.site', style: TextStyle(fontSize: 12, color: Color(0xFF00875A), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqsTab() {
    if (_isLoadingFaqs) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _faqs.length,
      itemBuilder: (ctx, idx) {
        final f = _faqs[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            shape: const Border(),
            title: Text(
              f['question'] ?? '',
              style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  f['answer'] ?? '',
                  style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade700, height: 1.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTermsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'شروط الاستخدام وسياسة الخصوصية 📜',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00875A)),
            ),
            SizedBox(height: 12),
            Text(
              '1. احترام قدسية القرآن الكريم والسنة النبوية وآداب مجالس العلم.\n\n'
              '2. الخصوصية التامة: تلتزم منصة إتقان بعدم تسجيل أو نشر أي تلاوات خاصة إلا بموافقة صريحة من الطالب والشيخ.\n\n'
              '3. الحفاظ على المواعيد: يرجى الحضور في موعد الحلقة المحدد لضمان الاستفادة الكاملة لجميع الإخوة والأخوات.\n\n'
              '4. الرصيد والمحفظة: تضمن المنصة حماية كاملة للمدفوعات والشحن والتحويلات المالية الآمنة.',
              style: TextStyle(fontFamily: 'Dubai', fontSize: 13, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }
}
