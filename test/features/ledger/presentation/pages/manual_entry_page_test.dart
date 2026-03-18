import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';
import 'package:pay_n_say/features/ledger/domain/models/transaction.dart';
import 'package:pay_n_say/features/ledger/presentation/pages/manual_entry_page.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';

import '../../../../helpers/fake_box.dart';

void main() {
  late FakeBox box;

  setUp(() {
    box = FakeBox();
  });

  Widget buildTestWidget({
    DateTime? initialDate,
    Transaction? editTransaction,
  }) {
    return ProviderScope(
      overrides: [
        hiveBoxProvider.overrideWithValue(box),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: ManualEntryPage(
          initialDate: initialDate,
          editTransaction: editTransaction,
        ),
      ),
    );
  }

  group('ManualEntryPage - 신규 등록 모드', () {
    testWidgets('앱바 제목이 "직접 입력"', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('직접 입력'), findsOneWidget);
    });

    testWidgets('지출/수입 토글 표시', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('지출'), findsOneWidget);
      expect(find.text('수입'), findsOneWidget);
    });

    testWidgets('필드 라벨 표시', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('상호명'), findsOneWidget);
      expect(find.text('카테고리'), findsOneWidget);
      expect(find.text('날짜'), findsOneWidget);
      expect(find.text('금액'), findsOneWidget);
    });

    testWidgets('저장 버튼 텍스트 - 지출', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('지출 저장하기'), findsOneWidget);
    });

    testWidgets('수입 탭 전환 시 버튼 텍스트 변경', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('수입'));
      await tester.pumpAndSettle();

      expect(find.text('수입 저장하기'), findsOneWidget);
    });

    testWidgets('상호명 빈칸 시 유효성 검사 에러', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 금액만 입력
      await tester.enterText(
        find.widgetWithText(TextFormField, '예) 12000'),
        '5000',
      );

      // 저장 버튼이 화면 밖일 수 있으므로 스크롤 후 탭
      await tester.ensureVisible(find.text('지출 저장하기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('지출 저장하기'));
      await tester.pumpAndSettle();

      expect(find.text('상호명을 입력해 주세요.'), findsOneWidget);
    });

    testWidgets('금액 빈칸 시 유효성 검사 에러', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 상호명만 입력
      await tester.enterText(
        find.widgetWithText(TextFormField, '예) 스타벅스'),
        '테스트 상점',
      );

      await tester.ensureVisible(find.text('지출 저장하기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('지출 저장하기'));
      await tester.pumpAndSettle();

      expect(find.text('금액을 입력해 주세요.'), findsOneWidget);
    });
  });

  group('ManualEntryPage - 수정 모드', () {
    final editTx = Transaction(
      id: 'edit-1',
      title: '스타벅스',
      date: DateTime(2026, 3, 10),
      amount: 6500,
      type: TransactionType.expense,
      icon: Icons.local_cafe,
      iconColor: Colors.brown,
    );

    testWidgets('앱바 제목이 "내역 수정"', (tester) async {
      await tester.pumpWidget(buildTestWidget(editTransaction: editTx));
      expect(find.text('내역 수정'), findsOneWidget);
    });

    testWidgets('기존 값이 폼에 채워짐', (tester) async {
      await tester.pumpWidget(buildTestWidget(editTransaction: editTx));

      // 상호명 필드에 기존 값
      expect(find.text('스타벅스'), findsOneWidget);
      // 금액 필드에 기존 값
      expect(find.text('6500'), findsOneWidget);
    });

    testWidgets('저장 버튼 텍스트가 "수정 완료"', (tester) async {
      await tester.pumpWidget(buildTestWidget(editTransaction: editTx));
      expect(find.text('수정 완료'), findsOneWidget);
    });
  });
}
