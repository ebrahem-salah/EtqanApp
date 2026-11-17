import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../call/live_recitation_room.dart';

class MyChaptersScreen extends StatefulWidget {
  const MyChaptersScreen({super.key});

  @override
  State<MyChaptersScreen> createState() => _MyChaptersScreenState();
}

class _MyChaptersScreenState extends State<MyChaptersScreen> {
  int _selectedTab = 0; // 0: الجارية, 1: المنتهية

  final List<Map<String, dynamic>> _activeChapters = [
    {
      'title': 'ت 1',
      'supervisor': 'مشرف تجريبي 3',
      'time': '04:02PM - 16/11/2026',
      'attendees': '0 / 1',
      'status': 'جارية الآن',
    },
    {
      'title': 'new',
      'supervisor': 'مشرف تجريبي 3',
      'time': '09:38AM - 16/11/2026',
      'attendees': '0 / 1',
      'status': 'جارية الآن',
    },
    {
      'title': 'حلقة جزء عم',
      'supervisor': 'شيخ مستقل 1',
      'time': '08:24PM - 27/10/2026',
      'attendees': '5 / 20',
      'status': 'جارية الآن',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF4),
      appBar: AppBar(
        title: const Text('حلقاتي'),
        leading: IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          // Segmented Tabs Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'الحلقات الجارية',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontWeight: FontWeight.bold,
                          color: _selectedTab == 0 ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'الحلقات المنتهية',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontWeight: FontWeight.bold,
                          color: _selectedTab == 1 ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List of Chapters
          Expanded(
            child: _selectedTab == 0
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activeChapters.length,
                    itemBuilder: (context, index) {
                      final item = _activeChapters[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4EE),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.power_settings_new, size: 16, color: Colors.black87),
                                        onPressed: () {},
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.share, size: 16, color: AppColors.primary),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  item['time'],
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      item['supervisor'],
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBF4D8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.group_outlined, size: 14, color: Colors.black87),
                                      const SizedBox(width: 4),
                                      Text(
                                        'المشتركين ${item['attendees']}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: const Text('دخول الحلقة', style: TextStyle(fontSize: 12, color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => LiveRecitationRoom(
                                          roomId: 'room_${item['title']}',
                                          circleTitle: item['title'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'لا توجد حلقات منتهية حالياً',
                      style: TextStyle(fontFamily: 'Dubai', color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
