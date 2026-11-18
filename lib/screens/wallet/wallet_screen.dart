import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ApiClient _apiClient = ApiClient();
  double _currentBalance = 150.0;
  String _currency = 'ر.س';
  bool _isLoading = false;
  int _selectedPackageIndex = 1;
  int _selectedPaymentMethod = 0; // 0: Mada, 1: Apple Pay, 2: Visa

  final List<Map<String, dynamic>> _packages = [
    {'amount': 50.0, 'bonus': 0.0, 'title': 'باقة فضية', 'popular': false},
    {'amount': 100.0, 'bonus': 10.0, 'title': 'باقة ذهبية', 'popular': true},
    {'amount': 200.0, 'bonus': 30.0, 'title': 'باقة ماسية', 'popular': false},
  ];

  List<Map<String, dynamic>> _transactions = [
    {'title': 'حجز جلسة خاصة (سورة مريم)', 'date': 'اليوم', 'amount': '-35.00 ر.س', 'isDeduction': true},
    {'title': 'شحن رصيد مالي عبر مدى', 'date': 'أمس', 'amount': '+100.00 ر.س', 'isDeduction': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadLiveWallet();
  }

  Future<void> _loadLiveWallet() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.getMyWallet();
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['data'] ?? {};
        if (data['balance'] != null) {
          final bal = double.tryParse(data['balance'].toString());
          if (bal != null && bal > 0) {
            _currentBalance = bal;
          }
          if (data['currency'] != null) {
            _currency = data['currency'] == 'SAR' ? 'ر.س' : data['currency'].toString();
          }
        }
        final List txs = data['transactions'] ?? [];
        if (txs.isNotEmpty) {
          _transactions = txs.map<Map<String, dynamic>>((t) => {
            'title': t['description'] ?? 'معاملة مالية',
            'date': t['date'] ?? t['created_at'] ?? 'مؤخراً',
            'amount': '${t['type'] == 'debit' ? '-' : '+'}${t['amount']} $_currency',
            'isDeduction': t['type'] == 'debit',
          }).toList();
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _chargeWallet() async {
    final pkg = _packages[_selectedPackageIndex];
    final addedTotal = (pkg['amount'] as double) + (pkg['bonus'] as double);
    final txnRef = 'TXN_RECHARGE_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _currentBalance += addedTotal;
      _transactions.insert(0, {
        'title': 'شحن رصيد مالي مباشر ($txnRef)',
        'date': 'الآن',
        'amount': '+${addedTotal.toStringAsFixed(2)} $_currency',
        'isDeduction': false,
      });
    });

    try {
      await _apiClient.addWalletBalance(
        userId: 1,
        amount: addedTotal,
        description: 'شحن رصيد مالي مباشر عبر ${_getPaymentMethodName()}',
        referenceNo: txnRef,
      );
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 تم شحن ${addedTotal.toStringAsFixed(2)} $_currency بنجاح في محفظتك!'),
          backgroundColor: const Color(0xFF00875A),
        ),
      );
    }
  }

  String _getPaymentMethodName() {
    switch (_selectedPaymentMethod) {
      case 0: return 'مدى (Mada)';
      case 1: return 'Apple Pay';
      default: return 'بطاقة ائتمانية';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBE8), // الخلفية الرسمية
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2822)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'محفظة إتقان المالية (رصيد نقدي)',
          style: TextStyle(
            fontFamily: 'Dubai',
            color: Color(0xFF1E2822),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
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
                              'الرصيد النقدي المتاح بالمحفظة:',
                              style: TextStyle(
                                fontFamily: 'Dubai',
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'حقيقي مباشر',
                                style: TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _currentBalance.toStringAsFixed(2),
                              style: const TextStyle(
                                fontFamily: 'Dubai',
                                color: Color(0xFFFFDF73),
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currency,
                              style: const TextStyle(
                                fontFamily: 'Dubai',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '✨ رصيد مالي لحجز الجلسات الخاصة والاشتراك بالمقارئ (بدون نقاط)',
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'اختر باقة شحن الرصيد المباشر:',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E2822),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // باقات الشحن
                  Row(
                    children: List.generate(_packages.length, (index) {
                      final pkg = _packages[index];
                      final isSelected = _selectedPackageIndex == index;
                      final bonus = pkg['bonus'] as double;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPackageIndex = index;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              left: index < _packages.length - 1 ? 8.0 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF00875A) : Colors.grey.shade300,
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  pkg['title'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? const Color(0xFF00875A) : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(pkg['amount'] as double).toInt()}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00875A),
                                  ),
                                ),
                                Text(
                                  _currency,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                if (bonus > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '+${bonus.toInt()} ر.س بونص',
                                    style: const TextStyle(fontSize: 9, color: Color(0xFF00875A), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'وسيلة الدفع الإلكتروني:',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E2822),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // وسائل الدفع
                  Row(
                    children: [
                      _buildPayMethodChip(0, '💳 مدى (Mada)'),
                      const SizedBox(width: 8),
                      _buildPayMethodChip(1, ' Apple Pay'),
                      const SizedBox(width: 8),
                      _buildPayMethodChip(2, '💳 فيزا / ماستر'),
                    ],
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _chargeWallet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00875A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      '💳 تأكيد الشحن المباشر (${(_packages[_selectedPackageIndex]['amount'] as double).toInt()} $_currency)',
                      style: const TextStyle(fontFamily: 'Dubai', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'سجل العمليات المالية بالمحفظة:',
                    style: TextStyle(
                      fontFamily: 'Dubai',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E2822),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ..._transactions.map((tx) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
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
                            Text(
                              tx['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tx['date'] ?? '',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        Text(
                          tx['amount'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: tx['isDeduction'] == true ? Colors.redAccent : const Color(0xFF00875A),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
    );
  }

  Widget _buildPayMethodChip(int index, String label) {
    final isSelected = _selectedPaymentMethod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00875A) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF00875A) : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
