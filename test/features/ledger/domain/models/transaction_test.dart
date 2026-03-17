import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_n_say/features/ledger/domain/models/transaction.dart';

void main() {
  group('Transaction', () {
    final transaction = Transaction(
      id: '1',
      title: '스타벅스',
      date: DateTime(2026, 3, 11),
      amount: 6500,
      type: TransactionType.expense,
      icon: Icons.local_cafe,
      iconColor: Colors.brown,
    );

    test('기본 타입은 expense', () {
      final tx = Transaction(
        id: '1',
        title: '테스트',
        date: DateTime(2026, 1, 1),
        amount: 1000,
        icon: Icons.receipt,
        iconColor: Colors.grey,
      );
      expect(tx.type, TransactionType.expense);
    });

    test('formattedDate는 YYYY.MM.DD 형식', () {
      expect(transaction.formattedDate, '2026.03.11');
    });

    test('formattedDate 한 자리 월/일에 0 패딩', () {
      final tx = transaction.copyWith(date: DateTime(2026, 1, 5));
      expect(tx.formattedDate, '2026.01.05');
    });

    test('copyWith으로 필드 부분 변경', () {
      final updated = transaction.copyWith(
        title: '투썸플레이스',
        amount: 5000,
      );
      expect(updated.id, '1');
      expect(updated.title, '투썸플레이스');
      expect(updated.amount, 5000);
      expect(updated.date, transaction.date);
      expect(updated.type, TransactionType.expense);
      expect(updated.icon, Icons.local_cafe);
      expect(updated.iconColor, Colors.brown);
    });

    test('copyWith 인자 없으면 동일한 값 유지', () {
      final copy = transaction.copyWith();
      expect(copy.id, transaction.id);
      expect(copy.title, transaction.title);
      expect(copy.amount, transaction.amount);
      expect(copy.date, transaction.date);
      expect(copy.type, transaction.type);
    });

    test('copyWith으로 타입 변경', () {
      final updated = transaction.copyWith(type: TransactionType.income);
      expect(updated.type, TransactionType.income);
    });

    test('toMap 직렬화', () {
      final map = transaction.toMap();
      expect(map['id'], '1');
      expect(map['title'], '스타벅스');
      expect(map['amount'], 6500);
      expect(map['type'], TransactionType.expense.index);
      expect(map['date'], isA<int>());
      expect(map['iconCodePoint'], isA<int>());
      expect(map['iconColor'], isA<int>());
    });

    test('fromMap 역직렬화', () {
      final map = transaction.toMap();
      final restored = Transaction.fromMap(map);
      expect(restored.id, transaction.id);
      expect(restored.title, transaction.title);
      expect(restored.amount, transaction.amount);
      expect(restored.type, transaction.type);
      expect(restored.date, transaction.date);
      expect(restored.icon.codePoint, transaction.icon.codePoint);
      expect(restored.iconColor.value, transaction.iconColor.value);
    });

    test('toMap → fromMap 라운드트립', () {
      final income = Transaction(
        id: 'rt-1',
        title: '급여',
        date: DateTime(2026, 1, 15),
        amount: 3000000,
        type: TransactionType.income,
        icon: Icons.account_balance_wallet,
        iconColor: Colors.blue,
      );
      final restored = Transaction.fromMap(income.toMap());
      expect(restored.id, income.id);
      expect(restored.title, income.title);
      expect(restored.amount, income.amount);
      expect(restored.type, TransactionType.income);
    });
  });

  group('TransactionCategory', () {
    test('expenseCategories 9개', () {
      expect(expenseCategories.length, 9);
    });

    test('incomeCategories 4개', () {
      expect(incomeCategories.length, 4);
    });

    test('expenseCategories 첫번째는 식비', () {
      expect(expenseCategories.first.label, '식비');
    });

    test('incomeCategories 첫번째는 급여', () {
      expect(incomeCategories.first.label, '급여');
    });

    test('각 카테고리에 icon과 color 존재', () {
      for (final cat in [...expenseCategories, ...incomeCategories]) {
        expect(cat.label, isNotEmpty);
        expect(cat.icon, isNotNull);
        expect(cat.color, isNotNull);
      }
    });
  });
}