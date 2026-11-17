import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../home/reels_home_screen.dart';
import '../chapters/chapters_screen.dart';
import '../sheikhs/sheikhs_screen.dart';
import '../my_chapters/my_chapters_screen.dart';
import '../chapters/add_chapter_dialog.dart';
import '../call/live_recitation_room.dart';
import '../wallet/wallet_screen.dart';
import '../competitions/competitions_screen.dart';
import '../library/library_screen.dart';
import '../radios/quran_radios_screen.dart';
import '../quran_tools/khatmah_azkar_screen.dart';
import '../sheikh_dashboard/sheikh_dashboard_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedTabIndex = 0;

  final List<Widget> _screens = const [
    ReelsHomeScreen(),
    ChaptersScreen(),
    SheikhsScreen(),
    MyChaptersScreen(),
    _MoreScreenPlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isSheikh = auth.currentUser?.role == UserRole.sheikh;

    return Scaffold(
      body: IndexedStack(
        index: _selectedTabIndex,
        children: _screens,
      ),
      floatingActionButton: isSheikh
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('إضافة حلقة'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AddChapterDialog(),
                );
              },
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppAssets.home, width: 22, height: 22, colorFilter: ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(AppAssets.home, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppAssets.chapters, width: 22, height: 22, colorFilter: ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(AppAssets.chapters, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            label: 'الحلقات',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppAssets.sheikhs, width: 22, height: 22, colorFilter: ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(AppAssets.sheikhs, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            label: 'الشيوخ',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppAssets.myChapters, width: 22, height: 22, colorFilter: ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(AppAssets.myChapters, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            label: 'حلقاتي',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppAssets.more, width: 22, height: 22, colorFilter: ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(AppAssets.more, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            label: 'المزيد',
          ),
        ],
      ),
    );
  }
}

class _MoreScreenPlaceholder extends StatelessWidget {
  const _MoreScreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isSheikh = user?.role == UserRole.sheikh;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        title: const Text('المزيد والإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                  child: const Icon(Icons.person, size: 36, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name.isNotEmpty == true ? user!.name : 'أحمد عبد المنعم',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSheikh ? 'حساب شيخ ومعلم معتمد' : 'حساب دارس وباحث',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    auth.switchUserRole();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          auth.currentUser?.role == UserRole.sheikh
                              ? 'تم التبديل إلى واجهة: الشيخ'
                              : 'تم التبديل إلى واجهة: الدارس',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text('تبديل الدور', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu Options
          _buildMenuTile(
            Icons.account_balance_wallet,
            'محفظتي ورصيد النقاط',
            '${user?.walletBalance.toStringAsFixed(0) ?? 100} نقطة',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WalletScreen()),
              );
            },
          ),
          _buildMenuTile(
            Icons.emoji_events,
            'مسابقة فرسان إتقان 2026',
            '100,000 ر.س 🏆',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CompetitionsScreen()),
              );
            },
          ),
          _buildMenuTile(Icons.bookmark, 'العناصر والمقاطع المحفوظة', ''),
          _buildMenuTile(
            Icons.library_books,
            'المكتبة الإسلامية والكتب',
            '20 كتاباً متون وتفسير',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LibraryScreen()),
              );
            },
          ),
          _buildMenuTile(
            Icons.radio,
            'الإذاعات القرآنية المباشرة',
            'بث حي 🔴',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QuranRadiosScreen()),
              );
            },
          ),
          _buildMenuTile(
            Icons.menu_book,
            'الورد اليومي والأذكار والقبلة',
            'الجزء 12 🔥',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KhatmahAzkarScreen()),
              );
            },
          ),
          _buildMenuTile(
            Icons.admin_panel_settings,
            'لوحة تحكم الشيخ المقرئ',
            'تبديل الحساب 👳‍♂️',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SheikhDashboardScreen()),
              );
            },
          ),
          _buildMenuTile(Icons.headset_mic, 'الدعم الفني والمساعدة', ''),
          _buildMenuTile(Icons.info_outline, 'عن منصة إتقان', 'الإصدار 1.0.0'),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.mic, color: Colors.white),
            label: const Text('دخول غرفة تسميع تجريبية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LiveRecitationRoom(
                    roomId: 'test_circle_101',
                    circleTitle: 'حلقة إتقان سورة الفاتحة والبقرة',
                    isSheikh: isSheikh,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String trailing, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing.isNotEmpty)
              Text(trailing, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
