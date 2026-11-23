import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../call/live_recitation_room.dart';
import '../dialogs/create_section_session_dialog.dart';

class FatwasHubScreen extends StatefulWidget {
  final String? initialCategory;
  const FatwasHubScreen({super.key, this.initialCategory});

  @override
  State<FatwasHubScreen> createState() => _FatwasHubScreenState();
}

class _FatwasHubScreenState extends State<FatwasHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _tabs = [
    'فتاوى دار الإفتاء الإلكترونية',
    'فتاوى مباشرة (بث حي)',
    'فتاوى مؤرشفة',
  ];

  final List<Map<String, dynamic>> _darAlIftaFatwas = [
    {
      'id': 'f_dar_1',
      'question': 'ما حكم التداول بالعملات الرقمية المشفرة مثل البيتكوين؟',
      'category': 'المعاملات المالية',
      'source': 'دار الإفتاء المصرية / هيئة كبار العلماء',
      'summary': 'الحكم يدور مع علته في مدى تحقق الغرر والجهالة والاعتماد الرسمي للدولة، والأصل التحرز حتى تنضبط تشريعياً ورسمياً لحماية أموال الناس.',
      'date': '2025-10-14',
    },
    {
      'id': 'f_dar_2',
      'question': 'هل تجزئ زكاة الفطر نقداً أم يشترط إخراجها طعاماً؟',
      'category': 'العبادات والزكاة',
      'source': 'مجمع الفقه الإسلامي الدولي',
      'summary': 'يجوز إخراجها نقداً إذا كان ذلك أنفع للفقير وأيسر عليه لقضاء حوائجه في العيد، وهو مذهب عمر بن عبد العزيز والإمام أبي حنيفة وجماعة من السلف.',
      'date': '2025-04-02',
    },
    {
      'id': 'f_dar_3',
      'question': 'حكم الجمع والقصر للمسافر بالطائرة ومسافة السفر المعتبرة',
      'category': 'الصلاة والطهارة',
      'source': 'اللجنة الدائمة للبحوث العلمية والإفتاء',
      'summary': 'يبدأ الترخص بالقصر والجمع بعد مغادرة بنيان بلد الإقامة وتجاوز المطار، إذا كانت المسافة تزيد عن 80 كيلومتراً.',
      'date': '2025-08-19',
    },
  ];

  final List<Map<String, dynamic>> _liveFatwaSessions = [
    {
      'id': 'f_live_1',
      'title': 'مجلس الفتاوى المباشرة: أحكام المعاملات التجارية والديون',
      'scholar': 'فضيلة الشيخ د. سعد الشثري',
      'sub': 'فتاوى مباشرة',
      'viewers': 95,
      'isLive': true,
      'answeredCount': '14 فتوى تمت الإجابة عنها',
    },
    {
      'id': 'f_live_2',
      'title': 'فتاوى الأسرة وتربية الأبناء والعلاقات الزوجية',
      'scholar': 'فضيلة الشيخ د. محمد العريفي',
      'sub': 'فتاوى مباشرة',
      'viewers': 340,
      'isLive': true,
      'answeredCount': '28 فتوى مباشرة',
    },
  ];

  final List<Map<String, dynamic>> _archivedFatwas = [
    {
      'id': 'f_arch_1',
      'question': 'ما حكم قراءة القرآن من شاشة الهاتف المحمول بغير وضوء؟',
      'scholar': 'فضيلة الشيخ ابن عثيمين رحمه الله',
      'answer': 'يجوز مس شاشة الجوال وقراءة القرآن منها بغير وضوء؛ لأن الجوال ليس مصحفاً حقيقياً وإنما هي موجات وذبذبات تظهر وتختفي، ولكن الأفضل للمسلم أن يتوضأ لقراءة كلام الله.',
      'topic': 'القرآن والتلاوة',
    },
    {
      'id': 'f_arch_2',
      'question': 'حكم أخذ الأجرة على تعليم القرآن الكريم وتحفيظه',
      'scholar': 'جمهور الفقهاء وهيئة الإفتاء',
      'answer': 'يجوز أخذ الأجرة والمكافأة على تعليم القرآن تفرغاً، لقول النبي ﷺ في الحديث الصحيح: «إن أحق ما أخذتم عليه أجراً كتاب الله».',
      'topic': 'التعليم والقرآن',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAskQuestionDialog(BuildContext context) {
    final qController = TextEditingController();
    bool isAudioSelected = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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
                      child: const Icon(Icons.help_outline_rounded, color: Color(0xFF00875A), size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Text('اطرح سؤالك على المفتي', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                const Divider(height: 22),
                const Text('طريقة طرح الاستفتاء:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note_rounded, size: 16),
                            SizedBox(width: 4),
                            Text('سؤال مكتوب', style: TextStyle(fontFamily: 'Dubai', fontSize: 12)),
                          ],
                        ),
                        selected: !isAudioSelected,
                        selectedColor: const Color(0xFF00875A).withOpacity(0.15),
                        onSelected: (val) => setDialogState(() => isAudioSelected = false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mic_rounded, size: 16),
                            SizedBox(width: 4),
                            Text('تسجيل صوتي', style: TextStyle(fontFamily: 'Dubai', fontSize: 12)),
                          ],
                        ),
                        selected: isAudioSelected,
                        selectedColor: const Color(0xFF00875A).withOpacity(0.15),
                        onSelected: (val) => setDialogState(() => isAudioSelected = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!isAudioSelected)
                  TextField(
                    controller: qController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'اكتب سؤالك الشرعي بدقة مع ذكر التفاصيل المهمة...',
                      hintStyle: const TextStyle(fontFamily: 'Dubai', fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFF00875A).withOpacity(0.1),
                          child: const Icon(Icons.mic_rounded, color: Color(0xFF00875A), size: 30),
                        ),
                        const SizedBox(height: 10),
                        const Text('اضغط للتسجيل الصوتي لسؤالك (حد أقصى دقيقتين)', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
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
                          '🔔 سيصلك تنبيه إشعار تلقائي فور قيام المفتي بالإجابة المعتمدة على سؤالك.',
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
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 تم إرسال سؤالك لهيئة الإفتاء بنجاح! سيصلك إشعار فوري فور ورود الإجابة.'),
                          backgroundColor: Color(0xFF00875A),
                          duration: Duration(seconds: 4),
                        ),
                      );
                    },
                    child: const Text('إرسال السؤال لهيئة الإفتاء', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
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
          'الفتاوى الشرعية',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: 'طرح سؤال جديد',
            onPressed: () => _showAskQuestionDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.video_call_rounded),
            tooltip: 'بدء بث فتاوى مباشر في الريلز',
            onPressed: () {
              CreateSectionSessionDialog.show(
                context,
                initialSection: 'الفتاوى',
                initialSubSection: 'فتاوى مباشرة',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. فتاوى دار الإفتاء الإلكترونية
          _buildDarAlIftaView(),
          // 2. فتاوى مباشرة (بث حي)
          _buildLiveFatwaView(),
          // 3. فتاوى مؤرشفة
          _buildArchivedView(),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'ask_fatwa_fab',
            backgroundColor: const Color(0xFF00875A),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.help_outline_rounded, size: 20),
            label: const Text('اطرح سؤالك على المفتي', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: () => _showAskQuestionDialog(context),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            heroTag: 'live_fatwa_fab',
            backgroundColor: const Color(0xFF0F5B46),
            foregroundColor: Colors.white,
            tooltip: 'بث مجلس فتاوى مباشر',
            child: const Icon(Icons.live_tv_rounded, size: 18),
            onPressed: () {
              CreateSectionSessionDialog.show(
                context,
                initialSection: 'الفتاوى',
                initialSubSection: 'فتاوى مباشرة',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDarAlIftaView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _darAlIftaFatwas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final f = _darAlIftaFatwas[idx];
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
                    decoration: BoxDecoration(color: const Color(0xFF00875A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(f['category'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
                  ),
                  Text(f['date'], style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
              const SizedBox(height: 8),
              Text(f['question'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('المصدر المعتمد: ${f['source']}', style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(f['summary'], style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade800, height: 1.4)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveFatwaView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _liveFatwaSessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = _liveFatwaSessions[idx];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE53935).withOpacity(0.4), width: 1.5),
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
                    decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xFFE53935), size: 7),
                        SizedBox(width: 4),
                        Text('بث مباشر للأسئلة والأجوبة', style: TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                      ],
                    ),
                  ),
                  Text('👁️ ${item['viewers']} مستمع', style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Text(item['title'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('المفتي: ${item['scholar']} • ${item['answeredCount']}', style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LiveRecitationRoom(
                          roomId: item['id'],
                          circleTitle: item['title'],
                          isSheikh: false,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.mic, color: Colors.white, size: 18),
                  label: const Text('طرح سؤال صوتي / الانضمام للبث المباشر', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArchivedView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _archivedFatwas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final af = _archivedFatwas[idx];
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF00875A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(af['topic'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A))),
              ),
              const SizedBox(height: 8),
              Text(af['question'], style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('أجاب عليه: ${af['scholar']}', style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(af['answer'], style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade800, height: 1.4)),
            ],
          ),
        );
      },
    );
  }
}
