import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';
import 'package:pay_n_say/features/english_learning/presentation/providers/english_learning_provider.dart';

class EnglishLearningPage extends ConsumerWidget {
  const EnglishLearningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learnedCount = ref.watch(learnedCountProvider);
    final totalWords = ref.watch(totalWordsProvider);
    final recentExpressions = ref.watch(recentEnglishExpressionsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('영어 학습'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 학습 진도 ──────────────────────────────
              _ProgressCard(
                learnedCount: learnedCount,
                totalWords: totalWords,
              ),
              const SizedBox(height: 20),

              // ── 오늘의 영어 표현 ──────────────────────
              if (recentExpressions.isNotEmpty) ...[
                _ExpressionsCard(expressions: recentExpressions),
                const SizedBox(height: 20),
              ],

              // ── 메뉴 ─────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _MenuCard(
                      icon: Icons.menu_book_rounded,
                      iconColor: AppColors.accent,
                      title: '단어장',
                      subtitle: '$totalWords개 표현',
                      onTap: () => context.push('/english/words'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MenuCard(
                      icon: Icons.quiz_rounded,
                      iconColor: AppColors.income,
                      title: '퀴즈',
                      subtitle: '실력 테스트',
                      onTap: () => context.push('/english/quiz'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 진도 카드 ───────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final int learnedCount;
  final int totalWords;

  const _ProgressCard({
    required this.learnedCount,
    required this.totalWords,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalWords > 0 ? learnedCount / totalWords : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_rounded, color: AppColors.accent, size: 22),
              const SizedBox(width: 8),
              const Text(
                '학습 진도',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$learnedCount',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 2),
                child: Text(
                  '/ $totalWords개',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 오늘의 영어 표현 카드 ───────────────────────────────
class _ExpressionsCard extends StatelessWidget {
  final List<TranslatedTransaction> expressions;

  const _ExpressionsCard({required this.expressions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              const Text(
                '최근 지출 영어 표현',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...expressions.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.transaction.title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      e.english,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── 메뉴 카드 ───────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
