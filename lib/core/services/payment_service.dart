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
  final int pointsEarned;

  PaymentResult({
    required this.success,
    required this.transactionId,
    required this.message,
    required this.amount,
    this.pointsEarned = 0,
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

  /// معالجة عملية شحن المحفظة بالنقاط
  /// [amountInSAR]: المبلغ بالريال السعودي
  /// [method]: وسيلة الدفع المختارة
  Future<PaymentResult> rechargeWallet({
    required double amountInSAR,
    required PaymentMethod method,
  }) async {
    try {
      // 1 ريال = 10 نقاط في محفظة إتقان
      final pointsToAdd = (amountInSAR * 10).toInt();
      final txnId = 'TXN_RECHARGE_${DateTime.now().millisecondsSinceEpoch}';
      final methodStr = _mapMethodToString(method);

      // تسجيل المعاملة في السحابة
      await _supabase.recordWalletTransaction(
        amount: amountInSAR,
        points: pointsToAdd,
        paymentMethod: methodStr,
        transactionType: 'recharge',
        referenceNumber: txnId,
      );

      return PaymentResult(
        success: true,
        transactionId: txnId,
        message: 'تم شحن المحفظة بنجاح وإضافة $pointsToAdd نقطة إلى رصيدك.',
        amount: amountInSAR,
        pointsEarned: pointsToAdd,
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
