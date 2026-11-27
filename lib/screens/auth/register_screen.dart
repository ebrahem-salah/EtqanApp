import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/country_codes.dart';
import '../../core/widgets/country_picker_bottom_sheet.dart';
import '../../providers/auth_provider.dart';
import '../student/student_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedCountryCode = '+20';
  String _selectedCountryFlag = '🇪🇬';
  String _selectedRole = 'student'; // 'student' | 'parent' | 'sheikh'
  bool _wantsVolunteer = false;

  bool _agreeToTerms = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final detected = CountryCodes.detectDeviceCountry();
    _selectedCountryCode = detected.dialCode;
    _selectedCountryFlag = detected.flag;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة', style: TextStyle(fontFamily: 'Dubai')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.isEmpty ? 'Pass#12345' : _passwordController.text,
      countryCode: _selectedCountryCode,
      userType: _selectedRole == 'sheikh' ? 'sheikh' : 'student',
      isParent: _selectedRole == 'parent',
      wantsVolunteer: _selectedRole != 'parent' && _wantsVolunteer,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم إنشاء حسابك بنجاح! مرحباً بك في إتقان',
              style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xFF00875A),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ ${auth.errorMessage ?? "فشل إنشاء الحساب، تأكد من البيانات"}',
            style: const TextStyle(fontFamily: 'Dubai'),
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _handleGoogleSignIn() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
      );
    }
  }

  void _handleAppleSignIn() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithApple();
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // Exact background from Figma
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header Banner (Exact Figma image: register_header_banner.png)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Image.asset(
                      AppAssets.registerHeaderBanner,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  // Clickable overlay on the back arrow (top right in RTL)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Form fields with comfortable horizontal padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title: تسجيل جديد
                    const Text(
                      'تسجيل جديد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2822),
                      ),
                    ),
                    const SizedBox(height: 4),

              // Subtitle: قم بإنشاء حساب جديد
              const Text(
                'قم بإنشاء حساب جديد واختر نوع الحساب',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 14),

              // Role Selector: طالب / والد / شيخ
              Row(
                children: [
                  _buildRoleCard(
                    value: 'student',
                    title: 'طالب',
                    subtitle: 'حفظ ومراجعة',
                    icon: Icons.school_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildRoleCard(
                    value: 'parent',
                    title: 'والد / ولي أمر',
                    subtitle: 'متابعة الأبناء',
                    icon: Icons.family_restroom_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildRoleCard(
                    value: 'sheikh',
                    title: 'شيخ / محفّظ',
                    subtitle: 'إدارة الحلقات',
                    icon: Icons.menu_book_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Field 1: الاسم
              _buildFigmaField(
                label: 'الاسم',
                controller: _nameController,
                hint: 'Mohmed Ahmed',
              ),
              const SizedBox(height: 12),

              // Field 2: رقم الجوال (With +966)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    // Flag chip with smart country picker
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
              const SizedBox(height: 12),

              // Field 3: البريد الالكتروني
              _buildFigmaField(
                label: 'البريد الالكتروني',
                controller: _emailController,
                hint: 'username@mail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Field 4: كلمة المرور
              _buildFigmaPasswordField(
                label: 'كلمة المرور',
                controller: _passwordController,
                obscureText: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 12),

              // Field 5: تأكيد كلمة المرور
              _buildFigmaPasswordField(
                label: 'تأكيد كلمة المرور',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 12),

              if (_selectedRole != 'parent')
                Row(
                  children: [
                    Checkbox(
                      value: _wantsVolunteer,
                      activeColor: const Color(0xFF00875A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) => setState(() => _wantsVolunteer = val ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'أرغب بالتطوع في مبادرات إتقان الخيرية 🤝 (يمكن إكماله من داخل التطبيق)',
                        style: TextStyle(fontSize: 12, color: Colors.black87, fontFamily: 'Dubai'),
                      ),
                    ),
                  ],
                ),

              // Terms & Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    activeColor: const Color(0xFF00875A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _agreeToTerms = val ?? true),
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 12, color: Colors.black87, fontFamily: 'Dubai'),
                        children: [
                          TextSpan(text: 'لقد قرأت وأوافق على '),
                          TextSpan(
                            text: 'الشروط والأحكام',
                            style: TextStyle(
                              color: Color(0xFF00875A),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Button: تسجيل (Black Button matching Figma)
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF191919),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _handleRegister,
                  child: const Text(
                    'تسجيل',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

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
              const SizedBox(height: 16),

              // Social Icons: Google & Apple
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _handleGoogleSignIn,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset('assets/svgs/google_icon.svg', width: 22, height: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _handleAppleSignIn,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset('assets/svgs/apple_icon.svg', width: 22, height: 22),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Link: لديك حساب بالفعل؟ تسجيل الدخول
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.black87),
                      children: [
                        TextSpan(text: 'لديك حساب بالفعل؟ '),
                        TextSpan(
                          text: 'تسجيل الدخول',
                          style: TextStyle(
                            color: Color(0xFF00875A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    ),
  ),
),
);
  }

  Widget _buildRoleCard({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool selected = _selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F5E9) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFF00875A) : Colors.grey.shade300,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? const Color(0xFF00875A) : Colors.grey.shade600,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: selected ? const Color(0xFF00875A) : const Color(0xFF191919),
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFigmaField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                TextField(
                  controller: controller,
                  obscureText: obscureText,
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
    );
  }
}
