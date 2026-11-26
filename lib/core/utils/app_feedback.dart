import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// أداة موحدة لإظهار نتائج العمليات (نجاح أو خطأ مع السبب التفصيلي) أثناء الاختبار والتشغيل
class AppFeedback {
  AppFeedback._();

  /// استخراج سبب الخطأ بشكل واضح ومفصل من أي استثناء (HTTP / Dio / عام)
  static String formatError(Object error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      final data = error.response?.data;

      if (data is Map) {
        final msg = data['message']?.toString();
        final errors = data['errors'];
        final List<String> details = [];
        if (errors is Map) {
          for (final entry in errors.entries) {
            final val = entry.value;
            if (val is List && val.isNotEmpty) {
              details.add('${entry.key}: ${val.join("، ")}');
            } else if (val != null) {
              details.add('${entry.key}: $val');
            }
          }
        }
        final combined = [
          if (msg != null && msg.isNotEmpty) msg,
          if (details.isNotEmpty) details.join(' | '),
        ].join(' — ');
        if (combined.isNotEmpty) {
          return code != null ? '[$code] $combined' : combined;
        }
      }

      if (code == 401) {
        return '[401] غير مصرح — يرجى تسجيل الخروج وإعادة الدخول';
      }
      if (code == 403) {
        return '[403] غير مسموح لهذا الحساب بهذا الإجراء';
      }
      if (code == 404) {
        return '[404] المسار غير موجود على الخادم';
      }
      if (code == 422) {
        return '[422] بيانات غير صالحة أو ناقصة';
      }
      if (code != null && code >= 500) {
        return '[$code] خطأ داخلي في الخادم';
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'انتهت مهلة الاتصال بالخادم (Timeout)';
        case DioExceptionType.connectionError:
          return 'تعذر الاتصال بالإنترنت أو الخادم';
        default:
          return error.message ?? error.toString();
      }
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  /// إظهار رسالة نجاح خضراء واضحة
  static void showSuccess(BuildContext? context, String message) {
    if (context == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ $message',
          style: const TextStyle(fontFamily: 'Dubai', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00875A),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// إظهار رسالة خطأ حمراء مفصلة مع اسم العملية وسبب الفشل
  static void showError(BuildContext? context, String action, Object error) {
    if (context == null || !context.mounted) return;
    final reason = formatError(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '❌ فشل $action: $reason',
          style: const TextStyle(fontFamily: 'Dubai', fontSize: 12),
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
