class PosessionCategoryTranslations {
  static const Map<String, String> _urdu = {
    'All': 'تمام',
    'Armor': 'زرہ بکتر',
    'Swords': 'تلواریں',
    'Shields': 'ڈھالیں',
    'Bows': 'کمانیں',
    'Spears': 'نیزیں',
    'Food': 'کھانا',
    'Drinks': 'مشروبات',
    'Utensils': 'برتن',
    'Furniture': 'فرنیچر',
    'Bedding': 'بستر',
    'Clothing': 'لباس',
    'Headwear': 'سر کے کپڑے',
    'Footwear': 'جوتے',
    'Rings': 'انگشتر',
    'Perfumes': 'خوشبو',
    'Animals': 'جانور',
  };

  static Map<String, String> labelsFor(
      Iterable<String> englishNames, String languageCode) {
    if (languageCode != 'ur') {
      return {for (final name in englishNames) name: name};
    }
    return {for (final name in englishNames) name: _urdu[name] ?? name};
  }
}
