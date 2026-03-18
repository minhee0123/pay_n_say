enum WordCategory {
  food,
  cafe,
  shopping,
  beauty,
  culture,
  transport,
  medical,
  finance,
  income,
}

extension WordCategoryLabel on WordCategory {
  String get label {
    switch (this) {
      case WordCategory.food:
        return '식비';
      case WordCategory.cafe:
        return '카페';
      case WordCategory.shopping:
        return '쇼핑';
      case WordCategory.beauty:
        return '뷰티';
      case WordCategory.culture:
        return '문화';
      case WordCategory.transport:
        return '교통';
      case WordCategory.medical:
        return '의료';
      case WordCategory.finance:
        return '금융';
      case WordCategory.income:
        return '수입';
    }
  }
}

class EnglishWord {
  final String id;
  final String english;
  final String korean;
  final String exampleEn;
  final String exampleKo;
  final WordCategory category;

  const EnglishWord({
    required this.id,
    required this.english,
    required this.korean,
    required this.exampleEn,
    required this.exampleKo,
    required this.category,
  });
}
