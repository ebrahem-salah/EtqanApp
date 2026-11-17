import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import 'login_screen.dart';
import '../student/student_home_screen.dart';

class WelcomeLandingScreen extends StatelessWidget {
  const WelcomeLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // Exact light yellow/cream background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Bar with Language Switcher (EN green circle)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00875A),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'EN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Center Illustration: Sheikh inside Mobile Frame
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/welcome_sheikh_illustration.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/figma_welcome_screen.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Page Indicators (2 dots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00875A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title: مرحباً بك في تطبيق اتقان
              const Text(
                'مرحباً بك في تطبيق اتقان',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2822),
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                'مكتبة شاملة ومتكاملة من الدروس والمحاضرات الدينية التي تناسب جميع الأعمار والمستويات',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Button 1: تسجيل الدخول (Green with user icon)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00875A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.person_outline, color: Colors.white, size: 20),
                  label: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Button 2: الاستمرار كزائر للتطبيق (Black button)
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
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
                    );
                  },
                  child: const Text(
                    'الاستمرار كزائر للتطبيق',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
