import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/country_codes.dart';

/// نافذة منبثقة لاختيار مفتاح الدولة مع البحث السريع
class CountryPickerBottomSheet extends StatefulWidget {
  final ValueChanged<CountryCodeItem> onSelect;
  final CountryCodeItem? initialSelection;

  const CountryPickerBottomSheet({
    super.key,
    required this.onSelect,
    this.initialSelection,
  });

  static Future<CountryCodeItem?> show(BuildContext context, {CountryCodeItem? initial}) {
    return showModalBottomSheet<CountryCodeItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CountryPickerBottomSheet(
        initialSelection: initial,
        onSelect: (c) => Navigator.of(ctx).pop(c),
      ),
    );
  }

  @override
  State<CountryPickerBottomSheet> createState() => _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<CountryPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryCodeItem> _filteredCountries = CountryCodes.all;

  void _onSearch(String query) {
    setState(() {
      _filteredCountries = CountryCodes.search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'اختر رمز الدولة',
                  style: TextStyle(
                    fontFamily: 'Dubai',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2822),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'ابحث باسم الدولة أو رمز الاتصال (مصر، 966، 20...)',
                hintStyle: TextStyle(fontFamily: 'Dubai', fontSize: 13, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF9F9F4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Countries List
          Expanded(
            child: _filteredCountries.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد نتائج مطابقة للبحث',
                      style: TextStyle(fontFamily: 'Dubai', color: Colors.grey.shade600),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredCountries.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF0F0E5)),
                    itemBuilder: (context, index) {
                      final item = _filteredCountries[index];
                      final isSelected = widget.initialSelection?.code == item.code;

                      return ListTile(
                        onTap: () => widget.onSelect(item),
                        leading: Text(item.flag, style: const TextStyle(fontSize: 26)),
                        title: Text(
                          item.nameAr,
                          style: TextStyle(
                            fontFamily: 'Dubai',
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primary : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          item.nameEn,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF0F0E5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.dialCode,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.primary : Colors.black87,
                              fontSize: 13,
                              fontFamily: 'Dubai',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
