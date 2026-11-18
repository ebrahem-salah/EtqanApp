class CountryCodeItem {
  final String nameAr;
  final String nameEn;
  final String dialCode;
  final String code; // ISO-2
  final String flag;
  final int minLength;
  final int maxLength;
  final String example;

  const CountryCodeItem({
    required this.nameAr,
    required this.nameEn,
    required this.dialCode,
    required this.code,
    required this.flag,
    this.minLength = 9,
    this.maxLength = 10,
    required this.example,
  });
}

class CountryCodes {
  static const List<CountryCodeItem> all = [
    // الدول العربية
    CountryCodeItem(nameAr: 'المملكة العربية السعودية', nameEn: 'Saudi Arabia', dialCode: '+966', code: 'SA', flag: '🇸🇦', minLength: 9, maxLength: 9, example: '5X XXX XXXX'),
    CountryCodeItem(nameAr: 'جمهورية مصر العربية', nameEn: 'Egypt', dialCode: '+20', code: 'EG', flag: '🇪🇬', minLength: 10, maxLength: 10, example: '10X XXX XXXX'),
    CountryCodeItem(nameAr: 'الإمارات العربية المتحدة', nameEn: 'United Arab Emirates', dialCode: '+971', code: 'AE', flag: '🇦🇪', minLength: 9, maxLength: 9, example: '5X XXX XXXX'),
    CountryCodeItem(nameAr: 'دولة الكويت', nameEn: 'Kuwait', dialCode: '+965', code: 'KW', flag: '🇰🇼', minLength: 8, maxLength: 8, example: '9X XXX XXX'),
    CountryCodeItem(nameAr: 'دولة قطر', nameEn: 'Qatar', dialCode: '+974', code: 'QA', flag: '🇶🇦', minLength: 8, maxLength: 8, example: '5X XXX XXX'),
    CountryCodeItem(nameAr: 'مملكة البحرين', nameEn: 'Bahrain', dialCode: '+973', code: 'BH', flag: '🇧🇭', minLength: 8, maxLength: 8, example: '3X XXX XXX'),
    CountryCodeItem(nameAr: 'سلطنة عُمان', nameEn: 'Oman', dialCode: '+968', code: 'OM', flag: '🇴🇲', minLength: 8, maxLength: 8, example: '9X XXX XXX'),
    CountryCodeItem(nameAr: 'المملكة الأردنية الهاشمية', nameEn: 'Jordan', dialCode: '+962', code: 'JO', flag: '🇯🇴', minLength: 9, maxLength: 9, example: '7X XXX XXXX'),
    CountryCodeItem(nameAr: 'دولة فلسطين', nameEn: 'Palestine', dialCode: '+970', code: 'PS', flag: '🇵🇸', minLength: 9, maxLength: 9, example: '5X XXX XXXX'),
    CountryCodeItem(nameAr: 'المملكة المغربية', nameEn: 'Morocco', dialCode: '+212', code: 'MA', flag: '🇲🇦', minLength: 9, maxLength: 9, example: '6X XXX XXXX'),
    CountryCodeItem(nameAr: 'الجمهورية الجزائرية', nameEn: 'Algeria', dialCode: '+213', code: 'DZ', flag: '🇩🇿', minLength: 9, maxLength: 9, example: '5X XXX XXXX'),
    CountryCodeItem(nameAr: 'الجمهورية التونسية', nameEn: 'Tunisia', dialCode: '+216', code: 'TN', flag: '🇹🇳', minLength: 8, maxLength: 8, example: '9X XXX XXX'),
    CountryCodeItem(nameAr: 'دولة ليبيا', nameEn: 'Libya', dialCode: '+218', code: 'LY', flag: '🇱🇾', minLength: 9, maxLength: 9, example: '9X XXX XXXX'),
    CountryCodeItem(nameAr: 'جمهورية السودان', nameEn: 'Sudan', dialCode: '+249', code: 'SD', flag: '🇸🇩', minLength: 9, maxLength: 9, example: '9X XXX XXXX'),
    CountryCodeItem(nameAr: 'الجمهورية اليمنية', nameEn: 'Yemen', dialCode: '+967', code: 'YE', flag: '🇾🇪', minLength: 9, maxLength: 9, example: '7X XXX XXXX'),
    CountryCodeItem(nameAr: 'جمهورية العراق', nameEn: 'Iraq', dialCode: '+964', code: 'IQ', flag: '🇮🇶', minLength: 10, maxLength: 10, example: '7X XXXX XXXX'),
    CountryCodeItem(nameAr: 'الجمهورية العربية السورية', nameEn: 'Syria', dialCode: '+963', code: 'SY', flag: '🇸🇾', minLength: 9, maxLength: 9, example: '9X XXX XXXX'),
    CountryCodeItem(nameAr: 'الجمهورية اللبنانية', nameEn: 'Lebanon', dialCode: '+961', code: 'LB', flag: '🇱🇧', minLength: 8, maxLength: 8, example: '7X XXX XXX'),
    CountryCodeItem(nameAr: 'الصومال', nameEn: 'Somalia', dialCode: '+252', code: 'SO', flag: '🇸🇴', minLength: 8, maxLength: 9, example: '6X XXX XXX'),
    CountryCodeItem(nameAr: 'موريتانيا', nameEn: 'Mauritania', dialCode: '+222', code: 'MR', flag: '🇲🇷', minLength: 8, maxLength: 8, example: '4X XXX XXX'),

    // دول إسلامية وعالمية كبرى
    CountryCodeItem(nameAr: 'تركيا', nameEn: 'Turkey', dialCode: '+90', code: 'TR', flag: '🇹🇷', minLength: 10, maxLength: 10, example: '5XX XXX XXXX'),
    CountryCodeItem(nameAr: 'ماليزيا', nameEn: 'Malaysia', dialCode: '+60', code: 'MY', flag: '🇲🇾', minLength: 9, maxLength: 10, example: '1X XXX XXXX'),
    CountryCodeItem(nameAr: 'إندونيسيا', nameEn: 'Indonesia', dialCode: '+62', code: 'ID', flag: '🇮🇩', minLength: 9, maxLength: 12, example: '8XX XXXX XXXX'),
    CountryCodeItem(nameAr: 'باكستان', nameEn: 'Pakistan', dialCode: '+92', code: 'PK', flag: '🇵🇰', minLength: 10, maxLength: 10, example: '3XX XXXXXXX'),
    CountryCodeItem(nameAr: 'المملكة المتحدة', nameEn: 'United Kingdom', dialCode: '+44', code: 'GB', flag: '🇬🇧', minLength: 10, maxLength: 10, example: '7XXX XXXXXX'),
    CountryCodeItem(nameAr: 'الولايات المتحدة الأمريكية', nameEn: 'United States', dialCode: '+1', code: 'US', flag: '🇺🇸', minLength: 10, maxLength: 10, example: 'XXX XXX XXXX'),
    CountryCodeItem(nameAr: 'كندا', nameEn: 'Canada', dialCode: '+1', code: 'CA', flag: '🇨🇦', minLength: 10, maxLength: 10, example: 'XXX XXX XXXX'),
    CountryCodeItem(nameAr: 'ألمانيا', nameEn: 'Germany', dialCode: '+49', code: 'DE', flag: '🇩🇪', minLength: 10, maxLength: 11, example: '1XX XXXXXXXX'),
    CountryCodeItem(nameAr: 'فرنسا', nameEn: 'France', dialCode: '+33', code: 'FR', flag: '🇫🇷', minLength: 9, maxLength: 9, example: '6 XX XX XX XX'),
  ];

  /// البحث الذكي بالاسم العربي، الإنجليزي، أو كود الاتصال الدولي
  static List<CountryCodeItem> search(String query) {
    if (query.trim().isEmpty) return all;
    final cleanQuery = query.trim().toLowerCase().replaceAll('+', '');
    return all.where((c) {
      final matchAr = c.nameAr.toLowerCase().contains(cleanQuery);
      final matchEn = c.nameEn.toLowerCase().contains(cleanQuery);
      final matchDial = c.dialCode.replaceAll('+', '').contains(cleanQuery);
      final matchCode = c.code.toLowerCase().contains(cleanQuery);
      return matchAr || matchEn || matchDial || matchCode;
    }).toList();
  }

  static CountryCodeItem get defaultCountry => all.first; // السعودية (+966)
}
