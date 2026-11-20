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
import 'my_videos_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../chat/chat_conversation_screen.dart';
import '../supervisors/supervisors_screen.dart';
import '../volunteer/volunteer_screen.dart';
import '../appreciations/appreciations_screen.dart';
import '../support/support_screen.dart';
import 'student_record_screen.dart';

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
    final userName = (user != null && user.name.isNotEmpty) ? user.name : 'مشرف تجريبي 3';
    final userPhone = (user?.phone != null && user!.phone!.isNotEmpty) ? user.phone! : '+966966111111';
    final walletBal = user?.walletBalance.toStringAsFixed(1) ?? '0.0';

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية من الصورة 4
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Bar: Notification Bell & "المزيد" Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none, color: Color(0xFF191919), size: 22),
                        onPressed: () {},
                      ),
                    ),
                    const Text(
                      'المزيد',
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191919),
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Hero with Islamic Arch Background (media_1795163241217_9b26dc60.jpg)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mosque Arch Silhouette
                    Container(
                      width: 220,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EFE9).withOpacity(0.8),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(110),
                          bottom: Radius.circular(20),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        // Avatar Circle
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 46,
                              color: Color(0xFF78909C),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // User Name
                        Text(
                          userName,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191919),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Phone Number
                        Text(
                          userPhone,
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4 Circular Quick Action Buttons (media_1795163241217_9b26dc60.jpg)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 1. محادثاتي
                    _buildCircularAction(
                      icon: Icons.chat_bubble_outline,
                      label: 'محادثاتي',
                      hasNotificationDot: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChatConversationScreen(
                              userName: 'مشرف الدعم الفني',
                            ),
                          ),
                        );
                      },
                    ),
                    // 2. الاصدقاء
                    _buildCircularAction(
                      icon: Icons.people_outline,
                      label: 'الاصدقاء',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SheikhsScreen()),
                        );
                      },
                    ),
                    // 3. التطوع
                    _buildCircularAction(
                      icon: Icons.assignment_outlined,
                      label: 'التطوع',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const VolunteerScreen()),
                        );
                      },
                    ),
                    // 4. الإذاعات
                    _buildCircularAction(
                      icon: Icons.radio_outlined,
                      label: 'الإذاعات',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const QuranRadiosScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menu List Items (media_1795163241217_9b26dc60.jpg)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // المحفظة
                    _buildMenuItem(
                      title: 'المحفظة',
                      icon: Icons.account_balance_wallet_outlined,
                      leadingText: '$walletBal دولار',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WalletScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // الحلقات المضافة
                    _buildMenuItem(
                      title: 'الحلقات المضافة',
                      icon: Icons.video_library_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ChaptersScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // فيديوهاتي
                    _buildMenuItem(
                      title: 'فيديوهاتي',
                      icon: Icons.smart_display_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MyVideosScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // حسابي
                    _buildMenuItem(
                      title: 'حسابي',
                      icon: Icons.manage_accounts_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // سجل الطالب والواجبات
                    _buildMenuItem(
                      title: 'سجل الطالب والواجبات',
                      icon: Icons.auto_stories_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const StudentRecordScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // المشرفون التعليميون
                    _buildMenuItem(
                      title: 'المشرفون التعليميون',
                      icon: Icons.supervisor_account_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SupervisorsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // شهادات الشكر والتقدير
                    _buildMenuItem(
                      title: 'شهادات الشكر والتقدير',
                      icon: Icons.workspace_premium_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AppreciationsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // تواصل معنا والدعم الفني
                    _buildMenuItem(
                      title: 'تواصل معنا والدعم الفني',
                      icon: Icons.contact_support_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SupportScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool hasNotificationDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: const Color(0xFF191919), size: 24),
                ),
              ),
              if (hasNotificationDot)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00875A),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Dubai',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00875A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    String? leadingText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (leadingText != null)
              Text(
                leadingText,
                style: const TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00875A),
                ),
              ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Dubai',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191919),
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: const Color(0xFF191919), size: 22),
          ],
        ),
      ),
    );
  }
}
