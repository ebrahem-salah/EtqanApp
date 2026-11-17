import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AddChapterDialog extends StatefulWidget {
  const AddChapterDialog({super.key});

  @override
  State<AddChapterDialog> createState() => _AddChapterDialogState();
}

class _AddChapterDialogState extends State<AddChapterDialog> {
  final _titleController = TextEditingController();
  String _selectedMainCategory = 'القرآن الكريم';
  String _selectedSubCategory = 'الحفظ';
  int _maxMembers = 20;
  bool _isFree = true;
  bool _isPrivate = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);

  final List<String> _mainCategories = [
    'القرآن الكريم',
    'تعليم الحروف والقاعدة النورانية',
    'مقرأة إهداء الثواب',
    'السنة النبوية',
    'الرقية الشرعية',
    'الطفل المسلم',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'إضافة حلقة جديدة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Chapter Title
              const Text('عنوان الحلقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'مثال: حلقة إتقان سورة البقرة وتصحيح التلاوة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),

              // Main Category
              const Text('القسم الرئيسي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedMainCategory,
                items: _mainCategories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMainCategory = val);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('تاريخ الحلقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (d != null) setState(() => _selectedDate = d);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text('${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('وقت البدء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (t != null) setState(() => _selectedTime = t);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(_selectedTime.format(context), style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Max students count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الحد الأقصى للطلاب:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                        onPressed: () {
                          if (_maxMembers > 1) setState(() => _maxMembers--);
                        },
                      ),
                      Text('$_maxMembers طالب', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        onPressed: () {
                          if (_maxMembers < 50) setState(() => _maxMembers++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Type: Free or Paid
              Row(
                children: [
                  const Text('نوع الحلقة: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Radio<bool>(
                    value: true,
                    groupValue: _isFree,
                    onChanged: (val) => setState(() => _isFree = val!),
                  ),
                  const Text('مجانية', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 12),
                  Radio<bool>(
                    value: false,
                    groupValue: _isFree,
                    onChanged: (val) => setState(() => _isFree = val!),
                  ),
                  const Text('مدفوعة (نقاط)', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),

              // Private Session Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('حلقة خاصة (برمز دخول سري)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                value: _isPrivate,
                onChanged: (val) => setState(() => _isPrivate = val),
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إنشاء الحلقة بنجاح وجدولتها في الحلقات الجارية!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text(
                    'تأكيد وإنشاء الحلقة',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
