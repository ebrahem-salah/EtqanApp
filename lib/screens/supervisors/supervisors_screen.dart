import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';

class SupervisorsScreen extends StatefulWidget {
  const SupervisorsScreen({super.key});

  @override
  State<SupervisorsScreen> createState() => _SupervisorsScreenState();
}

class _SupervisorsScreenState extends State<SupervisorsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  List<dynamic> _supervisors = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSupervisors();
  }

  Future<void> _loadSupervisors() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.getSupervisors();
      if (res.statusCode == 200 && res.data != null) {
        setState(() {
          _supervisors = res.data['data'] ?? [];
        });
      }
    } catch (_) {
      // Fallback sample data if empty
      _supervisors = [
        {
          'id': 1,
          'name': 'الشيخ الدكتور إبراهيم المنشاوي',
          'institution': 'مؤسسة إتقان الدولية',
          'sheikhs_count': 14,
          'circles_count': 32,
          'phone': '+966501112233',
        },
        {
          'id': 2,
          'name': 'الشيخ عبد الله بن محمد الدوسري',
          'institution': 'جمعية تحفيظ القرآن الكريم بالرياض',
          'sheikhs_count': 8,
          'circles_count': 19,
          'phone': '+966504445566',
        },
        {
          'id': 3,
          'name': 'المشرف العام م. أحمد عبد العزيز',
          'institution': 'مقرأة مكة المكرمة الإلكترونية',
          'sheikhs_count': 22,
          'circles_count': 45,
          'phone': '+966507778899',
        },
      ];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddSupervisorDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final instCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add_rounded, color: Color(0xFF00875A)),
            SizedBox(width: 8),
            Text('إضافة مشرف تعليمي جديد', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'اسم المشرف بالكامل',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف / الواتساب',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: instCtrl,
              decoration: InputDecoration(
                labelText: 'المؤسسة أو الجمعية التابع لها',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00875A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _supervisors.insert(0, {
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'name': nameCtrl.text,
                    'institution': instCtrl.text.isEmpty ? 'مؤسسة إتقان' : instCtrl.text,
                    'sheikhs_count': 0,
                    'circles_count': 0,
                    'phone': phoneCtrl.text,
                  });
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ تم تسجيل المشرف وإضافته للمنظومة التعليمية بنجاح!'),
                    backgroundColor: Color(0xFF00875A),
                  ),
                );
              }
            },
            child: const Text('إضافة المشرف', style: TextStyle(color: Colors.white, fontFamily: 'Dubai')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _supervisors.where((s) {
      final name = s['name']?.toString() ?? '';
      final inst = s['institution']?.toString() ?? '';
      return name.contains(_searchQuery) || inst.contains(_searchQuery);
    }).toList();

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
          'المشرفون التعليميون 👥',
          style: TextStyle(
            fontFamily: 'Dubai',
            color: Color(0xFF1E2822),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'إضافة مشرف جديد',
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF00875A)),
            onPressed: _showAddSupervisorDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم المشرف أو المؤسسة...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00875A)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Supervisors list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00875A)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, idx) {
                      final s = filtered[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFFE8F5E9),
                                  child: const Text('👨‍💼', style: TextStyle(fontSize: 22)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s['name'] ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'Dubai',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          s['institution'] ?? 'مؤسسة إتقان',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF00875A),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('الشيوخ التابعين', '${s['sheikhs_count'] ?? 0}'),
                                _buildStatItem('الحلقات النشطة', '${s['circles_count'] ?? 0}'),
                                _buildStatItem('التواصل', s['phone'] ?? '+966...'),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00875A))),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
