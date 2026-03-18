import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';
import 'package:pay_n_say/features/english_learning/presentation/providers/english_learning_provider.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;
  final List<QuizQuestion> _wrongAnswers = [];

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(quizQuestionsProvider);

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('퀴즈'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            '퀴즈를 생성할 수 없습니다.\n가계부에 내역을 추가해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    // 결과 화면
    if (_currentIndex >= questions.length) {
      return _ResultScreen(
        score: _score,
        total: questions.length,
        wrongAnswers: _wrongAnswers,
        onRetry: () => setState(() {
          _currentIndex = 0;
          _score = 0;
          _selectedAnswer = null;
          _answered = false;
          _wrongAnswers.clear();
          ref.invalidate(quizQuestionsProvider);
        }),
      );
    }

    final question = questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('퀴즈  ${_currentIndex + 1}/${questions.length}'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 진행률 바
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / questions.length,
                minHeight: 6,
                backgroundColor: AppColors.divider,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
            const SizedBox(height: 28),

            // 방향 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: question.isKoreanToEnglish
                    ? AppColors.accentLight
                    : AppColors.incomeLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                question.isKoreanToEnglish ? '한국어 → English' : 'English → 한국어',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: question.isKoreanToEnglish
                      ? AppColors.accent
                      : AppColors.income,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 문제 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Text(
                question.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 선택지
            ...question.options.map((option) {
              final isCorrect = option == question.correctAnswer;
              final isSelected = option == _selectedAnswer;

              Color bgColor = Colors.white;
              Color borderColor = AppColors.divider;
              Color textColor = AppColors.textPrimary;

              if (_answered) {
                if (isCorrect) {
                  bgColor = AppColors.incomeLight;
                  borderColor = AppColors.income;
                  textColor = AppColors.income;
                } else if (isSelected) {
                  bgColor = AppColors.expenseLight;
                  borderColor = AppColors.expense;
                  textColor = AppColors.expense;
                }
              } else if (isSelected) {
                bgColor = AppColors.accentLight;
                borderColor = AppColors.accent;
                textColor = AppColors.accent;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: _answered
                      ? null
                      : () {
                          setState(() {
                            _selectedAnswer = option;
                            _answered = true;
                            if (isCorrect) {
                              _score++;
                            } else {
                              _wrongAnswers.add(question);
                            }
                          });
                          // 단어장 진도 업데이트
                          _updateProgress(question, isCorrect);
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              );
            }),

            const Spacer(),

            // 다음 버튼
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex++;
                      _selectedAnswer = null;
                      _answered = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _currentIndex + 1 < questions.length ? '다음' : '결과 보기',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _updateProgress(QuizQuestion question, bool isCorrect) {
    // 단어장 기반 문제인 경우 진도 업데이트
    final words = ref.read(wordBankProvider);
    final matchingWord = words.where((w) {
      return w.korean == question.prompt || w.english == question.prompt;
    });
    if (matchingWord.isNotEmpty) {
      final notifier = ref.read(learningProgressProvider.notifier);
      if (isCorrect) {
        notifier.markCorrect(matchingWord.first.id);
      } else {
        notifier.markIncorrect(matchingWord.first.id);
      }
    }
  }
}

// ── 결과 화면 ───────────────────────────────────────────
class _ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final List<QuizQuestion> wrongAnswers;
  final VoidCallback onRetry;

  const _ResultScreen({
    required this.score,
    required this.total,
    required this.wrongAnswers,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (score / total * 100).round() : 0;
    final isPerfect = score == total;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('퀴즈 결과'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // 점수 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Text(
                    isPerfect ? '완벽해요!' : percentage >= 70 ? '잘했어요!' : '다시 도전!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isPerfect
                          ? AppColors.income
                          : percentage >= 70
                              ? AppColors.accent
                              : AppColors.expense,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$score / $total',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$percentage점',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 오답 리뷰
            if (wrongAnswers.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '틀린 문제',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...wrongAnswers.map((q) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.prompt,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.income, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                q.correctAnswer,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.income,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
            ],

            // 다시 하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  '다시 하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  '돌아가기',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
