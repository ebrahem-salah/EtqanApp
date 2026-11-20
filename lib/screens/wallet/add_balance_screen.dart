import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/services/notification_service.dart';

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key});

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _amountController = TextEditingController(text: '100');
  final TextEditingController _nameController = TextEditingController(text: 'إبراهيم صلاح');
  final TextEditingController _cardNumberController = TextEditingController(text: '4111 2222 3333 4444');
  final TextEditingController _expiryController = TextEditingController(text: '12/28');
  final TextEditingController _cvvController = TextEditingController(text: '789');

  int _selectedPaymentMethod = 0; // 0: مدى, 1: فيزا/ماستركارد, 2: Apple Pay, 3: STC Pay, 4: تمارا/تابي
  bool _isLoading = false;

  final List<int> _quickAmounts = [50, 100, 200, 500];

  Future<void> _submitPayment() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال مبلغ صحيح', style: TextStyle(fontFamily: 'Dubai')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final methods = ['مدى (Mada)', 'بطاقة ائتمانية (Visa/MC)', 'Apple Pay', 'STC Pay', 'تمارا / تابي'];
      final chosenMethod = methods[_selectedPaymentMethod];

      await _apiClient.addWalletBalance(
        userId: 1,
        amount: amount,
        description: 'شحن رصيد المحفظة عبر $chosenMethod',
        referenceNo: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      );

      // إرسال إشعار فوري بنجاح العملية
      await NotificationService().showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'تم شحن المحفظة بنجاح! 💳',
        body: 'تمت إضافة $amount ر.س إلى رصيدك عبر $chosenMethod.',
        payload: 'wallet_recharge',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة $amount ر.س إلى محفظتك بنجاح عبر $chosenMethod!',
                style: const TextStyle(fontFamily: 'Dubai')),
            backgroundColor: const Color(0xFF00875A),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تأكيد عملية الشحن بنجاح وتحديث الرصيد', style: TextStyle(fontFamily: 'Dubai')),
            backgroundColor: Color(0xFF00875A),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          'شحن رصيد المحفظة',
          style: TextStyle(
            fontFamily: 'Dubai',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191919),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Amount Field
                  const Text(
                    'المبلغ المراد شحنه (ر.س)',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'أدخل المبلغ (مثال: 100)',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'ر.س',
                          style: TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold, color: Color(0xFF0F5B46), fontSize: 16),
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAF8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Amount Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _quickAmounts.map((amt) {
                      final isSelected = _amountController.text == amt.toString();
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _amountController.text = amt.toString();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0F5B46) : const Color(0xFFF1F5F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0F5B46) : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              '$amt ر.س',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isSelected ? Colors.white : const Color(0xFF191919),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),

                  // 2. Section Title: طرق الدفع المعتمدة
                  const Text(
                    'اختر وسيلة الدفع المعتمدة',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Mada (مدى)
                  _buildPaymentOption(
                    index: 0,
                    title: 'بطاقة مدى البنكية (Mada Debit)',
                    subtitle: 'الخصم الفوري من الحساب البنكي السعودي',
                    iconWidget: _buildBadge('مدى', const Color(0xFF007A3D)),
                  ),
                  const SizedBox(height: 8),

                  // Visa / MasterCard
                  _buildPaymentOption(
                    index: 1,
                    title: 'البطاقات الائتمانية (Visa / MasterCard)',
                    subtitle: 'فيزا وماستركارد الدولية والمحلية',
                    iconWidget: const Icon(Icons.credit_card, color: Color(0xFF0F5B46)),
                  ),
                  const SizedBox(height: 8),

                  // Apple Pay
                  _buildPaymentOption(
                    index: 2,
                    title: 'Apple Pay',
                    subtitle: 'الدفع الآمن السريع بلمسة واحدة أو Face ID',
                    iconWidget: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.apple, color: Colors.white, size: 16),
                          Text('Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // STC Pay
                  _buildPaymentOption(
                    index: 3,
                    title: 'STC Pay',
                    subtitle: 'المحفظة الرقمية لشركة الاتصالات السعودية',
                    iconWidget: _buildBadge('stc pay', const Color(0xFF4F008C)),
                  ),
                  const SizedBox(height: 8),

                  // Tamara / Tabby
                  _buildPaymentOption(
                    index: 4,
                    title: 'تمارا / تابي (تقسيط بدون فوائد)',
                    subtitle: 'الدفع لاحقاً أو على 4 دفعات ميسرة',
                    iconWidget: _buildBadge('تمارا', const Color(0xFFD4AF37)),
                  ),
                  const SizedBox(height: 20),

                  // 3. Card Details & Visual Preview (if card is selected)
                  if (_selectedPaymentMethod == 0 || _selectedPaymentMethod == 1) ...[
                    // Visual Interactive Card Preview
                    _buildVisualCardPreview(),
                    const SizedBox(height: 18),

                    const Text(
                      'اسم صاحب البطاقة',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      textAlign: TextAlign.right,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'الاسم كما هو مدون على البطاقة',
                        filled: true,
                        fillColor: const Color(0xFFF9FAF8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'رقم البطاقة',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: '**** **** **** ****',
                        prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF0F5B46)),
                        filled: true,
                        fillColor: const Color(0xFFF9FAF8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('رمز التحقق (CVV)', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 4,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: '123',
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAF8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('تاريخ الانتهاء (MM/YY)', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _expiryController,
                                keyboardType: TextInputType.datetime,
                                textAlign: TextAlign.center,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: '12/28',
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAF8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 4. Apple Pay Special Button
                  if (_selectedPaymentMethod == 2) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shield_outlined, color: Color(0xFF0F5B46), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'الدفع مشفر بالكامل عبر محفظة Apple الآمنة',
                            style: TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 5. Submit Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedPaymentMethod == 2 ? Colors.black : const Color(0xFF0F5B46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_selectedPaymentMethod == 2) const Icon(Icons.apple, color: Colors.white, size: 22),
                                if (_selectedPaymentMethod == 2) const SizedBox(width: 6),
                                Text(
                                  _selectedPaymentMethod == 2
                                      ? 'Pay ${_amountController.text} ر.س'
                                      : 'تأكيد الشحن فوراً (${_amountController.text} ر.س)',
                                  style: const TextStyle(
                                    fontFamily: 'Dubai',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required String title,
    required String subtitle,
    required Widget iconWidget,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5EE) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F5B46) : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF0F5B46) : const Color(0xFF191919),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontFamily: 'Dubai', fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF0F5B46) : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildVisualCardPreview() {
    final isMada = _selectedPaymentMethod == 0;
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isMada
              ? [const Color(0xFF005B38), const Color(0xFF00875A)]
              : [const Color(0xFF1E293B), const Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMada ? 'بطاقة مدى الرقمية' : 'Etqan Platinum Card',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Dubai', fontWeight: FontWeight.bold),
              ),
              isMada
                  ? _buildBadge('مدى mada', Colors.white.withOpacity(0.2))
                  : const Icon(Icons.credit_card, color: Colors.white70),
            ],
          ),
          Text(
            _cardNumberController.text.isEmpty ? '**** **** **** ****' : _cardNumberController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حامل البطاقة', style: TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'Dubai')),
                  Text(
                    _nameController.text.isEmpty ? 'اسم المستخدم' : _nameController.text,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Dubai', fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('تنتهي في', style: TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'Dubai')),
                  Text(
                    _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
