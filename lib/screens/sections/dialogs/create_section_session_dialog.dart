import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/category_mapping.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/live_streams_service.dart';
import '../../../core/services/user_chapters_service.dart';
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
  String? _selectedSection;
  String? _selectedSubSection;
  final TextEditingController _customTitleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: '35');

  bool _useCreatorName = false;
  DateTime _startDateTime = DateTime.now();
  int _maxMembers = 25;
  bool _isPaid = false;
  bool _allowRecording = false;
  bool _isPrivate = false;
  bool _isSubmitting = false;

  final Map<String, List<String>> _sectionsWithSub = {
    'المكتبة الإلكترونية': [
      'قسم المصاحف',
      'كتب التفسير',
      'كتب الحديث',
      'أحكام التجويد',
      'علوم أخرى',
    ],
    'تعليم الحروف والقاعدة النورانية': [
      'المستوى الأول (الحروف المفردة)',
      'المستوى الثاني (المركبة والمدود)',
      'المستوى الثالث (أحكام التجويد)',
    ],
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
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialSection != null && _sectionsWithSub.containsKey(widget.initialSection)) {
      _selectedSection = widget.initialSection;
      final subs = _sectionsWithSub[_selectedSection]!;
      _selectedSubSection = (widget.initialSubSection != null && subs.contains(widget.initialSubSection))
          ? widget.initialSubSection
          : subs.first;
    }
  }

  @override
  void dispose() {
    _customTitleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _getFinalTitle(String creatorName) {
    final sec = _selectedSection ?? 'القرآن الكريم';
    final sub = _selectedSubSection ?? 'المقرأة';
    if (_useCreatorName) {
      return '$sub - فضيلة $creatorName';
    } else if (_customTitleController.text.trim().isNotEmpty) {
      return _customTitleController.text.trim();
    }
    return '$sec: $sub';
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      _startDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String _formatDateTime(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}/$m/$d  -  $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final creatorName = (user != null && user.name.isNotEmpty) ? user.name : 'الشيخ المقرئ';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        padding: const EdgeInsets.all(20),
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
                        child: const Icon(Icons.video_call_rounded, color: Color(0xFF00875A), size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'إنشاء حلقة / جلسة بث',
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 17,
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
              const Divider(height: 18),

              // 1. اسم الحلقة
              const Text(
                'اسم الحلقة',
                style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _useCreatorName = false),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                          color: !_useCreatorName ? const Color(0xFF00875A) : const Color(0xFFF8F9FA),
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
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _useCreatorName = true),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _useCreatorName ? const Color(0xFF00875A) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _useCreatorName ? const Color(0xFF00875A) : Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            'باسمي ($creatorName)',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _useCreatorName ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (!_useCreatorName) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _customTitleController,
                  decoration: InputDecoration(
                    hintText: 'اكتب اسم الحلقة (مثال: مقرأة تدبر وتصحيح التلاوة)',
                    hintStyle: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade500),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // 2. القسم الرئيسي
              const Text(
                'القسم الرئيسي',
                style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
              ),
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
                    hint: const Text(
                      'اختر القسم الرئيسي',
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.grey),
                    ),
                    items: _sectionsWithSub.keys
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, style: const TextStyle(fontFamily: 'Dubai', fontSize: 13)),
                            ))
                        .toList(),
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

              // 3. القسم الفرعي (يظهر فقط عند اختيار القسم الرئيسي)
              if (_selectedSection != null) ...[
                const SizedBox(height: 14),
                const Text(
                  'القسم الفرعي',
                  style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
                ),
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
                      items: _sectionsWithSub[_selectedSection]!
                          .map((sub) => DropdownMenuItem(
                                value: sub,
                                child: Text(sub, style: const TextStyle(fontFamily: 'Dubai', fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSubSection = val);
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // 4. تاريخ ووقت البدء
              const Text(
                'تاريخ ووقت البدء',
                style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateTime(_startDateTime),
                        style: const TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.calendar_month_rounded, color: Color(0xFF00875A), size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 5. عدد المشتركين
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'عدد المشتركين',
                      style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF00875A)),
                          onPressed: () {
                            if (_maxMembers > 2) setState(() => _maxMembers -= 2);
                          },
                        ),
                        Text(
                          '$_maxMembers مشارك',
                          style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
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
              ),
              const SizedBox(height: 14),

              // 6. نوع الحلقة (مجانية / مدفوعة)
              const Text(
                'نوع الحلقة',
                style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isPaid = false),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isPaid ? const Color(0xFF00875A) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: !_isPaid ? const Color(0xFF00875A) : Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            'مجانية',
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: !_isPaid ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isPaid = true),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isPaid ? const Color(0xFF00875A) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _isPaid ? const Color(0xFF00875A) : Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            'مدفوعة',
                            style: TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _isPaid ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isPaid) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'سعر الاشتراك (ج.م / ر.س)',
                    labelStyle: const TextStyle(fontFamily: 'Dubai', fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // 7. تسجيل الفيديو
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _allowRecording,
                  onChanged: (val) => setState(() => _allowRecording = val),
                  activeColor: const Color(0xFF00875A),
                  title: const Text(
                    'تسجيل الفيديو',
                    style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: const Text(
                    'حفظ تسجيل الحلقة وإتاحتها للمشتركين في الأرشيف',
                    style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 8. تحت خالص: حلقة خاصة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isPrivate,
                  onChanged: (val) => setState(() => _isPrivate = val),
                  activeColor: const Color(0xFF00875A),
                  title: const Text(
                    'حلقة خاصة',
                    style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: const Text(
                    'لا تظهر للعامة، الدخول عبر الدعوة فقط',
                    style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.black54),
                  ),
                ),
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
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (_selectedSection == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى اختيار القسم الرئيسي أولاً', style: TextStyle(fontFamily: 'Dubai')),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          setState(() => _isSubmitting = true);

                          final finalTitle = _getFinalTitle(creatorName);
                          final sectionName = _selectedSection!;
                          final subSectionName = _selectedSubSection ?? 'عام';
                          final priceDouble = _isPaid ? (double.tryParse(_priceController.text) ?? 35.0) : 0.0;

                          int? createdClassId;
                          String? serverError;
                          try {
                            final resolvedCategoryId = CategoryMapping.resolveCategoryId(
                              sectionName,
                              subSectionName,
                            );
                            final nowUtc = DateTime.now().toUtc();
                            final targetUtc = _startDateTime.difference(DateTime.now()).inMinutes.abs() <= 2
                                ? nowUtc.subtract(const Duration(minutes: 1))
                                : _startDateTime.toUtc();
                            final apiStartStr =
                                '${targetUtc.year}-${targetUtc.month.toString().padLeft(2, '0')}-${targetUtc.day.toString().padLeft(2, '0')} '
                                '${targetUtc.hour.toString().padLeft(2, '0')}:${targetUtc.minute.toString().padLeft(2, '0')}:${targetUtc.second.toString().padLeft(2, '0')}';

                            final res = await ApiClient().createClass(
                              name: finalTitle,
                              categoryId: resolvedCategoryId,
                              startTime: apiStartStr,
                              maxStudents: _maxMembers,
                              type: _isPaid ? 'paid' : 'free',
                              price: priceDouble,
                              isPrivate: _isPrivate,
                              allowRecording: _allowRecording,
                            );
                            final idVal = res.data?['data']?['id'];
                            if (idVal != null) {
                              createdClassId = int.tryParse('$idVal');
                            }
                          } on DioException catch (e) {
                            if (e.response?.statusCode == 401) {
                              serverError = 'انتهت جلسة الدخول — يرجى تسجيل الخروج والدخول مجدداً لنشر الحلقة للجميع';
                            } else {
                              serverError = e.response?.data?['message']?.toString() ??
                                  'تعذر نشر الحلقة على الخادم، تأكد من الاتصال بالإنترنت';
                            }
                          } catch (e) {
                            serverError = 'تعذر الاتصال بالخادم لنشر الحلقة';
                          }

                          if (createdClassId == null) {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    serverError ?? 'تعذر إنشاء الحلقة على الخادم',
                                    style: const TextStyle(fontFamily: 'Dubai'),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                            return;
                          }

                          final roomId = 'room_srv_$createdClassId';

                          await UserChaptersService.instance.createChapter(
                            name: finalTitle,
                            mainCategory: sectionName,
                            subCategory: subSectionName,
                            startTime: _formatDateTime(_startDateTime),
                            maxStudents: _maxMembers,
                            isPaid: _isPaid,
                            price: priceDouble,
                            isPrivate: _isPrivate,
                            allowRecording: _allowRecording,
                            showInReelsAsLive: !_isPrivate,
                            supervisorName: creatorName,
                            serverId: createdClassId,
                            customRoomId: roomId,
                          );

                          if (!_isPrivate) {
                            LiveStreamsService.instance.addLiveStream(
                              LiveStreamItem(
                                id: roomId,
                                title: finalTitle,
                                sheikhName: creatorName,
                                sheikhAvatar: 'assets/images/profile.png',
                                sectionName: sectionName,
                                subSectionName: subSectionName,
                                viewerCount: 1,
                                roomId: roomId,
                                isVideo: true,
                                startedAt: DateTime.now(),
                              ),
                            );
                          }

                          if (!mounted) return;
                          Navigator.of(context).pop();

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LiveRecitationRoom(
                                roomId: roomId,
                                circleTitle: finalTitle,
                                isSheikh: true,
                                classRoomId: createdClassId,
                                sheikhName: creatorName,
                                subscribersCount: 1,
                                capacity: _maxMembers,
                              ),
                            ),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم إنشاء الحلقة ونشرها بنجاح للجميع!',
                                style: TextStyle(fontFamily: 'Dubai'),
                              ),
                              backgroundColor: Color(0xFF00875A),
                            ),
                          );
                        },
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.play_circle_fill_rounded, color: Colors.white),
                  label: Text(
                    _isSubmitting ? 'جاري النشر...' : 'إنشاء وبدء الحلقة',
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
