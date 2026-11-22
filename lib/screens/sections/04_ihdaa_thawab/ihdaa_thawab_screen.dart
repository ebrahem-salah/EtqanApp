import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../call/live_recitation_room.dart';
import '../dialogs/create_section_session_dialog.dart';

class IhdaaThawabScreen extends StatefulWidget {
  const IhdaaThawabScreen({super.key});

  @override
  State<IhdaaThawabScreen> createState() => _IhdaaThawabScreenState();
}

class _IhdaaThawabScreenState extends State<IhdaaThawabScreen> {
  final List<Map<String, dynamic>> _khatmahs = [
    {
      'id': 'ihdaa_1',
      'dedicatedTo': 'المرحوم الوالد الحاج محمد عبد الله',
      'beneficiaryType': 'متوفى',
      'initiator': 'ابنه المهندس إبراهيم',
      'completedJuz': 24,
      'totalJuz': 30,
      'isLiveNow': true,
      'liveRoomId': 'room_ihdaa_thawab_404',
      'activeSheikh': 'القارئ الشيخ عبد الله المصلح',
      'viewers': 78,
    },
    {
      'id': 'ihdaa_2',
      'dedicatedTo': 'شفاء الوالدة أم أحمد ومرضى المسلمين',
      'beneficiaryType': 'مريض',
      'initiator': 'عائلة آل أحمد',
      'completedJuz': 18,
      'totalJuz': 30,
      'isLiveNow': false,
      'activeSheikh': 'الشيخ عبد الرحمن السديس (مسجل)',
      'viewers': 0,
    },
    {
      'id': 'ihdaa_3',
      'dedicatedTo': 'شهداء فلسطين والأمة الإسلامية',
      'beneficiaryType': 'شهداء',
      'initiator': 'إدارة تطبيق إتقان',
      'completedJuz': 30,
      'totalJuz': 30,
      'isLiveNow': false,
      'activeSheikh': 'أتمها 45 قارئاً',
      'viewers': 0,
    },
  ];

  void _showNewKhatmahDialog(BuildContext context) {
    final titleController = TextEditingController();
    final personController = TextEditingController();
    String reason = 'متوفى';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: Color(0xFF00875A)),
                      SizedBox(width: 8),
                      Text(
                        'تسجيل ختمة إهداء ثواب',
                        style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Text('المهدى إليه:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: personController,
                    decoration: InputDecoration(
                      hintText: 'اسم المتوفى أو المريض أو الوالدين',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('الغرض:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: ['متوفى', 'مريض للشفاء', 'بر الوالدين', 'عام'].map((r) {
                      final isSelected = reason == r;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: ChoiceChip(
                          label: Text(r, style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
                          selected: isSelected,
                          selectedColor: const Color(0xFF00875A),
                          onSelected: (_) => setDialogState(() => reason = r),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00875A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (personController.text.trim().isEmpty) return;
                        setState(() {
                          _khatmahs.insert(0, {
                            'id': 'ihdaa_${DateTime.now().millisecondsSinceEpoch}',
                            'dedicatedTo': personController.text.trim(),
                            'beneficiaryType': reason,
                            'initiator': 'أنت',
                            'completedJuz': 0,
                            'totalJuz': 30,
                            'isLiveNow': false,
                            'activeSheikh': 'قيد التلاوة والمشاركة',
                            'viewers': 0,
                          });
                        });
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إنشاء الختمة بنجاح وإتاحتها لعموم القراء في المنصة'),
                            backgroundColor: Color(0xFF00875A),
                          ),
                        );
                      },
                      child: const Text('تأكيد إنشاء الختمة', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
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
          'مقرأة إهداء الثواب',
          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00875A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_rounded),
            tooltip: 'بث مباشر لإهداء الثواب في الريلز',
            onPressed: () {
              CreateSectionSessionDialog.show(
                context,
                initialSection: 'مقرأة إهداء الثواب',
                initialSubSection: 'ختمة إهداء ثواب لمتوفى',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Spiritual Quote Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00875A), Color(0xFF005E3C)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00875A).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      '«إذا مات ابن آدم انقطع عمله إلا من ثلاث...»',
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'قسم مخصص للمقارئ الجماعية وختمات القرآن الكريم الكاملة وإهداء ثواب التلاوة للمتوفين والمرضى والوالدين، مع البث المباشر والدعاء المستجاب عند كل ختمة.',
                  style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showNewKhatmahDialog(context),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                  label: const Text(
                    'تسجيل ختمة جديدة',
                    style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00875A),
                    side: const BorderSide(color: Color(0xFF00875A)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    CreateSectionSessionDialog.show(
                      context,
                      initialSection: 'مقرأة إهداء الثواب',
                      initialSubSection: 'مقرأة عامة لإهداء الثواب',
                    );
                  },
                  icon: const Icon(Icons.sensors_rounded, color: Color(0xFF00875A), size: 20),
                  label: const Text(
                    'بث مباشر بالمقرأة',
                    style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section Title
          const Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: Color(0xFF00875A), size: 20),
              SizedBox(width: 8),
              Text(
                'الختمات والمقارئ الجارية الآن',
                style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Khatmahs List
          ..._khatmahs.map((khatmah) {
            final double progress = khatmah['completedJuz'] / khatmah['totalJuz'];
            final bool isLive = khatmah['isLiveNow'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isLive ? Border.all(color: const Color(0xFFE53935).withOpacity(0.5), width: 1.5) : null,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
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
                            color: const Color(0xFF00875A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ثواب ${khatmah['beneficiaryType']}',
                            style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
                          ),
                        ),
                        if (isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, color: Colors.white, size: 7),
                                const SizedBox(width: 4),
                                Text(
                                  'مقرأة حية (${khatmah['viewers']})',
                                  style: const TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      khatmah['dedicatedTo'],
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'أنشأها: ${khatmah['initiator']} • القارئ: ${khatmah['activeSheikh']}',
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),

                    // Progress bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'اكتمل ${khatmah['completedJuz']} من 30 جزء',
                          style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(fontFamily: 'Dubai', fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00875A)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLive ? const Color(0xFFE53935) : const Color(0xFF00875A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LiveRecitationRoom(
                                roomId: khatmah['id'],
                                circleTitle: 'مقرأة إهداء الثواب: ${khatmah['dedicatedTo']}',
                                isSheikh: false,
                              ),
                            ),
                          );
                        },
                        icon: Icon(isLive ? Icons.play_arrow_rounded : Icons.bookmark_add_outlined, color: Colors.white),
                        label: Text(
                          isLive ? 'الانضمام للبث المباشر والمشاركة في التلاوة' : 'حجز جزء والتلاوة الآن',
                          style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
