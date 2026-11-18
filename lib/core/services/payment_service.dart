import 'package:flutter/material.dart';
import 'supabase_service.dart';

/// طرق الدفع المتاحة في منظومة إتقان
enum PaymentMethod {
  mada,      // بطاقات مدى السعودية
  applePay,  // آبل باي
  visaMaster,// فيزا وماستركارد
  stcPay,    // إس تي سي باي
  fawry,     // فوري (مصر والشرق الأوسط)
  walletPoints, // رصيد نقاط المحفظة
}

/// نتيجة عملية الدفع
class PaymentResult {
  final bool success;
  final String transactionId;
  final String message;
  final double amount;
  final double balanceAdded;

  PaymentResult({
    required this.success,
    required this.transactionId,
    required this.message,
    required this.amount,
    this.balanceAdded = 0.0,
  });
}

/// خدمة معالجة المدفوعات وشحن المحفظة وحجز الجلسات
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final SupabaseService _supabase = SupabaseService();

  /// مفاتيح الربط مع بوابة ميسر (Moyasar) و Stripe
  static const String moyasarPublishableKey = 'pk_test_moyasar_etqan_live_2026';
  static const String stripePublishableKey = 'pk_test_stripe_etqan_live_2026';

  /// معالجة عملية شحن رصيد المحفظة المالي مباشرة (بدون نقاط)
  /// [amountInSAR]: قيمة الشحن المباشرة بالريال السعودي
  /// [method]: وسيلة الدفع المختارة
  Future<PaymentResult> rechargeWallet({
    required double amountInSAR,
    required PaymentMethod method,
  }) async {
    try {
      final txnId = 'TXN_RECHARGE_${DateTime.now().millisecondsSinceEpoch}';
      final methodStr = _mapMethodToString(method);

      // تسجيل المعاملة في السحابة بالقيمة المالية الحقيقية
      await _supabase.recordWalletTransaction(
        amount: amountInSAR,
        points: amountInSAR.toInt(),
        paymentMethod: methodStr,
        transactionType: 'recharge',
        referenceNumber: txnId,
      );

      return PaymentResult(
        success: true,
        transactionId: txnId,
        message: 'تم شحن المحفظة بنجاح وإضافة ${amountInSAR.toStringAsFixed(2)} ر.س إلى رصيدك.',
        amount: amountInSAR,
        balanceAdded: amountInSAR,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        transactionId: '',
        message: 'فشلت عملية الدفع: ${e.toString()}',
        amount: amountInSAR,
      );
    }
  }

  /// سداد رسوم جلسة التسميع الخاصة
  Future<PaymentResult> payForSessionBooking({
    required String circleTitle,
    required double sessionFeeSAR,
    required PaymentMethod method,
  }) async {
    try {
      final txnId = 'TXN_BOOK_${DateTime.now().millisecondsSinceEpoch}';
      final methodStr = _mapMethodToString(method);

      await _supabase.recordWalletTransaction(
        amount: sessionFeeSAR,
        points: 0,
        paymentMethod: methodStr,
        transactionType: 'booking_fee',
        referenceNumber: txnId,
      );

      return PaymentResult(
        success: true,
        transactionId: txnId,
        message: 'تم سداد رسوم الجلسة ($circleTitle) بنجاح وتأكيد الحجز.',
        amount: sessionFeeSAR,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        transactionId: '',
        message: 'فشل سداد الرسوم: ${e.toString()}',
        amount: sessionFeeSAR,
      );
    }
  }

  String _mapMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mada:
        return 'mada';
      case PaymentMethod.applePay:
        return 'apple_pay';
      case PaymentMethod.visaMaster:
        return 'visa';
      case PaymentMethod.stcPay:
        return 'stc_pay';
      case PaymentMethod.fawry:
        return 'fawry';
      case PaymentMethod.walletPoints:
        return 'points';
    }
  }
}
