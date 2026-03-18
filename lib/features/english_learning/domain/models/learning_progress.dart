class LearningProgress {
  final String wordId;
  final int correctCount;
  final int totalAttempts;
  final DateTime lastStudied;
  final bool isBookmarked;

  const LearningProgress({
    required this.wordId,
    this.correctCount = 0,
    this.totalAttempts = 0,
    required this.lastStudied,
    this.isBookmarked = false,
  });

  bool get isLearned => correctCount >= 3;

  LearningProgress copyWith({
    String? wordId,
    int? correctCount,
    int? totalAttempts,
    DateTime? lastStudied,
    bool? isBookmarked,
  }) {
    return LearningProgress(
      wordId: wordId ?? this.wordId,
      correctCount: correctCount ?? this.correctCount,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      lastStudied: lastStudied ?? this.lastStudied,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wordId': wordId,
      'correctCount': correctCount,
      'totalAttempts': totalAttempts,
      'lastStudied': lastStudied.toIso8601String(),
      'isBookmarked': isBookmarked,
    };
  }

  factory LearningProgress.fromMap(Map<dynamic, dynamic> map) {
    return LearningProgress(
      wordId: map['wordId'] as String,
      correctCount: map['correctCount'] as int? ?? 0,
      totalAttempts: map['totalAttempts'] as int? ?? 0,
      lastStudied: DateTime.parse(map['lastStudied'] as String),
      isBookmarked: map['isBookmarked'] as bool? ?? false,
    );
  }
}
