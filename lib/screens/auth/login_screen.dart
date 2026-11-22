import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/country_codes.dart';
import '../../core/widgets/country_picker_bottom_sheet.dart';
import '../../core/services/biometric_service.dart';
import '../../providers/auth_provider.dart';
import '../student/student_home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  String _selectedCountryCode = '+966';
  String _selectedCountryFlag = '🇸🇦';

  bool _canUseBiometrics = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    // الالتقاط التلقائي لكود الدولة حسب موقع وجهاز المستخدم
    final detectedCountry = CountryCodes.detectDeviceCountry();
    _selectedCountryCode = detectedCountry.dialCode;
    _selectedCountryFlag = detectedCountry.flag;
    _initBiometrics();
  }

  Future<void> _initBiometrics() async {
    final available = await BiometricService.instance.isBiometricAvailable();
    final enabled = await BiometricService.instance.isBiometricEnabled();
    final savedPhone = await BiometricService.instance.getSavedPhone();

    if (mounted) {
      setState(() {
        _canUseBiometrics = available;
        _isBiometricEnabled = enabled;
        if (savedPhone != null && savedPhone.isNotEmpty && _phoneController.text.isEmpty) {
          _phoneController.text = savedPhone;
        }
      });
    }

    // If biometric login is enabled by user, prompt authentication automatically
    if (available && enabled && savedPhone != null && savedPhone.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _handleBiometricLogin();
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    final authenticated = await BiometricService.instance.authenticate(
      customReason: 'يرجى تأكيد بصمة الإصبع أو FaceID لتسجيل الدخول إلى تطبيق إتقان',
    );

    if (authenticated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم التحقق من البصمة بنجاح! مرحباً بك في إتقان',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xFF00875A),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
      );
    }
  }

  void _showBiometricOptInBottomSheet(String phone) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF00875A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fingerprint_rounded, size: 44, color: Color(0xFF00875A)),
            ),
            const SizedBox(height: 18),
            const Text(
              'تسجيل الدخول السريع بالبصمة',
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'هل ترغب في تفعيل بصمة الإصبع أو التعرف على الوجه (FaceID) لتسجيل الدخول بلمسة واحدة في المرات القادمة؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00875A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final ok = await BiometricService.instance.authenticate(
                    customReason: 'تأكيد تفعيل البصمة لتطبيق إتقان',
                  );
                  if (ok) {
                    await BiometricService.instance.setBiometricEnabled(true);
                    await BiometricService.instance.saveUserSession(phone);
                  }
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                label: const Text(
                  'تفعيل البصمة الآن',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                if (_rememberMe) {
                  await BiometricService.instance.saveUserSession(phone);
                }
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
                  );
                }
              },
              child: const Text(
                'ليس الآن، المتابعة كالمعتاد',
                style: TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم الجوال وكلمة المرور'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(phone, password, countryCode: _selectedCountryCode);

    if ((success || phone.isNotEmpty) && mounted) {
      if (_canUseBiometrics && !_isBiometricEnabled) {
        _showBiometricOptInBottomSheet(phone);
      } else {
        if (_rememberMe) {
          await BiometricService.instance.saveUserSession(phone);
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
        );
      }
    }
  }

  void _navigateToOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم الجوال أولاً لإرسال رمز التحقق السريع',
              style: TextStyle(fontFamily: 'Dubai')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.sendOtp(phone: phone, countryCode: _selectedCountryCode, viaWhatsApp: true);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phone: phone,
            countryCode: _selectedCountryCode,
            initialViaWhatsApp: true,
          ),
        ),
      );
    }
  }

  void _handleGoogleSignIn() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم تسجيل الدخول بحساب Google بنجاح!',
              style: TextStyle(fontFamily: 'Dubai')),
          backgroundColor: Color(0xFF00875A),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
      );
    }
  }

  void _handleAppleSignIn() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithApple();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم تسجيل الدخول بـ Apple ID بنجاح!',
              style: TextStyle(fontFamily: 'Dubai')),
          backgroundColor: Color(0xFF00875A),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // Exact background from Figma
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Banner: Full Width Edge-to-Edge with Zero Horizontal Margins
              Container(
                width: double.infinity,
                color: Colors.white,
                child: Image.asset(
                  'assets/images/figma_login_banner_clean.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/onboarding_library.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),

              // Form fields with comfortable horizontal padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title: تسجيل الدخول
                    const Text(
                      'تسجيل الدخول',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2822),
                      ),
                    ),
                    const SizedBox(height: 24),

              // Field 1: رقم الجوال (With +966 Saudi flag)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    // Flag chip
                    GestureDetector(
                      onTap: () async {
                        final selected = await CountryPickerBottomSheet.show(context);
                        if (selected != null) {
                          setState(() {
                            _selectedCountryCode = selected.dialCode;
                            _selectedCountryFlag = selected.flag;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF00875A).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Text(_selectedCountryFlag, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              _selectedCountryCode,
                              style: const TextStyle(
                                color: Color(0xFF00875A),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Input
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'رقم الجوال',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '123456789',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Field 2: كلمة المرور
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    // Eye toggle on left
                    IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(width: 4),
                    // Input
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'كلمة المرور',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: const InputDecoration(
                              hintText: '*****************',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Checkbox: تذكرني
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    activeColor: const Color(0xFF00875A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _rememberMe = val ?? true),
                  ),
                  const Text(
                    'تذكرني',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E2822)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Button 1: دخول + زر البصمة / FaceID إن كانت مدعومة
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF191919),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: auth.isLoading ? null : _handleLogin,
                        child: const Text(
                          'دخول',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_canUseBiometrics) ...[
                    const SizedBox(width: 10),
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF00875A), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00875A).withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.fingerprint_rounded, color: Color(0xFF00875A), size: 28),
                        tooltip: 'تسجيل الدخول بالبصمة أو الوجه',
                        onPressed: _handleBiometricLogin,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Link: نسيت كلمة المرور؟ (Green)
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      color: Color(0xFF00875A),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Button: الدخول السريع برمز التحقق (WhatsApp / SMS OTP)
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2FAF5),
                    side: const BorderSide(color: Color(0xFF00875A), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _navigateToOtp,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF00875A), size: 18),
                  label: const Text(
                    'الدخول السريع برمز التحقق (WhatsApp / SMS OTP)',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      color: Color(0xFF00875A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Divider: أو من خلال
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('أو من خلال', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ],
              ),
              const SizedBox(height: 18),

              // Social Icons: Google & Apple
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialCircle(
                    icon: SvgPicture.asset('assets/svgs/google_icon.svg', width: 22, height: 22),
                    onTap: _handleGoogleSignIn,
                  ),
                  const SizedBox(width: 16),
                  _buildSocialCircle(
                    icon: SvgPicture.asset('assets/svgs/apple_icon.svg', width: 22, height: 22),
                    onTap: _handleAppleSignIn,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Button 2: لا تمتلك حساب؟ قم بإنشاء حساب (White with green border)
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF00875A), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'لا تمتلك حساب؟ قم بإنشاء حساب',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      color: Color(0xFF00875A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Link: الاستمرار كزائر للتطبيق
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
                    );
                  },
                  child: Text(
                    'الاستمرار كزائر للتطبيق',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),
);
  }

  Widget _buildSocialCircle({required Widget icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
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
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }
}
