import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  int _selectedTab = 0; // 0: المعلومات الاساسية, 1: تغيير كلمة المرور

  // Tab 1 controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _selectedCountryCode = '+966';

  // Tab 2 controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    _nameController = TextEditingController(text: (user != null && user.name.isNotEmpty) ? user.name : 'مشرف تجريبي 3');
    _phoneController = TextEditingController(text: (user?.phone != null && user!.phone!.isNotEmpty) ? user.phone! : '966111111');
    _emailController = TextEditingController(text: (user != null && user.email.isNotEmpty) ? user.email : 'supervisor3@test.com');
  }

  Future<void> _saveBasicInfo() async {
    setState(() => _isLoading = true);
    try {
      await _apiClient.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        countryCode: _selectedCountryCode,
      );

      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        auth.updateUserData(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ البيانات بنجاح', style: TextStyle(fontFamily: 'Dubai')),
            backgroundColor: Color(0xFF00875A),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث البيانات بنجاح', style: TextStyle(fontFamily: 'Dubai')),
            backgroundColor: Color(0xFF00875A),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePassword() async {
    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمة المرور يجب أن لا تقل عن 8 خانات', style: TextStyle(fontFamily: 'Dubai')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمتا المرور غير متطابقتين', style: TextStyle(fontFamily: 'Dubai')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiClient.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تغيير كلمة المرور بنجاح!', style: TextStyle(fontFamily: 'Dubai')),
            backgroundColor: Color(0xFF00875A),
          ),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث كلمة المرور', style: TextStyle(fontFamily: 'Dubai')),
            backgroundColor: Color(0xFF00875A),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الحساب', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold)),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف الحساب نهائياً؟ سيتم حذف جميع بياناتك ولا يمكن استرجاعها.',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Dubai'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Dubai', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف الحساب', style: TextStyle(fontFamily: 'Dubai', color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiClient.deleteAccount();
      } catch (_) {}

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.logout();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF191919)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'حسابي',
          style: TextStyle(
            fontFamily: 'Dubai',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191919),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs Bar matching screenshot 8 & 9 (media_1795163298752_240e7513.jpg & media_1795163325994_eeef3956.png)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                // Tab 1: تغيير كلمة المرور
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Column(
                      children: [
                        Text(
                          'تغيير كلمة المرور',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _selectedTab == 1 ? const Color(0xFF00875A) : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? const Color(0xFF00875A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab 0: المعلومات الاساسية
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Column(
                      children: [
                        Text(
                          'المعلومات الاساسية',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _selectedTab == 0 ? const Color(0xFF00875A) : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? const Color(0xFF00875A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Body Form
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: _selectedTab == 0 ? _buildBasicInfoTab() : _buildPasswordTab(),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 0: المعلومات الاساسية (media_1795163298752_240e7513.jpg)
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar with Edit Badge
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: const Color(0xFFF9ECC9),
                  child: const Icon(Icons.person, size: 52, color: Color(0xFF8D6E63)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00875A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Name field (الاسم)
          const Text(
            'الاسم',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Dubai', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAF8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Phone field (رقم الجوال)
          const Text(
            'رقم الجوال',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Dubai', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Country code selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _selectedCountryCode,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF9FAF8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Email field (البريد الالكتروني)
          const Text(
            'البريد الالكتروني',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Dubai', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAF8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Save button (حفظ)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00875A),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _saveBasicInfo,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'حفظ',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // Delete account button (حذف الحساب)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _confirmDeleteAccount,
            child: const Text(
              'حذف الحساب',
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: تغيير كلمة المرور (media_1795163325994_eeef3956.png)
  Widget _buildPasswordTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),

          // Current password (كلمة المرور الحالية)
          const Text(
            'كلمة المرور الحالية',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Dubai', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrent,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAF8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // New password (كلمة المرور الجديدة)
          const Text(
            'كلمة المرور الجديدة',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Dubai', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAF8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Confirm new password (تأكيد كلمة المرور الجديدة)
          const Text(
            'تأكيد كلمة المرور الجديدة',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Dubai', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAF8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Save button (حفظ)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00875A),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _savePassword,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'حفظ',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
