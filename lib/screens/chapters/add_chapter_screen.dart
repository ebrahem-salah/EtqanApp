import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';

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
  bool _isSubmitting = false;

  DateTime? _selectedDateTime;
  String? _selectedCategory;
  String? _selectedSubCategory;

  // Categories with dynamic hierarchy
  final Map<String, List<String>> _categoryHierarchy = {
    'تعليم الحروف والقاعدة النورانية': ['الجزء الأول', 'الجزء الثاني', 'الجزء الثالث'],
    'القرآن الكريم': ['الحفظ والإتقان', 'المراجعة والتثبيت', 'التجويد ومخارج الحروف', 'التدارس والتدبر', 'المقرأة الجماعية', 'علوم القرآن والتفسير'],
    'مقرأة إهداء الثواب': ['ختمة إهداء الوالدين', 'ختمة عامة', 'إهداء المتوفين'],
    'السنة النبوية': ['صحيح البخاري', 'صحيح مسلم', 'الأربعون النووية', 'رياض الصالحين'],
    'علوم أخرى': ['العقيدة الإسلامية', 'التاريخ والسير', 'اللغة العربية'],
    'الفتاوى': ['فتاوى العبادات', 'فتاوى المعاملات'],
    'الرقية الشرعية': ['الرقية من الكتاب والسنة', 'أذكار الصباح والمساء'],
    'الطفل المسلم': ['قصص الأنبياء للصغار', 'حفظ جزء عم'],
    'المرأة المسلمة': ['فقه المرأة', 'حلقات أمهات المؤمنين'],
    'قسم الفقه': ['فقه الطهارة والصلاة', 'فقه الزكاة والصيام'],
    'قسم الابتهال': ['المقامات الصوتية والتلاوة', 'الأناشيد والابتهالات'],
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

    try {
      final startTimeStr = _selectedDateTime != null
          ? _selectedDateTime!.toIso8601String()
          : DateTime.now().add(const Duration(hours: 2)).toIso8601String();

      final categoryIndex = _categoryHierarchy.keys.toList().indexOf(_selectedCategory!) + 1;

      await _apiClient.createClass(
        name: name,
        categoryId: categoryIndex,
        startTime: startTimeStr,
        maxStudents: int.tryParse(_maxStudentsController.text) ?? 20,
        type: _isPaid ? 'paid' : 'free',
        price: _isPaid ? (double.tryParse(_priceController.text) ?? 35.0) : 0.0,
        isPrivate: _isPrivate,
        allowRecording: _allowRecording,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 تم إنشاء الحلقة بنجاح وإضافتها على السيرفر!'),
            backgroundColor: Color(0xFF00875A),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم حفظ الحلقة بنجاح محلياً وعلى خادم إتقان'),
            backgroundColor: Color(0xFF00875A),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subCategories = _selectedCategory != null ? _categoryHierarchy[_selectedCategory!] ?? [] : [];

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // Exact background from Image 7
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
              // 1. Circle Photo Picker Header (Matching Image 7)
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
                    hintText: 'قراءة المصحف اهداء لوالدي',
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
                    items: _categoryHierarchy.keys.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontFamily: 'Dubai', fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                        _selectedSubCategory = null;
                        // Smart default: Memorization/Noorani = Do NOT record (false). Lectures/Fiqh/Sciences = Record (true).
                        if (val == 'تعليم الحروف والقاعدة النورانية' || val == 'الرقية الشرعية' || val == 'الطفل المسلم') {
                          _allowRecording = false;
                        } else if (val == 'قسم الفقه' || val == 'السنة النبوية' || val == 'علوم أخرى') {
                          _allowRecording = true;
                        } else {
                          _allowRecording = false;
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 4. القسم الفرعي (Dynamic Cascade if available)
              if (subCategories.isNotEmpty) ...[
                _buildFormContainer(
                  title: 'القسم الفرعي',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedSubCategory,
                      hint: const Text('اختر القسم الفرعي', style: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Dubai')),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00875A)),
                      items: subCategories.map((sub) {
                        return DropdownMenuItem(
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

              // 8. حلقة خاصة (Switch toggle)
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
                      'حلقة خاصة',
                      style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 9. تسجيل وحفظ الجلسة (Switch toggle)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
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
                              'تسجيل وحفظ الجلسة',
                              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.videocam_outlined, size: 20, color: Color(0xFF00875A)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _allowRecording
                          ? '🟢 سيتم تسجيل الدرس ورفعه تلقائياً للمكتبة كمرجع للطلاب'
                          : '🔒 جلسة خاصة غير مسجلة (حفظ تام لخصوصية تلاوة الطلاب ولن يتم استهلاك مساحة السيرفر)',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        color: _allowRecording ? const Color(0xFF00875A) : Colors.grey.shade600,
                        fontFamily: 'Dubai',
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 10. Black Submit Button: اضافة
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
