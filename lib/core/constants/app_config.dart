/// إعدادات خادم واستضافة منصة إتقان (Server & Environment Configuration)
/// يمكنك التبديل بين السيرفر المباشر بالـ IP أو الدومين الرسمي بتبديل سطر واحد فقط هنا!
class AppConfig {
  AppConfig._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ⚡ زر التبديل السريع بين الـ IP والدومين ⚡
  // عند تفعيل الدومين etqan.site في DNS، فقط غيّر false إلى true!
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const bool useDomain = false;

  /// عنوان الـ IP المباشر لسيرفر Hostinger VPS الخاص بك
  static const String serverIp = '72.61.163.197';

  /// النطاق الرسمي لمنصة إتقان
  static const String serverDomain = 'etqan.site';

  /// النطاق الأساسي الفعال تلقائياً بناءً على اختيارك أعلاه
  static String get host => useDomain ? 'https://$serverDomain' : 'http://$serverIp';

  /// مسار الـ API الكامل للمنصة
  static String get apiBaseUrl => '$host/api/v1';

  /// مسار التخزين والملفات العامة (الفيديوهات والصور المسجلة)
  static String get storageBaseUrl => '$host/storage';

  /// رابط التحقق من الشهادات والإجازات
  static String verifyCertUrl(String certNumber) => '$host/verify/cert/$certNumber';
}
