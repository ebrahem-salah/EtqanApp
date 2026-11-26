import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/category_mapping.dart';
import '../../core/network/api_client.dart';
import '../../core/services/user_chapters_service.dart';
import '../../core/utils/app_feedback.dart';
import '../../providers/auth_provider.dart';

class AddChapterScreen extends StatefulWidget {
  const AddChapterScreen({super.key});

  @override
  State<AddChapterScreen> createState() => _AddChapterScreenState();
}

class _AddChapterScreenState extends State<AddChapterScreen> {
  final ApiClient _apiClient = ApiClient();
  final _nameController = TextEditingController();
  final _maxStudentsController = TextEditingController(text: '20');
  final _priceController = TextEditingController(text: '35');

  bool _isPaid = false;
  bool _isPrivate = false;
  bool _allowRecording = false;
  bool _showInReelsAsLive = true;
  bool _isSubmitting = false;

  DateTime? _selectedDateTime;
  String? _selectedCategory;
  String? _selectedSubCategory;

  // الأقسام الـ 16 الشاملة وتفرعاتها
  final Map<String, List<String>> _categoryHierarchy = {
    'المكتبة الإلكترونية': [
      'قسم المصاحف',
      'كتب التفسير',
      'كتب الحديث',
      'أحكام التجويد',
      'علوم أخرى'
    ],
    'تعليم الحروف والقاعدة النورانية': [
      'المستوى الأول (الحروف المفردة)',
      'المستوى الثاني (الحروف المركبة)',
      'المستوى الثالث (أحكام التجويد)'
    ],
    'القرآن الكريم': [
      'الحفظ (الصغار)',
      'الحفظ (الكبار)',
      'المراجعة (ثلاثون جزء)',
      'المراجعة (فمي بشوق)',
      'التجويد ومخارج الحروف',
      'المدارسة والتدبر',
      'المقرأة الجماعية',
      'علوم القرآن',
      'القراءات العشر',
      'المقامات الصوتية',
      'التفسير القرآني',
      'القراءة بالإسناد المتصل'
    ],
    'مقرأة إهداء الثواب': [
      'ختمة إهداء الوالدين',
      'ختمة المتوفين',
      'ختمة عامة',
      'إهداء المرضى'
    ],
    'السنة النبوية': [
      'الحفظ (الصغار)',
      'الحفظ (الكبار)',
      'علوم الحديث',
      'شروح الأحاديث',
      'الإقراء لكتب السنة',
      'القراءة بالإسناد'
    ],
    'الدورات العلمية': [
      'الدورات العلمية العامة',
      'الدورات العلمية الخاصة'
    ],
    'علوم أخرى': [
      'الفقه الإسلامي',
      'السيرة النبوية',
      'العقيدة الإسلامية',
      'الرقائق والتزكية'
    ],
    'الفتاوى': [
      'فتاوى دار الإفتاء الإلكترونية',
      'فتاوى مباشرة',
      'فتاوى مؤرشفة'
    ],
    'الرقية الشرعية': [
      'رقية مباشرة',
      'الراقي د. محمد كمال بو حسين',
      'الراقي د. أحمد عبد المنعم',
      'أذكار وتحصينات'
    ],
    'المسابقات الدينية': [
      'مسابقات القرآن الكريم',
      'مسابقات السنة النبوية'
    ],
    'الشهادات والإجازات العلمية': [
      'إجازات القرآن الكريم',
      'شهادات الدورات',
      'إجازات السنة النبوية'
    ],
    'الإذاعات الإسلامية': [
      'إذاعات القرآن المباشرة',
      'إذاعات التلاوات المرتلة',
      'إذاعات السنة النبوية'
    ],
    'الطفل المسلم': [
      'قصص الأنبياء للصغار',
      'آداب وأخلاق إسلامية',
      'أحاديث وأذكار الطفل'
    ],
    'المرأة المسلمة': [
      'أحكام فقهية خاصة بالمرأة',
      'آداب وسير أمهات المؤمنين',
      'أعمال وبركات البيت المسلم'
    ],
    'الأئمة والمؤذنون': [
      'إمام يبحث عن عمل في الإمامة',
      'مؤذن يبحث عن عمل في الأذان',
      'إعلانات المساجد'
    ],
    'المتطوعون في المنصة': [
      'متطوع في مجال الدعوة والإقراء',
      'متطوع في المجال الفني والتقني'
    ],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _maxStudentsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم الحلقة'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار القسم الرئيسي'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final startTimeStr = _selectedDateTime != null
        ? '${_selectedDateTime!.year}/${_selectedDateTime!.month}/${_selectedDateTime!.day} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
        : 'اليوم (مباشر)';

    final maxStudentsInt = int.tryParse(_maxStudentsController.text) ?? 20;
    final priceDouble = _isPaid ? (double.tryParse(_priceController.text) ?? 35.0) : 0.0;
    final subCat = _selectedSubCategory ?? 'عام';
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final creatorName = auth.currentUser?.name ?? 'الشيخ المقرئ';

    // 1. الحفظ على خادم الـ API بمعرف القسم الحقيقي أولاً
    int? createdClassId;
    String? serverError;
    try {
      final resolvedCategoryId = CategoryMapping.resolveCategoryId(
        _selectedCategory!,
        _selectedSubCategory,
      );
      final targetUtc = (_selectedDateTime == null ||
              _selectedDateTime!.difference(DateTime.now()).inMinutes.abs() <= 2)
          ? DateTime.now().toUtc().subtract(const Duration(minutes: 1))
          : _selectedDateTime!.toUtc();
      final apiStartStr =
          '${targetUtc.year}-${targetUtc.month.toString().padLeft(2, '0')}-${targetUtc.day.toString().padLeft(2, '0')} '
          '${targetUtc.hour.toString().padLeft(2, '0')}:${targetUtc.minute.toString().padLeft(2, '0')}:${targetUtc.second.toString().padLeft(2, '0')}';

      final res = await _apiClient.createClass(
        name: name,
        categoryId: resolvedCategoryId,
        startTime: apiStartStr,
        maxStudents: maxStudentsInt,
        type: _isPaid ? 'paid' : 'free',
        price: priceDouble,
        isPrivate: _isPrivate,
        allowRecording: _allowRecording,
      );
      final idVal = res.data?['data']?['id'];
      if (idVal != null) {
        createdClassId = int.tryParse('$idVal');
      }
    } catch (e) {
      serverError = AppFeedback.formatError(e);
    }

    if (createdClassId == null) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppFeedback.showError(
          context,
          'إنشاء الحلقة',
          serverError ?? 'الخادم لم يُرجع معرف الحلقة',
        );
      }
      return;
    }

    // 2. حفظ الحلقة في الذاكرة المحلية بنفس معرف السيرفر
    await UserChaptersService.instance.createChapter(
      name: name,
      mainCategory: _selectedCategory!,
      subCategory: subCat,
      startTime: startTimeStr,
      maxStudents: maxStudentsInt,
      isPaid: _isPaid,
      price: priceDouble,
      isPrivate: _isPrivate,
      allowRecording: _allowRecording,
      showInReelsAsLive: _showInReelsAsLive,
      supervisorName: creatorName,
      serverId: createdClassId,
      customRoomId: 'room_srv_$createdClassId',
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 تم إنشاء الحلقة بنجاح وحفظها في "حلقاتي" وربطها بالريلز!'),
          backgroundColor: Color(0xFF00875A),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subCategories = _selectedCategory != null
        ? (_categoryHierarchy[_selectedCategory!] ?? ['عام'])
        : <String>[];

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'اضافة حلقة جديدة',
          style: TextStyle(
            color: Color(0xFF1E2822),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Dubai',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00875A), size: 18),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // 1. Circle Photo Picker Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00875A), width: 2),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Color(0xFF00875A),
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اضافة صور الحلقة',
                      style: TextStyle(
                        color: Color(0xFF00875A),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Dubai',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. اسم الحلقة
              _buildFormContainer(
                title: 'اسم الحلقة',
                child: TextField(
                  controller: _nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: 'اكتب اسم الحلقة (أو اسمك لتسمية الحلقة باسمك)',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Dubai'),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 3. القسم الرئيسي
              _buildFormContainer(
                title: 'القسم الرئيسي',
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    hint: const Text('اختر القسم الرئيسي', style: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Dubai')),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00875A)),
                    items: _categoryHierarchy.keys.map<DropdownMenuItem<String>>((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontFamily: 'Dubai', fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                        final subs = val != null ? _categoryHierarchy[val] : null;
                        _selectedSubCategory = (subs != null && subs.isNotEmpty) ? subs.first : null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 4. القسم الفرعي
              if (subCategories.isNotEmpty) ...[
                _buildFormContainer(
                  title: 'القسم الفرعي',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedSubCategory,
                      hint: const Text('اختر القسم الفرعي', style: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Dubai')),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00875A)),
                      items: subCategories.map<DropdownMenuItem<String>>((sub) {
                        return DropdownMenuItem<String>(
                          value: sub,
                          child: Text(sub, style: const TextStyle(fontFamily: 'Dubai', fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSubCategory = val;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 5. تاريخ ووقت البدء
              GestureDetector(
                onTap: _pickDateTime,
                child: _buildFormContainer(
                  title: 'تاريخ ووقت البدء',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: Color(0xFF00875A), size: 22),
                      Text(
                        _selectedDateTime == null
                            ? 'اضغط للاختيار'
                            : '${_selectedDateTime!.year}/${_selectedDateTime!.month}/${_selectedDateTime!.day} - ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: _selectedDateTime == null ? Colors.grey : const Color(0xFF00875A),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Dubai',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 6. عدد المشتركين المسموح لهم بالدخول
              _buildFormContainer(
                title: 'عدد المشتركين المسموح لهم بالدخول',
                child: Row(
                  children: [
                    const Icon(Icons.people_outline, color: Colors.grey, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _maxStudentsController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '20',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 7. نوع الحلقة (مجانية / مدفوعة)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _isPaid,
                              activeColor: const Color(0xFF00875A),
                              onChanged: (val) => setState(() => _isPaid = val ?? false),
                            ),
                            const Text('مدفوعة', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
                            const SizedBox(width: 16),
                            Radio<bool>(
                              value: false,
                              groupValue: _isPaid,
                              activeColor: const Color(0xFF00875A),
                              onChanged: (val) => setState(() => _isPaid = val ?? false),
                            ),
                            const Text('مجانية', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Text(
                          'نوع الحلقة',
                          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    if (_isPaid) ...[
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: '35',
                                suffixText: 'ر.س',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              ),
                            ),
                          ),
                          const Text(
                            'سعر الحلقة',
                            style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 8. زر حلقة خاصة (Switch toggle)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Switch(
                      value: _isPrivate,
                      activeColor: const Color(0xFF00875A),
                      onChanged: (val) => setState(() => _isPrivate = val),
                    ),
                    const Text(
                      'حلقة خاصة (للأعضاء المدعوين فقط)',
                      style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 9. زر تسجيل الحلقة (Switch toggle)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Switch(
                      value: _allowRecording,
                      activeColor: const Color(0xFF00875A),
                      onChanged: (val) => setState(() => _allowRecording = val),
                    ),
                    const Row(
                      children: [
                        Text(
                          'تسجيل وقائع الحلقة وحفظها',
                          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.videocam_outlined, size: 20, color: Color(0xFF00875A)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 10. زر ظهور الحلقة في الريلز كمباشر (Switch toggle)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF00875A).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Switch(
                      value: _showInReelsAsLive,
                      activeColor: const Color(0xFF00875A),
                      onChanged: (val) => setState(() => _showInReelsAsLive = val),
                    ),
                    const Row(
                      children: [
                        Text(
                          'تظهر كبث مباشر في مقاطع الريلز 🔴',
                          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Color(0xFF00875A)),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.live_tv_rounded, size: 20, color: Color(0xFF00875A)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 11. Submit Button: اضافة
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF191919),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'اضافة',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontFamily: 'Dubai',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
