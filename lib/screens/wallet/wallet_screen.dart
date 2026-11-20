import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import 'add_balance_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ApiClient _apiClient = ApiClient();
  double _currentBalance = 0.0;
  String _currency = 'دولار';
  bool _isLoading = false;

  DateTime? _fromDate;
  DateTime? _toDate;

  List<Map<String, dynamic>> _transactions = [];

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
          if (bal != null) {
            _currentBalance = bal;
          }
          if (data['currency'] != null) {
            _currency = data['currency'] == 'SAR' ? 'ر.س' : 'دولار';
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

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00875A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'DD/MM/YYYY';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
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
          'المحفظة',
          style: TextStyle(
            fontFamily: 'Dubai',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191919),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),

              // Giant Circular Gauge matching screenshot (media_1795163246913_c03a3902.png)
              Center(
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF191919), // الإطار الخارجي الأسود
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE8F5E9), // الإطار الداخلي الأخضر الفاتح
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentBalance.toStringAsFixed(_currentBalance.truncateToDouble() == _currentBalance ? 0 : 2),
                            style: const TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00875A), // الرقم الأخضر العريض
                            ),
                          ),
                          Text(
                            _currency,
                            style: const TextStyle(
                              fontFamily: 'Dubai',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191919),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Date Range Selector (التاريخ من / التاريخ الى)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    // التاريخ الى
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(isFrom: false),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF191919)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'التاريخ الى',
                                  style: TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _formatDate(_toDate),
                                  style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 35,
                      color: const Color(0xFFDDDDDD),
                    ),

                    // التاريخ من
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(isFrom: true),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'التاريخ من',
                                  style: TextStyle(fontFamily: 'Dubai', fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _formatDate(_fromDate),
                                  style: TextStyle(fontFamily: 'Dubai', fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF191919)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // White lower sheet for transactions
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: _transactions.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد حركات مالية في هذه الفترة',
                            style: TextStyle(fontFamily: 'Dubai', color: Colors.grey, fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final tx = _transactions[index];
                            final isDec = tx['isDeduction'] == true;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAF8),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tx['amount'],
                                    style: TextStyle(
                                      fontFamily: 'Dubai',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDec ? Colors.red : const Color(0xFF00875A),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        tx['title'],
                                        style: const TextStyle(
                                          fontFamily: 'Dubai',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        tx['date'],
                                        style: TextStyle(
                                          fontFamily: 'Dubai',
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),

          // Floating Action Button at bottom left matching screenshot (media_1795163246913_c03a3902.png)
          Positioned(
            bottom: 24,
            left: 24,
            child: GestureDetector(
              onTap: () async {
                final recharged = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const AddBalanceScreen()),
                );
                if (recharged == true) {
                  _loadLiveWallet();
                }
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF191919), // الدائرة السوداء
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Color(0xFF00875A), // علامة الزائد الخضراء
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
