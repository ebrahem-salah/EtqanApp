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
import '../notifications/notifications_screen.dart';
import '../sections/sections_hub_screen.dart';
import '../sections/dialogs/create_section_session_dialog.dart';

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
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          );
                        },
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
                    // بطاقة الأقسام الـ 16 الرئيسية الشاملة
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SectionsHubScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00875A), Color(0xFF005A3C)],
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
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.grid_view_rounded, color: Colors.white, size: 26),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'الأقسام الرئيسية (16 قسماً)',
                                        style: TextStyle(
                                          fontFamily: 'Dubai',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(Icons.verified, color: Colors.amber, size: 16),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'القرآن، السنة، الفتاوى، الرقية، النورانية، الطفل، المرأة...',
                                    style: TextStyle(
                                      fontFamily: 'Dubai',
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // المحفظة
                    _buildMenuItem(
                      title: 'المحفظة',
                      icon: Icons.account_balance_wallet_outlined,
                      leadingText: '$walletBal ر.س',
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

                    // تواصل معنا
                    _buildMenuItem(
                      title: 'تواصل معنا',
                      icon: Icons.help_outline_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SupportScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // الدعم الفني
                    _buildMenuItem(
                      title: 'الدعم الفني',
                      icon: Icons.headset_mic_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChatConversationScreen(
                              userName: 'الدعم الفني - تطبيق إتقان',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // الاسئلة الشائعة
                    _buildMenuItem(
                      title: 'الاسئلة الشائعة',
                      icon: Icons.chat_bubble_outline_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SupportScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // الشروط والاحكام
                    _buildMenuItem(
                      title: 'الشروط والاحكام',
                      icon: Icons.verified_user_outlined,
                      onTap: () {
                        _showTermsDialog(context);
                      },
                    ),
                    const SizedBox(height: 12),

                    // لغة التطبيق (AR / EN)
                    _buildLanguageItem(),
                    const SizedBox(height: 12),

                    // الاشعارات
                    _buildNotificationsToggle(),
                    const SizedBox(height: 12),

                    // تسجيل الخروج
                    _buildLogoutItem(context, auth),
                    const SizedBox(height: 24),

                    // رقم الإصدار
                    Text(
                      'الاصدار v1.0.01',
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
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

  // لغة التطبيق (AR / EN) من الصورة 1
  Widget _buildLanguageItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
          // Radio AR (Checked)
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00875A), width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00875A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'AR',
                style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Radio EN
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'EN',
                style: TextStyle(fontFamily: 'Dubai', color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'لغة التطبيق',
            style: TextStyle(
              fontFamily: 'Dubai',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191919),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.language_rounded, color: Color(0xFF191919), size: 22),
        ],
      ),
    );
  }

  // الاشعارات Switch من الصورة 1
  Widget _buildNotificationsToggle() {
    return StatefulBuilder(
      builder: (context, setStateLocal) {
        bool isNotificationsOn = true;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: isNotificationsOn,
                  activeColor: const Color(0xFF00875A),
                  activeTrackColor: const Color(0xFFC8E6C9),
                  onChanged: (val) {
                    setStateLocal(() {
                      isNotificationsOn = val;
                    });
                  },
                ),
              ),
              const Spacer(),
              const Text(
                'الاشعارات',
                style: TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191919),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.notifications_active_outlined, color: Color(0xFF191919), size: 22),
            ],
          ),
        );
      },
    );
  }

  // تسجيل الخروج باللون الأحمر من الصورة 1
  Widget _buildLogoutItem(BuildContext context, AuthProvider auth) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold), textAlign: TextAlign.right),
            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من تطبيق إتقان؟', style: TextStyle(fontFamily: 'Dubai'), textAlign: TextAlign.right),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء', style: TextStyle(fontFamily: 'Dubai', color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await auth.logout();
                },
                child: const Text('تأكيد الخروج', style: TextStyle(fontFamily: 'Dubai', color: Colors.white)),
              ),
            ],
          ),
        );
      },
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
        child: const Row(
          children: [
            Spacer(),
            Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent, // النص أحمر مطابق للصورة 1
              ),
            ),
            SizedBox(width: 12),
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('الشروط والأحكام وسياسة الخصوصية', style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold), textAlign: TextAlign.right),
        content: const SingleChildScrollView(
          child: Text(
            'تطبيق إتقان هو منصة إلكترونية لتعليم القرآن الكريم والسنة النبوية.\n\n'
            '1. يلتزم المستخدم بالآداب الإسلامية والأخلاق الفاضلة داخل الحلقات.\n'
            '2. المحتوى الصوتي والمرئي خاضع لرقابة المشرفين المعتمدين لضمان الجودة والإتقان.\n'
            '3. جميع المقارئ والمناهج معتمدة رسمياً وموثقة وفق الروايات المتواترة.\n\n'
            'يمكنك قراءة النسخة الكاملة على: https://www.etqan.site/privacy.html',
            style: TextStyle(fontFamily: 'Dubai', fontSize: 13, height: 1.6),
            textAlign: TextAlign.right,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'Dubai', color: Color(0xFF00875A))),
          ),
        ],
      ),
    );
  }
}
