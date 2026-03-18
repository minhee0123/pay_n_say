import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pay_n_say/features/english_learning/domain/data/transaction_translator.dart';
import 'package:pay_n_say/features/english_learning/domain/data/word_bank.dart';
import 'package:pay_n_say/features/english_learning/domain/models/english_word.dart';
import 'package:pay_n_say/features/english_learning/domain/models/learning_progress.dart';
import 'package:pay_n_say/features/ledger/domain/models/transaction.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';

// ── Hive box (main.dart에서 override) ─────────────────────
final learningBoxProvider = Provider<Box>((ref) => throw UnimplementedError());

// ── 단어 뱅크 ────────────────────────────────────────────
final wordBankProvider = Provider<List<EnglishWord>>((ref) => wordBank);

final wordsByCategoryProvider =
    Provider.family<List<EnglishWord>, WordCategory?>((ref, category) {
  final words = ref.watch(wordBankProvider);
  if (category == null) return words;
  return words.where((w) => w.category == category).toList();
});

// ── 학습 진도 관리 ────────────────────────────────────────
class LearningProgressNotifier
    extends StateNotifier<Map<String, LearningProgress>> {
  final Box _box;

  LearningProgressNotifier(this._box) : super(_load(_box));

  static Map<String, LearningProgress> _load(Box box) {
    final map = <String, LearningProgress>{};
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        map[key as String] = LearningProgress.fromMap(raw);
      }
    }
    return map;
  }

  void markCorrect(String wordId) {
    final prev = state[wordId];
    final updated = (prev ?? LearningProgress(
      wordId: wordId,
      lastStudied: DateTime.now(),
    )).copyWith(
      correctCount: (prev?.correctCount ?? 0) + 1,
      totalAttempts: (prev?.totalAttempts ?? 0) + 1,
      lastStudied: DateTime.now(),
    );
    _box.put(wordId, updated.toMap());
    state = {...state, wordId: updated};
  }

  void markIncorrect(String wordId) {
    final prev = state[wordId];
    final updated = (prev ?? LearningProgress(
      wordId: wordId,
      lastStudied: DateTime.now(),
    )).copyWith(
      totalAttempts: (prev?.totalAttempts ?? 0) + 1,
      lastStudied: DateTime.now(),
    );
    _box.put(wordId, updated.toMap());
    state = {...state, wordId: updated};
  }

  void toggleBookmark(String wordId) {
    final prev = state[wordId];
    final updated = (prev ?? LearningProgress(
      wordId: wordId,
      lastStudied: DateTime.now(),
    )).copyWith(
      isBookmarked: !(prev?.isBookmarked ?? false),
    );
    _box.put(wordId, updated.toMap());
    state = {...state, wordId: updated};
  }
}

final learningProgressProvider = StateNotifierProvider<
    LearningProgressNotifier, Map<String, LearningProgress>>(
  (ref) => LearningProgressNotifier(ref.read(learningBoxProvider)),
);

// ── 파생 프로바이더 ───────────────────────────────────────
final learnedCountProvider = Provider<int>((ref) {
  return ref
      .watch(learningProgressProvider)
      .values
      .where((p) => p.isLearned)
      .length;
});

final totalWordsProvider = Provider<int>((ref) {
  return ref.watch(wordBankProvider).length;
});

// ── 가계부 연동: 최근 거래 영어 표현 ─────────────────────
class TranslatedTransaction {
  final Transaction transaction;
  final String english;
  final String korean;

  const TranslatedTransaction({
    required this.transaction,
    required this.english,
    required this.korean,
  });
}

final recentEnglishExpressionsProvider =
    Provider<List<TranslatedTransaction>>((ref) {
  final all = ref.watch(transactionsProvider);
  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  return all
      .where((t) => t.date.isAfter(cutoff))
      .take(5)
      .map((t) => TranslatedTransaction(
            transaction: t,
            english: TransactionTranslator.translate(t),
            korean: TransactionTranslator.translateKorean(t),
          ))
      .toList();
});

// ── 퀴즈 ─────────────────────────────────────────────────
class QuizQuestion {
  final String prompt;
  final String correctAnswer;
  final List<String> options;
  final bool isKoreanToEnglish;

  const QuizQuestion({
    required this.prompt,
    required this.correctAnswer,
    required this.options,
    required this.isKoreanToEnglish,
  });
}

final quizQuestionsProvider = Provider<List<QuizQuestion>>((ref) {
  final words = ref.watch(wordBankProvider);
  final transactions = ref.watch(transactionsProvider);
  final rng = Random();

  final questions = <QuizQuestion>[];

  // 단어장 기반 문제
  final shuffledWords = List.of(words)..shuffle(rng);
  for (final word in shuffledWords.take(7)) {
    final isK2E = rng.nextBool();
    final prompt = isK2E ? word.korean : word.english;
    final correct = isK2E ? word.english : word.korean;

    final otherWords = words.where((w) => w.id != word.id).toList()
      ..shuffle(rng);
    final wrongAnswers = otherWords
        .take(3)
        .map((w) => isK2E ? w.english : w.korean)
        .toList();

    final options = [correct, ...wrongAnswers]..shuffle(rng);
    questions.add(QuizQuestion(
      prompt: prompt,
      correctAnswer: correct,
      options: options,
      isKoreanToEnglish: isK2E,
    ));
  }

  // 거래 기반 문제 (최대 3개)
  final shuffledTx = List.of(transactions)..shuffle(rng);
  for (final tx in shuffledTx.take(3)) {
    final english = TransactionTranslator.translate(tx);
    final korean = TransactionTranslator.translateKorean(tx);
    final isK2E = rng.nextBool();
    final prompt = isK2E ? korean : english;
    final correct = isK2E ? english : korean;

    // 다른 거래들로 오답 생성
    final otherTx = transactions.where((t) => t.id != tx.id).toList()
      ..shuffle(rng);
    final wrongAnswers = otherTx.take(3).map((t) {
      return isK2E
          ? TransactionTranslator.translate(t)
          : TransactionTranslator.translateKorean(t);
    }).toList();

    // 오답이 3개 미만이면 스킵
    if (wrongAnswers.length < 3) continue;

    final options = [correct, ...wrongAnswers]..shuffle(rng);
    questions.add(QuizQuestion(
      prompt: prompt,
      correctAnswer: correct,
      options: options,
      isKoreanToEnglish: isK2E,
    ));
  }

  questions.shuffle(rng);
  return questions.take(10).toList();
});
