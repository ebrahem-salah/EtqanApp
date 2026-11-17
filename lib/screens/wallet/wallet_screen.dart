import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _currentBalance = 100;
  int _selectedPackageIndex = 1;
  int _selectedPaymentMethod = 0; // 0: Mada, 1: Apple Pay, 2: Visa

  final List<Map<String, dynamic>> _packages = [
    {'points': 50, 'price': '50 ر.س', 'popular': false},
    {'points': 100, 'price': '90 ر.س (خصم 10%)', 'popular': true},
    {'points': 250, 'price': '200 ر.س (خصم 20%)', 'popular': false},
  ];

  final List<Map<String, String>> _transactions = [
    {'title': 'حجز جلسة تصحيح سورة البقرة', 'date': '16 نوفمبر 2026', 'amount': '-20 نقطة', 'isDeduction': 'true'},
    {'title': 'شحن رصيد المحفظة عبر مدى', 'date': '10 نوفمبر 2026', 'amount': '+100 نقطة', 'isDeduction': 'false'},
    {'title': 'مكافأة تميز في مسابقة التجويد', 'date': '01 نوفمبر 2026', 'amount': '+20 نقطة', 'isDeduction': 'false'},
  ];

  void _chargeWallet() {
    final pkg = _packages[_selectedPackageIndex];
    setState(() {
      _currentBalance += pkg['points'] as int;
      _transactions.insert(0, {
        'title': 'شحن رصيد المحفظة بنجاح',
        'date': 'الآن',
        'amount': '+${pkg['points']} نقطة',
        'isDeduction': 'false',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 تم شحن ${pkg['points']} نقطة بنجاح في محفظتك!'),
        backgroundColor: const Color(0xFF00875A),
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2822)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'محفظتي ورصيد الحلقات',
          style: TextStyle(
            fontFamily: 'Dubai',
            color: Color(0xFF1E2822),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة الرصيد الفاخرة
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00875A), Color(0xFF00583A)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00875A).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الرصيد المتاح للاستخدام',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(AppAssets.wallet, width: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_currentBalance نقطة',
                    style: const TextStyle(
                      fontFamily: 'Dubai',
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'تتيح لك حجز 5 جلسات تسميع مباشرة مع كبار المشايخ',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // باقات شحن الرصيد
            const Text(
              'اختر باقة شحن النقاط:',
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2822),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: List.generate(_packages.length, (index) {
                final pkg = _packages[index];
                final isSelected = _selectedPackageIndex == index;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: index < _packages.length - 1 ? 10.0 : 0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedPackageIndex = index),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00875A).withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF00875A) : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (pkg['popular'] == true)
                              Container(
                                margin: const EdgeInsets.bottom: 6),
                            Text(
                              '${pkg['points']} نقطة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isSelected ? const Color(0xFF00875A) : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pkg['price'],
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // طرق الدفع
            const Text(
              'طريقة الدفع المفضلة:',
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2822),
              ),
            ),
            const SizedBox(height: 10),

            _buildPaymentOption(0, '🇸🇦 بطاقة مدى (Mada)', 'الدفع الفوري للبطاقات السعودية'),
            _buildPaymentOption(1, '🍎 Apple Pay', 'الدفع السريع بلمسة واحدة'),
            _buildPaymentOption(2, '💳 البطاقات الائتمانية (Visa / MasterCard)', 'فيزا وماستر كارد الدولية'),

            const SizedBox(height: 24),

            // زر شحن الرصيد
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF191919),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _chargeWallet,
                child: const Text(
                  'إتمام عملية الشحن الآن',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // سجل العمليات
            const Text(
              'سجل الحركات السابقة:',
              style: TextStyle(
                fontFamily: 'Dubai',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2822),
              ),
            ),
            const SizedBox(height: 10),

            Column(
              children: _transactions.map((tx) {
                final isDeduction = tx['isDeduction'] == 'true';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(tx['date']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                      Text(
                        tx['amount']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDeduction ? Colors.red.shade700 : const Color(0xFF00875A),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(int index, String title, String desc) {
    final isSelected = _selectedPaymentMethod == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF00875A) : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
      ),
      child: RadioListTile<int>(
        value: index,
        groupValue: _selectedPaymentMethod,
        activeColor: const Color(0xFF00875A),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        onChanged: (val) => setState(() => _selectedPaymentMethod = val ?? 0),
      ),
    );
  }
}
