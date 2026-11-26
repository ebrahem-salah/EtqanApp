import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/network/api_client.dart';
import '../auth/login_screen.dart';
import '../student/student_home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideMosquesAnimation;

  @override
  void initState() {
    super.initState();

    // 2.5 seconds total intro animation duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 1. Logo starts far away (scale 0.2) and zooms forward (scale 1.0)
    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // 2. Fade in opacity from invisible to fully visible
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // 3. Mosque silhouettes slide up from below
    _slideMosquesAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.2), // Starts offscreen below
      end: Offset.zero,              // Rises to bottom dock position
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Auto navigate after animation finishes (Persistent Session / Auto-login)
    Future.delayed(const Duration(milliseconds: 3200), () async {
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      bool hasToken = savedToken != null &&
          savedToken.isNotEmpty &&
          !savedToken.startsWith('offline_session_') &&
          !savedToken.startsWith('otp_session_') &&
          !savedToken.startsWith('google_token_') &&
          !savedToken.startsWith('apple_token_');

      if (hasToken) {
        try {
          await ApiClient().getProfile();
        } on DioException catch (e) {
          if (e.response?.statusCode == 401) {
            await prefs.remove('auth_token');
            hasToken = false;
          }
        } catch (_) {}
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => hasToken ? const StudentHomeScreen() : const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7DF), // Light cream yellow from design
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Center Original Etqan Logo with Zoom-In & Fade Effect (Image 3 from User)
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/logo/etqan_logo_original.png',
                  width: 170,
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    AppAssets.logo,
                    width: 150,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Original Mosque Silhouettes Sliding Up From Below (Image 1 from User)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideMosquesAnimation,
              child: Image.asset(
                'assets/images/mosque_silhouette.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
