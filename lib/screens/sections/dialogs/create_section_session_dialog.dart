import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/live_streams_service.dart';
import '../../../providers/auth_provider.dart';
import '../../call/live_recitation_room.dart';

class CreateSectionSessionDialog extends StatefulWidget {
  final String? initialSection;
  final String? initialSubSection;

  const CreateSectionSessionDialog({
    super.key,
    this.initialSection,
    this.initialSubSection,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialSection,
    String? initialSubSection,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CreateSectionSessionDialog(
        initialSection: initialSection,
        initialSubSection: initialSubSection,
      ),
    );
  }

  @override
  State<CreateSectionSessionDialog> createState() => _CreateSectionSessionDialogState();
}

class _CreateSectionSessionDialogState extends State<CreateSectionSessionDialog> {
  late String _selectedSection;
  late String _selectedSubSection;
  final TextEditingController _customTitleController = TextEditingController();
  
  // Naming choice: true = Named after creator, false = Custom name
  bool _useCreatorName = false;
  bool _startLiveStreamImmediately = true; // Automatically broadcasts to Reels
  bool _isFree = true;
  int _maxMembers = 25;

  final Map<String, List<String>> _sectionsWithSub = {
    'القرآن الكريم': [
      'المقرأة',
      'المدارسة',
      'الحفظ (الصغار)',
      'الحفظ (الكبار)',
      'المراجعة (ثلاثون جزء)',
      'المراجعة (فمي بشوق)',
      'التجويد',
      'علوم القرآن',
      'القراءات العشر',
      'المقامات الصوتية',
      'التفسير',
      'القراءة بالإسناد',
    ],
    'مقرأة إهداء الثواب': [
      'ختمة إهداء ثواب لمتوفى',
      'ختمة إهداء ثواب لمريض',
      'ختمة إهداء ثواب للوالدين',
      'مقرأة عامة لإهداء الثواب',
    ],
    'السنة النبوية': [
      'الحفظ (الصغار)',
      'الحفظ (الكبار)',
      'علوم الحديث',
      'شروح الأحاديث',
      'الإقراء لكتب السنة',
      'القراءة بالإسناد',
    ],
    'الفتاوى': [
      'فتاوى مباشرة',
      'فتاوى دار الإفتاء الإلكترونية',
      'فتاوى مؤرشفة',
    ],
    'الرقية الشرعية': [
      'رقية مباشرة',
      'الراقي د. محمد كمال بو حسين',
      'الراقي د. أحمد عبد المنعم',
      'جلسة رقية خاصة',
    ],
    'تعليم الحروف والقاعدة النورانية': [
      'المستوى الأول (الحروف المفردة)',
      'المستوى الثاني (المركبة والمدود)',
      'المستوى الثالث (أحكام التجويد)',
    ],
    'الدورات العلمية': [
      'الدورات العلمية العامة',
      'الدورات العلمية الخاصة',
    ],
    'علوم أخرى': [
      'الفقه',
      'السيرة النبوية',
      'العقيدة',
      'الرقائق',
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedSection = widget.initialSection ?? 'القرآن الكريم';
    if (!_sectionsWithSub.containsKey(_selectedSection)) {
      _selectedSection = 'القرآن الكريم';
    }
    final subs = _sectionsWithSub[_selectedSection]!;
    _selectedSubSection = (widget.initialSubSection != null && subs.contains(widget.initialSubSection))
        ? widget.initialSubSection!
        : subs.first;
  }

  @override
  void dispose() {
    _customTitleController.dispose();
    super.dispose();
  }

  String _getFinalTitle(String creatorName) {
    if (_useCreatorName) {
      return '$_selectedSubSection - فضيلة $creatorName';
    } else {
      if (_customTitleController.text.trim().isNotEmpty) {
        return _customTitleController.text.trim();
      }
      return '$_selectedSection: $_selectedSubSection';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final creatorName = (user != null && user.name.isNotEmpty) ? user.name : 'الشيخ المقرئ';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00875A).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.video_call_rounded, color: Color(0xFF00875A), size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'إنشاء حلقة / جلسة بث',
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191919),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Section Selector
              const Text('القسم الرئيسي', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedSection,
                    items: _sectionsWithSub.keys.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontFamily: 'Dubai', fontSize: 14)))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedSection = val;
                          _selectedSubSection = _sectionsWithSub[val]!.first;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Sub-section Selector
              const Text('التصنيف والفرع', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedSubSection,
                    items: _sectionsWithSub[_selectedSection]!.map((sub) => DropdownMenuItem(value: sub, child: Text(sub, style: const TextStyle(fontFamily: 'Dubai', fontSize: 14)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSubSection = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Naming Option (الملاحظة الهامة من المستخدم)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF00875A).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: Color(0xFF00875A), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'تسمية الحلقة أو الجلسة:',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF00875A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _useCreatorName = true),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              decoration: BoxDecoration(
                                color: _useCreatorName ? const Color(0xFF00875A) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _useCreatorName ? const Color(0xFF00875A) : Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Text(
                                  'تسمية باسمي ($creatorName)',
                                  style: TextStyle(
                                    fontFamily: 'Dubai',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _useCreatorName ? Colors.white : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _useCreatorName = false),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              decoration: BoxDecoration(
                                color: !_useCreatorName ? const Color(0xFF00875A) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: !_useCreatorName ? const Color(0xFF00875A) : Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Text(
                                  'اسم مخصص للحلقة',
                                  style: TextStyle(
                                    fontFamily: 'Dubai',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: !_useCreatorName ? Colors.white : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_useCreatorName) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _customTitleController,
                        decoration: InputDecoration(
                          hintText: 'اكتب اسم الحلقة (مثال: مقرأة تدبر وتصحيح جزء عم / إهداء الثواب لوالدي)',
                          hintStyle: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade500),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Live Broadcast To Reels Option (الشرط الثاني للمستخدم)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE53935).withOpacity(0.08),
                      const Color(0xFFFF8A80).withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _startLiveStreamImmediately,
                  onChanged: (val) => setState(() => _startLiveStreamImmediately = val),
                  activeColor: const Color(0xFFE53935),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 8),
                            SizedBox(width: 4),
                            Text(
                              'بث مباشر',
                              style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'إظهار البث في مقاطع الريلز فوراً',
                          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'سيظهر البث المباشر لجميع مستخدمي التطبيق في شريط الريلز ليتمكنوا من الانضمام بضغطة واحدة.',
                    style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Max students count & Free/Paid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الحد الأقصى للطلاب:', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF00875A)),
                        onPressed: () {
                          if (_maxMembers > 2) setState(() => _maxMembers -= 2);
                        },
                      ),
                      Text('$_maxMembers مشارك', style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00875A)),
                        onPressed: () {
                          if (_maxMembers < 100) setState(() => _maxMembers += 5);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Submit & Launch Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final finalTitle = _getFinalTitle(creatorName);
                    final roomId = 'room_${DateTime.now().millisecondsSinceEpoch}';

                    // If live broadcast is enabled, add it to LiveStreamsService so it appears in Reels!
                    if (_startLiveStreamImmediately) {
                      LiveStreamsService.instance.addLiveStream(
                        LiveStreamItem(
                          id: roomId,
                          title: finalTitle,
                          sheikhName: creatorName,
                          sheikhAvatar: 'assets/images/profile.png',
                          sectionName: _selectedSection,
                          subSectionName: _selectedSubSection,
                          viewerCount: 1,
                          roomId: roomId,
                          isVideo: true,
                          startedAt: DateTime.now(),
                        ),
                      );
                    }

                    Navigator.of(context).pop();

                    // Open Live Recitation Room
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LiveRecitationRoom(
                          roomId: roomId,
                          circleTitle: finalTitle,
                          isSheikh: true,
                        ),
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _startLiveStreamImmediately
                              ? 'تم إنشاء الحلقة وبدء البث المباشر بنجاح! يظهر الآن في الريلز.'
                              : 'تم جدولة الحلقة بنجاح!',
                          style: const TextStyle(fontFamily: 'Dubai'),
                        ),
                        backgroundColor: const Color(0xFF00875A),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white),
                  label: Text(
                    _startLiveStreamImmediately ? 'بدء البث المباشر ونشره في الريلز' : 'إنشاء وحفظ الحلقة',
                    style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
