import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MushafSurahMeta {
  final int number;
  final String name;
  final int ayahsCount;
  final String revelationType;

  const MushafSurahMeta({
    required this.number,
    required this.name,
    required this.ayahsCount,
    required this.revelationType,
  });

  factory MushafSurahMeta.fromJson(Map<String, dynamic> json) {
    final rev = (json['revelationType'] ?? '').toString();
    return MushafSurahMeta(
      number: int.tryParse('${json['number'] ?? 1}') ?? 1,
      name: (json['name'] ?? '').toString(),
      ayahsCount: int.tryParse('${json['numberOfAyahs'] ?? json['ayahsCount'] ?? 7}') ?? 7,
      revelationType: rev == 'Meccan' || rev == 'مكية' ? 'مكية' : 'مدنية',
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'name': name,
        'ayahsCount': ayahsCount,
        'revelationType': revelationType,
      };
}

/// خدمة المصحف النصي العثماني الكامل (114 سورة) مع حفظ تلقائي أوفلاين
class QuranUthmaniService {
  QuranUthmaniService._();
  static final QuranUthmaniService instance = QuranUthmaniService._();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 15),
  ));

  static const String _surahsKey = 'quran_uthmani_surahs_meta_v1';
  static const String _surahPrefix = 'quran_uthmani_surah_ayahs_v1_';
  static const String _tafsirPrefix = 'quran_tafsir_muyassar_v1_';

  final Map<int, List<Map<String, dynamic>>> _memorySurahCache = {};
  final Map<int, Map<int, String>> _memoryTafsirCache = {};
  List<MushafSurahMeta>? _memoryMetaCache;

  /// قائمة السور الـ 114 كاملة للعرض الفوري والبحث السريع
  static const List<MushafSurahMeta> allSurahsMeta = [
    MushafSurahMeta(number: 1, name: 'سُورَةُ ٱلْفَاتِحَةِ', ayahsCount: 7, revelationType: 'مكية'),
    MushafSurahMeta(number: 2, name: 'سُورَةُ البَقَرَةِ', ayahsCount: 286, revelationType: 'مدنية'),
    MushafSurahMeta(number: 3, name: 'سُورَةُ آلِ عِمْرَانَ', ayahsCount: 200, revelationType: 'مدنية'),
    MushafSurahMeta(number: 4, name: 'سُورَةُ النِّسَاءِ', ayahsCount: 176, revelationType: 'مدنية'),
    MushafSurahMeta(number: 5, name: 'سُورَةُ المَائِدَةِ', ayahsCount: 120, revelationType: 'مدنية'),
    MushafSurahMeta(number: 6, name: 'سُورَةُ الأَنْعَامِ', ayahsCount: 165, revelationType: 'مكية'),
    MushafSurahMeta(number: 7, name: 'سُورَةُ الأَعْرَافِ', ayahsCount: 206, revelationType: 'مكية'),
    MushafSurahMeta(number: 8, name: 'سُورَةُ الأَنْفَالِ', ayahsCount: 75, revelationType: 'مدنية'),
    MushafSurahMeta(number: 9, name: 'سُورَةُ التَّوْبَةِ', ayahsCount: 129, revelationType: 'مدنية'),
    MushafSurahMeta(number: 10, name: 'سُورَةُ يُونُسَ', ayahsCount: 109, revelationType: 'مكية'),
    MushafSurahMeta(number: 11, name: 'سُورَةُ هُودٍ', ayahsCount: 123, revelationType: 'مكية'),
    MushafSurahMeta(number: 12, name: 'سُورَةُ يُوسُفَ', ayahsCount: 111, revelationType: 'مكية'),
    MushafSurahMeta(number: 13, name: 'سُورَةُ الرَّعْدِ', ayahsCount: 43, revelationType: 'مدنية'),
    MushafSurahMeta(number: 14, name: 'سُورَةُ إِبْرَاهِيمَ', ayahsCount: 52, revelationType: 'مكية'),
    MushafSurahMeta(number: 15, name: 'سُورَةُ الحِجْرِ', ayahsCount: 99, revelationType: 'مكية'),
    MushafSurahMeta(number: 16, name: 'سُورَةُ النَّحْلِ', ayahsCount: 128, revelationType: 'مكية'),
    MushafSurahMeta(number: 17, name: 'سُورَةُ الإِسْرَاءِ', ayahsCount: 111, revelationType: 'مكية'),
    MushafSurahMeta(number: 18, name: 'سُورَةُ الكَهْفِ', ayahsCount: 110, revelationType: 'مكية'),
    MushafSurahMeta(number: 19, name: 'سُورَةُ مَرْيَمَ', ayahsCount: 98, revelationType: 'مكية'),
    MushafSurahMeta(number: 20, name: 'سُورَةُ طه', ayahsCount: 135, revelationType: 'مكية'),
    MushafSurahMeta(number: 21, name: 'سُورَةُ الأَنْبِيَاءِ', ayahsCount: 112, revelationType: 'مكية'),
    MushafSurahMeta(number: 22, name: 'سُورَةُ الحَجِّ', ayahsCount: 78, revelationType: 'مدنية'),
    MushafSurahMeta(number: 23, name: 'سُورَةُ المُؤْمِنُونَ', ayahsCount: 118, revelationType: 'مكية'),
    MushafSurahMeta(number: 24, name: 'سُورَةُ النُّورِ', ayahsCount: 64, revelationType: 'مدنية'),
    MushafSurahMeta(number: 25, name: 'سُورَةُ الفُرْقَانِ', ayahsCount: 77, revelationType: 'مكية'),
    MushafSurahMeta(number: 26, name: 'سُورَةُ الشُّعَرَاءِ', ayahsCount: 227, revelationType: 'مكية'),
    MushafSurahMeta(number: 27, name: 'سُورَةُ النَّمْلِ', ayahsCount: 93, revelationType: 'مكية'),
    MushafSurahMeta(number: 28, name: 'سُورَةُ القَصَصِ', ayahsCount: 88, revelationType: 'مكية'),
    MushafSurahMeta(number: 29, name: 'سُورَةُ العَنْكَبُوتِ', ayahsCount: 69, revelationType: 'مكية'),
    MushafSurahMeta(number: 30, name: 'سُورَةُ الرُّومِ', ayahsCount: 60, revelationType: 'مكية'),
    MushafSurahMeta(number: 31, name: 'سُورَةُ لُقْمَانَ', ayahsCount: 34, revelationType: 'مكية'),
    MushafSurahMeta(number: 32, name: 'سُورَةُ السَّجْدَةِ', ayahsCount: 30, revelationType: 'مكية'),
    MushafSurahMeta(number: 33, name: 'سُورَةُ الأَحْزَابِ', ayahsCount: 73, revelationType: 'مدنية'),
    MushafSurahMeta(number: 34, name: 'سُورَةُ سَبَإٍ', ayahsCount: 54, revelationType: 'مكية'),
    MushafSurahMeta(number: 35, name: 'سُورَةُ فَاطِرٍ', ayahsCount: 45, revelationType: 'مكية'),
    MushafSurahMeta(number: 36, name: 'سُورَةُ يسٓ', ayahsCount: 83, revelationType: 'مكية'),
    MushafSurahMeta(number: 37, name: 'سُورَةُ الصَّافَّاتِ', ayahsCount: 182, revelationType: 'مكية'),
    MushafSurahMeta(number: 38, name: 'سُورَةُ صٓ', ayahsCount: 88, revelationType: 'مكية'),
    MushafSurahMeta(number: 39, name: 'سُورَةُ الزُّمَرِ', ayahsCount: 75, revelationType: 'مكية'),
    MushafSurahMeta(number: 40, name: 'سُورَةُ غَافِرٍ', ayahsCount: 85, revelationType: 'مكية'),
    MushafSurahMeta(number: 41, name: 'سُورَةُ فُصِّلَتْ', ayahsCount: 54, revelationType: 'مكية'),
    MushafSurahMeta(number: 42, name: 'سُورَةُ الشُّورَىٰ', ayahsCount: 53, revelationType: 'مكية'),
    MushafSurahMeta(number: 43, name: 'سُورَةُ الزُّخْرُفِ', ayahsCount: 89, revelationType: 'مكية'),
    MushafSurahMeta(number: 44, name: 'سُورَةُ الدُّخَانِ', ayahsCount: 59, revelationType: 'مكية'),
    MushafSurahMeta(number: 45, name: 'سُورَةُ الجَاثِيَةِ', ayahsCount: 37, revelationType: 'مكية'),
    MushafSurahMeta(number: 46, name: 'سُورَةُ الأَحْقَافِ', ayahsCount: 35, revelationType: 'مكية'),
    MushafSurahMeta(number: 47, name: 'سُورَةُ مُحَمَّدٍ', ayahsCount: 38, revelationType: 'مدنية'),
    MushafSurahMeta(number: 48, name: 'سُورَةُ الفَتْحِ', ayahsCount: 29, revelationType: 'مدنية'),
    MushafSurahMeta(number: 49, name: 'سُورَةُ الحُجُرَاتِ', ayahsCount: 18, revelationType: 'مدنية'),
    MushafSurahMeta(number: 50, name: 'سُورَةُ قٓ', ayahsCount: 45, revelationType: 'مكية'),
    MushafSurahMeta(number: 51, name: 'سُورَةُ الذَّارِيَاتِ', ayahsCount: 60, revelationType: 'مكية'),
    MushafSurahMeta(number: 52, name: 'سُورَةُ الطُّورِ', ayahsCount: 49, revelationType: 'مكية'),
    MushafSurahMeta(number: 53, name: 'سُورَةُ النَّجْمِ', ayahsCount: 62, revelationType: 'مكية'),
    MushafSurahMeta(number: 54, name: 'سُورَةُ القَمَرِ', ayahsCount: 55, revelationType: 'مكية'),
    MushafSurahMeta(number: 55, name: 'سُورَةُ الرَّحْمَٰن', ayahsCount: 78, revelationType: 'مدنية'),
    MushafSurahMeta(number: 56, name: 'سُورَةُ الوَاقِعَةِ', ayahsCount: 96, revelationType: 'مكية'),
    MushafSurahMeta(number: 57, name: 'سُورَةُ الحَدِيدِ', ayahsCount: 29, revelationType: 'مدنية'),
    MushafSurahMeta(number: 58, name: 'سُورَةُ المُجَادِلَةِ', ayahsCount: 22, revelationType: 'مدنية'),
    MushafSurahMeta(number: 59, name: 'سُورَةُ الحَشْرِ', ayahsCount: 24, revelationType: 'مدنية'),
    MushafSurahMeta(number: 60, name: 'سُورَةُ المُمْتَحَنَةِ', ayahsCount: 13, revelationType: 'مدنية'),
    MushafSurahMeta(number: 61, name: 'سُورَةُ الصَّفِّ', ayahsCount: 14, revelationType: 'مدنية'),
    MushafSurahMeta(number: 62, name: 'سُورَةُ الجُمُعَةِ', ayahsCount: 11, revelationType: 'مدنية'),
    MushafSurahMeta(number: 63, name: 'سُورَةُ المُنَافِقُونَ', ayahsCount: 11, revelationType: 'مدنية'),
    MushafSurahMeta(number: 64, name: 'سُورَةُ التَّغَابُنِ', ayahsCount: 18, revelationType: 'مدنية'),
    MushafSurahMeta(number: 65, name: 'سُورَةُ الطَّلَاقِ', ayahsCount: 12, revelationType: 'مدنية'),
    MushafSurahMeta(number: 66, name: 'سُورَةُ التَّحْرِيمِ', ayahsCount: 12, revelationType: 'مدنية'),
    MushafSurahMeta(number: 67, name: 'سُورَةُ المُلْكِ', ayahsCount: 30, revelationType: 'مكية'),
    MushafSurahMeta(number: 68, name: 'سُورَةُ القَلَمِ', ayahsCount: 52, revelationType: 'مكية'),
    MushafSurahMeta(number: 69, name: 'سُورَةُ الحَاقَّةِ', ayahsCount: 52, revelationType: 'مكية'),
    MushafSurahMeta(number: 70, name: 'سُورَةُ المَعَارِجِ', ayahsCount: 44, revelationType: 'مكية'),
    MushafSurahMeta(number: 71, name: 'سُورَةُ نُوحٍ', ayahsCount: 28, revelationType: 'مكية'),
    MushafSurahMeta(number: 72, name: 'سُورَةُ الجِنِّ', ayahsCount: 28, revelationType: 'مكية'),
    MushafSurahMeta(number: 73, name: 'سُورَةُ المُزَّمِّلِ', ayahsCount: 20, revelationType: 'مكية'),
    MushafSurahMeta(number: 74, name: 'سُورَةُ المُدَّثِّرِ', ayahsCount: 56, revelationType: 'مكية'),
    MushafSurahMeta(number: 75, name: 'سُورَةُ القِيَامَةِ', ayahsCount: 40, revelationType: 'مكية'),
    MushafSurahMeta(number: 76, name: 'سُورَةُ الإِنْسَانِ', ayahsCount: 31, revelationType: 'مدنية'),
    MushafSurahMeta(number: 77, name: 'سُورَةُ المُرْسَلَاتِ', ayahsCount: 50, revelationType: 'مكية'),
    MushafSurahMeta(number: 78, name: 'سُورَةُ النَّبَإِ', ayahsCount: 40, revelationType: 'مكية'),
    MushafSurahMeta(number: 79, name: 'سُورَةُ النَّازِعَاتِ', ayahsCount: 46, revelationType: 'مكية'),
    MushafSurahMeta(number: 80, name: 'سُورَةُ عَبَسَ', ayahsCount: 42, revelationType: 'مكية'),
    MushafSurahMeta(number: 81, name: 'سُورَةُ التَّكْوِيرِ', ayahsCount: 29, revelationType: 'مكية'),
    MushafSurahMeta(number: 82, name: 'سُورَةُ الانْفِطَارِ', ayahsCount: 19, revelationType: 'مكية'),
    MushafSurahMeta(number: 83, name: 'سُورَةُ المُطَفِّفِينَ', ayahsCount: 36, revelationType: 'مكية'),
    MushafSurahMeta(number: 84, name: 'سُورَةُ الانْشِقَاقِ', ayahsCount: 25, revelationType: 'مكية'),
    MushafSurahMeta(number: 85, name: 'سُورَةُ البُرُوجِ', ayahsCount: 22, revelationType: 'مكية'),
    MushafSurahMeta(number: 86, name: 'سُورَةُ الطَّارِقِ', ayahsCount: 17, revelationType: 'مكية'),
    MushafSurahMeta(number: 87, name: 'سُورَةُ الأَعْلَىٰ', ayahsCount: 19, revelationType: 'مكية'),
    MushafSurahMeta(number: 88, name: 'سُورَةُ الغَاشِيَةِ', ayahsCount: 26, revelationType: 'مكية'),
    MushafSurahMeta(number: 89, name: 'سُورَةُ الفَجْرِ', ayahsCount: 30, revelationType: 'مكية'),
    MushafSurahMeta(number: 90, name: 'سُورَةُ البَلَدِ', ayahsCount: 20, revelationType: 'مكية'),
    MushafSurahMeta(number: 91, name: 'سُورَةُ الشَّمْسِ', ayahsCount: 15, revelationType: 'مكية'),
    MushafSurahMeta(number: 92, name: 'سُورَةُ اللَّيْلِ', ayahsCount: 21, revelationType: 'مكية'),
    MushafSurahMeta(number: 93, name: 'سُورَةُ الضُّحَىٰ', ayahsCount: 11, revelationType: 'مكية'),
    MushafSurahMeta(number: 94, name: 'سُورَةُ الشَّرْحِ', ayahsCount: 8, revelationType: 'مكية'),
    MushafSurahMeta(number: 95, name: 'سُورَةُ التِّينِ', ayahsCount: 8, revelationType: 'مكية'),
    MushafSurahMeta(number: 96, name: 'سُورَةُ العَلَقِ', ayahsCount: 19, revelationType: 'مكية'),
    MushafSurahMeta(number: 97, name: 'سُورَةُ القَدْرِ', ayahsCount: 5, revelationType: 'مكية'),
    MushafSurahMeta(number: 98, name: 'سُورَةُ البَيِّنَةِ', ayahsCount: 8, revelationType: 'مدنية'),
    MushafSurahMeta(number: 99, name: 'سُورَةُ الزَّلْزَلَةِ', ayahsCount: 8, revelationType: 'مدنية'),
    MushafSurahMeta(number: 100, name: 'سُورَةُ العَادِيَاتِ', ayahsCount: 11, revelationType: 'مكية'),
    MushafSurahMeta(number: 101, name: 'سُورَةُ القَارِعَةِ', ayahsCount: 11, revelationType: 'مكية'),
    MushafSurahMeta(number: 102, name: 'سُورَةُ التَّكَاثُرِ', ayahsCount: 8, revelationType: 'مكية'),
    MushafSurahMeta(number: 103, name: 'سُورَةُ العَصْرِ', ayahsCount: 3, revelationType: 'مكية'),
    MushafSurahMeta(number: 104, name: 'سُورَةُ الهُمَزَةِ', ayahsCount: 9, revelationType: 'مكية'),
    MushafSurahMeta(number: 105, name: 'سُورَةُ الفِيلِ', ayahsCount: 5, revelationType: 'مكية'),
    MushafSurahMeta(number: 106, name: 'سُورَةُ قُرَيْشٍ', ayahsCount: 4, revelationType: 'مكية'),
    MushafSurahMeta(number: 107, name: 'سُورَةُ المَاعُونِ', ayahsCount: 7, revelationType: 'مكية'),
    MushafSurahMeta(number: 108, name: 'سُورَةُ الكَوْثَرِ', ayahsCount: 3, revelationType: 'مكية'),
    MushafSurahMeta(number: 109, name: 'سُورَةُ الكَافِرُونَ', ayahsCount: 6, revelationType: 'مكية'),
    MushafSurahMeta(number: 110, name: 'سُورَةُ النَّصْرِ', ayahsCount: 3, revelationType: 'مدنية'),
    MushafSurahMeta(number: 111, name: 'سُورَةُ المَسَدِ', ayahsCount: 5, revelationType: 'مكية'),
    MushafSurahMeta(number: 112, name: 'سُورَةُ الإِخْلَاصِ', ayahsCount: 4, revelationType: 'مكية'),
    MushafSurahMeta(number: 113, name: 'سُورَةُ الفَلَقِ', ayahsCount: 5, revelationType: 'مكية'),
    MushafSurahMeta(number: 114, name: 'سُورَةُ النَّاسِ', ayahsCount: 6, revelationType: 'مكية'),
  ];

  Future<List<MushafSurahMeta>> getSurahsList() async {
    if (_memoryMetaCache != null) return _memoryMetaCache!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_surahsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List decoded = jsonDecode(raw);
        if (decoded.length == 114) {
          _memoryMetaCache = decoded
              .map((e) => MushafSurahMeta.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          return _memoryMetaCache!;
        }
      } catch (_) {}
    }
    _memoryMetaCache = allSurahsMeta;
    await prefs.setString(_surahsKey, jsonEncode(allSurahsMeta.map((e) => e.toJson()).toList()));
    return _memoryMetaCache!;
  }

  /// جلب آيات السورة كاملة بالرسم العثماني (من الكاش أو من الخادم وتخزينها محلياً)
  Future<List<Map<String, dynamic>>> getSurahAyahs(int surahNumber) async {
    if (_memorySurahCache.containsKey(surahNumber)) {
      return _memorySurahCache[surahNumber]!;
    }

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_surahPrefix$surahNumber');
    if (cached != null && cached.isNotEmpty) {
      try {
        final List decoded = jsonDecode(cached);
        final list = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        _memorySurahCache[surahNumber] = list;
        return list;
      } catch (_) {}
    }

    final response = await _dio.get('https://api.alquran.cloud/v1/surah/$surahNumber/quran-uthmani');
    if (response.statusCode == 200 && response.data != null) {
      final List rawAyahs = response.data['data']?['ayahs'] ?? [];
      final parsed = rawAyahs.map<Map<String, dynamic>>((a) => {
            'numberInSurah': a['numberInSurah'] ?? 1,
            'text': (a['text'] ?? '').toString(),
            'page': a['page'] ?? 1,
            'juz': a['juz'] ?? 1,
          }).toList();
      _memorySurahCache[surahNumber] = parsed;
      await prefs.setString('$_surahPrefix$surahNumber', jsonEncode(parsed));
      return parsed;
    }
    throw Exception('تعذر تحميل السورة من خادم المصحف');
  }

  /// جلب التفسير الميسر لسورة كاملة (مع حفظ تلقائي أوفلاين)
  Future<Map<int, String>> getSurahTafsir(int surahNumber) async {
    if (_memoryTafsirCache.containsKey(surahNumber)) {
      return _memoryTafsirCache[surahNumber]!;
    }

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_tafsirPrefix$surahNumber');
    if (cached != null && cached.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cached);
        final map = decoded.map((k, v) => MapEntry(int.tryParse(k) ?? 1, v.toString()));
        _memoryTafsirCache[surahNumber] = map;
        return map;
      } catch (_) {}
    }

    final response = await _dio.get('https://api.alquran.cloud/v1/surah/$surahNumber/ar.muyassar');
    if (response.statusCode == 200 && response.data != null) {
      final List rawAyahs = response.data['data']?['ayahs'] ?? [];
      final Map<int, String> parsed = {};
      for (final a in rawAyahs) {
        final int num = int.tryParse('${a['numberInSurah'] ?? 0}') ?? 0;
        if (num > 0) parsed[num] = (a['text'] ?? '').toString();
      }
      _memoryTafsirCache[surahNumber] = parsed;
      await prefs.setString(
        '$_tafsirPrefix$surahNumber',
        jsonEncode(parsed.map((k, v) => MapEntry('$k', v))),
      );
      return parsed;
    }
    throw Exception('تعذر تحميل التفسير الميسر للسورة');
  }
}
