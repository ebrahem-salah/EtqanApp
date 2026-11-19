import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../student/student_home_screen.dart';

class WelcomeLandingScreen extends StatefulWidget {
  const WelcomeLandingScreen({super.key});

  @override
  State<WelcomeLandingScreen> createState() => _WelcomeLandingScreenState();
}

class _WelcomeLandingScreenState extends State<WelcomeLandingScreen> {
  bool _isEnglish = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // Exact light yellow/cream background
      body: SafeArea(
        child: Column(
          children: [
            // Top Section with Language Switcher Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEnglish = !_isEnglish;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00875A),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00875A).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _isEnglish ? 'AR' : 'EN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center Illustration: Sheikh Illustration inside clean white frame
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                color: Colors.white,
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
            ),

            // Bottom Section: Cream Yellow Card with Texts & Action Buttons
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFCFBE8),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        // Page Indicators (2 dots: green & grey)
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
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          _isEnglish ? 'Welcome to Etqan App' : 'مرحباً بك في تطبيق اتقان',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2822),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          _isEnglish
                              ? 'A global comprehensive platform for Quran, Sunnah, and Islamic sciences for all levels.'
                              : 'مكتبة شاملة ومتكاملة من الدروس والمحاضرات الدينية التي تناسب جميع الأعمار والمستويات',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),

                    // Action Buttons (Unified Layout)
                    Column(
                      children: [
                        // Button 1: إنشاء حساب جديد / Create Account (Solid Green)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00875A),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                            child: Text(
                              _isEnglish ? 'Create Account' : 'إنشاء حساب جديد',
                              style: const TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Button 2: تسجيل الدخول / Log In (White with Green Border)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF00875A), width: 2),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              _isEnglish ? 'Log In' : 'تسجيل الدخول',
                              style: const TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00875A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Button 3: الاستمرار كزائر / Continue as Guest (Ghost text)
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                            child: Text(
                              _isEnglish ? 'Continue as Guest >' : 'الاستمرار كزائر >',
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
