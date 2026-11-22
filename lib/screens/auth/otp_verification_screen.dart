import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/biometric_service.dart';
import '../../providers/auth_provider.dart';
import '../student/student_home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String countryCode;
  final bool initialViaWhatsApp;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.countryCode = '+966',
    this.initialViaWhatsApp = true,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  late bool _viaWhatsApp;
  int _secondsRemaining = 59;
  Timer? _timer;
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _viaWhatsApp = widget.initialViaWhatsApp;
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 59;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text.trim()).join();

  void _handleResend({required bool useWhatsApp}) async {
    setState(() {
      _viaWhatsApp = useWhatsApp;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.sendOtp(
      phone: widget.phone,
      countryCode: widget.countryCode,
      viaWhatsApp: useWhatsApp,
    );

    _startCountdown();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            useWhatsApp 
              ? '💬 تم إرسال كود جديد عبر واتساب بنجاح' 
              : '📩 تم إرسال كود جديد عبر رسالة نصية قصيرة SMS',
            style: const TextStyle(fontFamily: 'Dubai'),
          ),
          backgroundColor: const Color(0xFF00875A),
        ),
      );
    }
  }

  void _handleVerify() async {
    final code = _otpCode;
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رمز التحقق المكون من 4 أرقام بالكامل',
              style: TextStyle(fontFamily: 'Dubai')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.verifyOtpAndLogin(
      phone: widget.phone,
      otp: code,
      countryCode: widget.countryCode,
    );
    setState(() => _isVerifying = false);

    if (success && mounted) {
      // Check if biometrics is available to prompt user
      final canBio = await BiometricService.instance.isBiometricAvailable();
      final bioEnabled = await BiometricService.instance.isBiometricEnabled();

      if (canBio && !bioEnabled && mounted) {
        _showBiometricPrompt();
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showBiometricPrompt() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 26.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF00875A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fingerprint_rounded, size: 42, color: Color(0xFF00875A)),
            ),
            const SizedBox(height: 16),
            const Text(
              'تفعيل تسجيل الدخول بالبصمة',
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'هل ترغب في تفعيل بصمة الإصبع أو FaceID لتسجيل الدخول السريع في المرات القادمة بدون انتظار كود الـ OTP؟',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00875A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final ok = await BiometricService.instance.authenticate(
                    customReason: 'تأكيد تفعيل البصمة لتطبيق إتقان',
                  );
                  if (ok) {
                    await BiometricService.instance.setBiometricEnabled(true);
                    await BiometricService.instance.saveUserSession('${widget.countryCode}${widget.phone}');
                  }
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.check, color: Colors.white, size: 18),
                label: const Text(
                  'تفعيل البصمة الآن',
                  style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('المتابعة بدون تفعيل', style: TextStyle(fontFamily: 'Dubai', color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الكريمية الرسمية
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Icon with badge
              Center(
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00875A).withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _viaWhatsApp ? Icons.chat_bubble_outline_rounded : Icons.mark_email_read_outlined,
                      size: 42,
                      color: const Color(0xFF00875A),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'رمز التحقق السريع',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2822),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'أدخل الرمز المكون من 4 أرقام الذي تم إرساله إلى:\n${widget.countryCode} ${widget.phone}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Dubai',
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),

              // Delivery Channel Chip
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _viaWhatsApp ? const Color(0xFFE8F8F0) : const Color(0xFFEBF3FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _viaWhatsApp ? const Color(0xFF25D366) : const Color(0xFF2B80FF),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _viaWhatsApp ? Icons.whatsapp : Icons.sms_outlined,
                        size: 16,
                        color: _viaWhatsApp ? const Color(0xFF0F8A43) : const Color(0xFF1967D2),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _viaWhatsApp ? 'تم الإرسال عبر واتساب (WhatsApp)' : 'تم الإرسال عبر رسالة نصية قصيرة (SMS)',
                        style: TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _viaWhatsApp ? const Color(0xFF0F8A43) : const Color(0xFF1967D2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 4 OTP Box Inputs
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 58,
                      height: 62,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _controllers[index].text.isNotEmpty
                              ? const Color(0xFF00875A)
                              : Colors.grey.shade300,
                          width: _controllers[index].text.isNotEmpty ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2822),
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            setState(() {});
                            if (val.isNotEmpty && index < 3) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (val.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            if (_otpCode.length == 4) {
                              _handleVerify();
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),

              // Confirm Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF191919),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _isVerifying ? null : _handleVerify,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'تأكيد ومتابعة',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Countdown / Resend options
              if (!_canResend) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'إعادة الإرسال متاحة بعد 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontFamily: 'Dubai',
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Resend via other channel
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('لم يصلك الرمز؟ ', style: TextStyle(fontFamily: 'Dubai', color: Colors.black54)),
                    GestureDetector(
                      onTap: () => _handleResend(useWhatsApp: !_viaWhatsApp),
                      child: Text(
                        _viaWhatsApp ? 'أرسل عبر رسالة نصية SMS 📩' : 'أرسل عبر واتساب WhatsApp 💬',
                        style: const TextStyle(
                          fontFamily: 'Dubai',
                          color: Color(0xFF00875A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),

              // Quick Hint about WhatsApp / SMS
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Color(0xFF00875A)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _viaWhatsApp
                          ? 'إذا لم يكن الرقم مسجلاً على واتساب، سيتم تحويل الرمز تلقائياً كرسالة SMS عادية.'
                          : 'تصل رسائل الـ SMS مباشرة إلى شريحة الهاتف حتى بدون اتصال إنترنت.',
                        style: const TextStyle(
                          fontFamily: 'Dubai',
                          fontSize: 11,
                          color: Colors.black54,
                          height: 1.4,
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
}
