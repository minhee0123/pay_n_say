import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';
import 'package:pay_n_say/features/ledger/presentation/pages/day_detail_page.dart';

void main() {
  Widget buildTestWidget(DateTime date) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: DayDetailPage(date: date),
      ),
    );
  }

  group('DayDetailPage', () {
    testWidgets('앱바에 날짜와 요일 표시 (3월 11일 수요일)', (tester) async {
      final date = DateTime(2026, 3, 11); // 수요일
      await tester.pumpWidget(buildTestWidget(date));

      expect(find.text('3월 11일 (수)'), findsOneWidget);
    });

    testWidgets('내역이 있는 날 - 트랜잭션 카드 표시', (tester) async {
      // 3월 11일: 스타벅스, CGV (초기 데이터)
      final date = DateTime(2026, 3, 11);
      await tester.pumpWidget(buildTestWidget(date));

      expect(find.text('스타벅스'), findsOneWidget);
      expect(find.text('CGV'), findsOneWidget);
    });

    testWidgets('내역이 있는 날 - 건수 배지 표시', (tester) async {
      final date = DateTime(2026, 3, 11);
      await tester.pumpWidget(buildTestWidget(date));

      expect(find.text('2'), findsOneWidget); // 2건
      expect(find.text('내역'), findsOneWidget);
    });

    testWidgets('요약 카드에 수입/지출/잔액 표시', (tester) async {
      final date = DateTime(2026, 3, 11);
      await tester.pumpWidget(buildTestWidget(date));

      expect(find.text('수입'), findsOneWidget);
      expect(find.text('지출'), findsOneWidget);
      expect(find.text('잔액'), findsOneWidget);
    });

    testWidgets('내역 없는 날 - 빈 상태 메시지 표시', (tester) async {
      final date = DateTime(2026, 3, 20);
      await tester.pumpWidget(buildTestWidget(date));

      expect(find.text('이 날의 내역이 없어요'), findsOneWidget);
      expect(find.text('+ 버튼으로 내역을 추가해보세요'), findsOneWidget);
    });

    testWidgets('FAB 존재', (tester) async {
      final date = DateTime(2026, 3, 11);
      await tester.pumpWidget(buildTestWidget(date));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('트랜잭션 카드 롱프레스시 삭제 다이얼로그', (tester) async {
      final date = DateTime(2026, 3, 11);
      await tester.pumpWidget(buildTestWidget(date));

      await tester.longPress(find.text('스타벅스'));
      await tester.pumpAndSettle();

      expect(find.text('내역 삭제'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('삭제'), findsOneWidget);
    });

    testWidgets('삭제 다이얼로그 취소', (tester) async {
      final date = DateTime(2026, 3, 11);
      await tester.pumpWidget(buildTestWidget(date));

      await tester.longPress(find.text('스타벅스'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // 다이얼로그 닫힘, 내역 유지
      expect(find.text('스타벅스'), findsOneWidget);
    });

    testWidgets('삭제 확인 시 내역 제거', (tester) async {
      final date = DateTime(2026, 3, 11);
      await tester.pumpWidget(buildTestWidget(date));

      await tester.longPress(find.text('스타벅스'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();

      expect(find.text('스타벅스'), findsNothing);
      expect(find.text('CGV'), findsOneWidget);
    });
  });
}
