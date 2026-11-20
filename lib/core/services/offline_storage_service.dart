import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نموذج السورة القرآنية للتخزين دون اتصال
class QuranSurahOffline {
  final int number;
  final String name;
  final String englishName;
  final int numberOfAyahs;
  final String revelationType;

  QuranSurahOffline({
    required this.number,
    required this.name,
    required this.englishName,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory QuranSurahOffline.fromJson(Map<String, dynamic> json) {
    return QuranSurahOffline(
      number: json['number'] ?? 1,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 7,
      revelationType: json['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية',
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'name': name,
        'englishName': englishName,
        'numberOfAyahs': numberOfAyahs,
        'revelationType': revelationType,
      };
}

/// خدمة وضع عدم الاتصال للقرآن والمكتبة وسجل التلاوات (Offline Mode Manager)
class OfflineStorageService {
  OfflineStorageService._();
  static final OfflineStorageService instance = OfflineStorageService._();

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  List<QuranSurahOffline> _cachedSurahs = [];
  List<QuranSurahOffline> get cachedSurahs => _cachedSurahs;

  /// تهيئة الكاش ومراقبة الاتصال
  Future<void> initialize() async {
    // 1. التحقق من حالة الاتصال الأولية
    final results = await _connectivity.checkConnectivity();
    _isOnline = !results.contains(ConnectivityResult.none);

    // 2. الاستماع لأي تغير في الشبكة
    _connectivity.onConnectivityChanged.listen((results) {
      _isOnline = !results.contains(ConnectivityResult.none);
      debugPrint('حالة الاتصال بالإنترنت تغيرت: ${_isOnline ? "متصل" : "غير متصل (وضع أوفلاين)"}');
    });

    // 3. تحميل سور القرآن الكريم محلياً لضمان توفرها الدائم
    await loadOfflineSurahs();
  }

  /// تحميل السور من البيانات المحلية أو التخزين المؤقت
  Future<List<QuranSurahOffline>> loadOfflineSurahs() async {
    if (_cachedSurahs.isNotEmpty) return _cachedSurahs;

    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('offline_quran_surahs');

    if (cachedJson != null) {
      final List list = jsonDecode(cachedJson);
      _cachedSurahs = list.map((e) => QuranSurahOffline.fromJson(e)).toList();
      return _cachedSurahs;
    }

    // سور القرآن الكريم الأساسية المدمجة
    _cachedSurahs = _defaultSurahs;
    await prefs.setString('offline_quran_surahs', jsonEncode(_defaultSurahs.map((s) => s.toJson()).toList()));
    return _cachedSurahs;
  }

  /// حفظ موضع القراءة الأخير (العلامة المرجعية) دون إنترنت
  Future<void> saveBookmark({required int surahNumber, required int ayahNumber, required String surahName}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah_num', surahNumber);
    await prefs.setInt('last_read_ayah_num', ayahNumber);
    await prefs.setString('last_read_surah_name', surahName);
    await prefs.setString('last_read_timestamp', DateTime.now().toIso8601String());
  }

  /// جلب آخر موضع قراءة محفوظ
  Future<Map<String, dynamic>?> getLastBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final surahNum = prefs.getInt('last_read_surah_num');
    if (surahNum == null) return null;

    return {
      'surahNumber': surahNum,
      'ayahNumber': prefs.getInt('last_read_ayah_num') ?? 1,
      'surahName': prefs.getString('last_read_surah_name') ?? 'سورة الفاتحة',
      'timestamp': prefs.getString('last_read_timestamp'),
    };
  }

  /// قائمة أساسية لسور القرآن الكريم
  static final List<QuranSurahOffline> _defaultSurahs = [
    QuranSurahOffline(number: 1, name: 'سُورَةُ ٱلْفَاتِحَةِ', englishName: 'Al-Faatiha', numberOfAyahs: 7, revelationType: 'مكية'),
    QuranSurahOffline(number: 2, name: 'سُورَةُ البَقَرَةِ', englishName: 'Al-Baqara', numberOfAyahs: 286, revelationType: 'مدنية'),
    QuranSurahOffline(number: 3, name: 'سُورَةُ آلِ عِمْرَانَ', englishName: 'Aal-i-Imraan', numberOfAyahs: 200, revelationType: 'مدنية'),
    QuranSurahOffline(number: 4, name: 'سُورَةُ النِّسَاءِ', englishName: 'An-Nisaa', numberOfAyahs: 176, revelationType: 'مدنية'),
    QuranSurahOffline(number: 5, name: 'سُورَةُ المَائِدَةِ', englishName: 'Al-Maaida', numberOfAyahs: 120, revelationType: 'مدنية'),
    QuranSurahOffline(number: 6, name: 'سُورَةُ الأَنْعَامِ', englishName: 'Al-An\'aam', numberOfAyahs: 165, revelationType: 'مكية'),
    QuranSurahOffline(number: 7, name: 'سُورَةُ الأَعْرَافِ', englishName: 'Al-A\'raaf', numberOfAyahs: 206, revelationType: 'مكية'),
    QuranSurahOffline(number: 8, name: 'سُورَةُ الأَنْفَالِ', englishName: 'Al-Anfaal', numberOfAyahs: 75, revelationType: 'مدنية'),
    QuranSurahOffline(number: 9, name: 'سُورَةُ التَّوْبَةِ', englishName: 'At-Tawba', numberOfAyahs: 129, revelationType: 'مدنية'),
    QuranSurahOffline(number: 10, name: 'سُورَةُ يُونُسَ', englishName: 'Yunus', numberOfAyahs: 109, revelationType: 'مكية'),
    QuranSurahOffline(number: 11, name: 'سُورَةُ هُودٍ', englishName: 'Hud', numberOfAyahs: 123, revelationType: 'مكية'),
    QuranSurahOffline(number: 12, name: 'سُورَةُ يُوسُفَ', englishName: 'Yusuf', numberOfAyahs: 111, revelationType: 'مكية'),
    QuranSurahOffline(number: 18, name: 'سُورَةُ الكَهْفِ', englishName: 'Al-Kahf', numberOfAyahs: 110, revelationType: 'مكية'),
    QuranSurahOffline(number: 19, name: 'سُورَةُ مَرْيَمَ', englishName: 'Maryam', numberOfAyahs: 98, revelationType: 'مكية'),
    QuranSurahOffline(number: 36, name: 'سُورَةُ يسٓ', englishName: 'Yaseen', numberOfAyahs: 83, revelationType: 'مكية'),
    QuranSurahOffline(number: 55, name: 'سُورَةُ الرَّحْمَٰن', englishName: 'Ar-Rahmaan', numberOfAyahs: 78, revelationType: 'مدنية'),
    QuranSurahOffline(number: 56, name: 'سُورَةُ الوَاقِعَةِ', englishName: 'Al-Waaqia', numberOfAyahs: 96, revelationType: 'مكية'),
    QuranSurahOffline(number: 67, name: 'سُورَةُ المُلْكِ', englishName: 'Al-Mulk', numberOfAyahs: 30, revelationType: 'مكية'),
    QuranSurahOffline(number: 112, name: 'سُورَةُ الإِخْلَاصِ', englishName: 'Al-Ikhlaas', numberOfAyahs: 4, revelationType: 'مكية'),
    QuranSurahOffline(number: 113, name: 'سُورَةُ الفَلَقِ', englishName: 'Al-Falaq', numberOfAyahs: 5, revelationType: 'مكية'),
    QuranSurahOffline(number: 114, name: 'سُورَةُ النَّاسِ', englishName: 'An-Naas', numberOfAyahs: 6, revelationType: 'مكية'),
  ];
}
