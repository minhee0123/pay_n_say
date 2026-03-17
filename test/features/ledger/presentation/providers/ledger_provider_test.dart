import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pay_n_say/features/ledger/domain/models/transaction.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';

void main() {
  late ProviderContainer container;
  late Box box;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox('transactions_test_${DateTime.now().millisecondsSinceEpoch}');
    container = ProviderContainer(
      overrides: [
        hiveBoxProvider.overrideWithValue(box),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await box.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Transaction _makeTx({
    String id = 'test-1',
    String title = '테스트',
    DateTime? date,
    int amount = 1000,
    TransactionType type = TransactionType.expense,
  }) {
    return Transaction(
      id: id,
      title: title,
      date: date ?? DateTime(2026, 3, 15),
      amount: amount,
      type: type,
      icon: Icons.receipt,
      iconColor: Colors.grey,
    );
  }

  group('TransactionsNotifier', () {
    test('초기 데이터 9건 로드', () {
      final transactions = container.read(transactionsProvider);
      expect(transactions.length, 9);
    });

    test('초기 데이터 존재 확인', () {
      final transactions = container.read(transactionsProvider);
      expect(transactions.any((t) => t.title == '3월 급여'), isTrue);
      expect(transactions.any((t) => t.title == '스타벅스'), isTrue);
    });

    test('초기 데이터가 Hive에 저장됨', () {
      container.read(transactionsProvider); // trigger init
      expect(box.isNotEmpty, isTrue);
      expect(box.length, 9);
    });

    test('add: 새 내역 추가', () {
      final notifier = container.read(transactionsProvider.notifier);
      final tx = _makeTx();

      notifier.add(tx);

      final transactions = container.read(transactionsProvider);
      expect(transactions.length, 10);
      expect(transactions.any((t) => t.id == 'test-1'), isTrue);
    });

    test('add: Hive에도 저장됨', () {
      final notifier = container.read(transactionsProvider.notifier);
      notifier.add(_makeTx());

      expect(box.get('test-1'), isNotNull);
    });

    test('add: 추가 후에도 날짜 내림차순 유지', () {
      final notifier = container.read(transactionsProvider.notifier);
      notifier.add(_makeTx(date: DateTime(2026, 3, 7)));

      final transactions = container.read(transactionsProvider);
      for (int i = 0; i < transactions.length - 1; i++) {
        expect(
          transactions[i].date.compareTo(transactions[i + 1].date),
          greaterThanOrEqualTo(0),
        );
      }
    });

    test('update: 기존 내역 수정', () {
      final notifier = container.read(transactionsProvider.notifier);
      final original = container.read(transactionsProvider).first;
      final updated = original.copyWith(title: '수정된 제목', amount: 99999);

      notifier.update(updated);

      final transactions = container.read(transactionsProvider);
      final found = transactions.firstWhere((t) => t.id == original.id);
      expect(found.title, '수정된 제목');
      expect(found.amount, 99999);
      expect(transactions.length, 9);
    });

    test('update: Hive에도 반영됨', () {
      final notifier = container.read(transactionsProvider.notifier);
      final original = container.read(transactionsProvider).first;
      notifier.update(original.copyWith(title: '변경'));

      final saved = box.get(original.id) as Map;
      expect(saved['title'], '변경');
    });

    test('delete: 내역 삭제', () {
      final notifier = container.read(transactionsProvider.notifier);
      final firstId = container.read(transactionsProvider).first.id;

      notifier.delete(firstId);

      final transactions = container.read(transactionsProvider);
      expect(transactions.length, 8);
      expect(transactions.any((t) => t.id == firstId), isFalse);
    });

    test('delete: Hive에서도 삭제됨', () {
      final notifier = container.read(transactionsProvider.notifier);
      final firstId = container.read(transactionsProvider).first.id;
      notifier.delete(firstId);

      expect(box.get(firstId), isNull);
    });

    test('delete: 존재하지 않는 id 삭제시 변화 없음', () {
      final notifier = container.read(transactionsProvider.notifier);
      notifier.delete('non-existent-id');

      expect(container.read(transactionsProvider).length, 9);
    });
  });

  group('transactionsForDayProvider', () {
    test('특정 날짜의 내역만 필터링', () {
      final day = DateTime(2026, 3, 11);
      final transactions = container.read(transactionsForDayProvider(day));
      // 3월 11일: 스타벅스, CGV
      expect(transactions.length, 2);
      expect(transactions.every((t) => t.date.day == 11), isTrue);
    });

    test('내역 없는 날짜는 빈 리스트', () {
      final day = DateTime(2026, 3, 20);
      final transactions = container.read(transactionsForDayProvider(day));
      expect(transactions, isEmpty);
    });
  });

  group('monthlyExpenseProvider', () {
    test('2026년 3월 지출 합계', () {
      final month = DateTime(2026, 3);
      final total = container.read(monthlyExpenseProvider(month));
      // 6500+15000+43200+12900+28500+4300+1400+9800 = 121600
      expect(total, 121600);
    });

    test('내역 없는 달은 0', () {
      final month = DateTime(2026, 12);
      expect(container.read(monthlyExpenseProvider(month)), 0);
    });
  });

  group('monthlyIncomeProvider', () {
    test('2026년 3월 수입 합계', () {
      final month = DateTime(2026, 3);
      final total = container.read(monthlyIncomeProvider(month));
      // 급여 2,500,000
      expect(total, 2500000);
    });

    test('내역 없는 달은 0', () {
      final month = DateTime(2026, 12);
      expect(container.read(monthlyIncomeProvider(month)), 0);
    });
  });

  group('프로바이더 연동', () {
    test('add 후 월간 합계 갱신', () {
      final notifier = container.read(transactionsProvider.notifier);
      final beforeExpense =
          container.read(monthlyExpenseProvider(DateTime(2026, 3)));

      notifier.add(_makeTx(amount: 5000));

      final afterExpense =
          container.read(monthlyExpenseProvider(DateTime(2026, 3)));
      expect(afterExpense, beforeExpense + 5000);
    });

    test('delete 후 일별 내역 갱신', () {
      final day11 = DateTime(2026, 3, 11);
      final before = container.read(transactionsForDayProvider(day11));
      expect(before.length, 2);

      final notifier = container.read(transactionsProvider.notifier);
      notifier.delete(before.first.id);

      final after = container.read(transactionsForDayProvider(day11));
      expect(after.length, 1);
    });
  });
}
