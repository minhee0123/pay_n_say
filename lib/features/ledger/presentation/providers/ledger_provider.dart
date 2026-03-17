import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pay_n_say/features/ledger/domain/models/transaction.dart';

/// main.dart에서 Hive box를 열어 override로 주입
final hiveBoxProvider = Provider<Box>((ref) => throw UnimplementedError());

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final Box _box;

  TransactionsNotifier(this._box) : super(_loadOrSeed(_box));

  static List<Transaction> _loadOrSeed(Box box) {
    if (box.isNotEmpty) {
      return box.values
          .map((v) => Transaction.fromMap(v as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    // 첫 실행: 샘플 데이터 저장
    for (final t in _initialData) {
      box.put(t.id, t.toMap());
    }
    return List.of(_initialData);
  }

  void add(Transaction transaction) {
    _box.put(transaction.id, transaction.toMap());
    state = [transaction, ...state]
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void update(Transaction transaction) {
    _box.put(transaction.id, transaction.toMap());
    state = [
      for (final t in state)
        if (t.id == transaction.id) transaction else t,
    ]..sort((a, b) => b.date.compareTo(a.date));
  }

  void delete(String id) {
    _box.delete(id);
    state = state.where((t) => t.id != id).toList();
  }
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>(
  (ref) => TransactionsNotifier(ref.read(hiveBoxProvider)),
);

final transactionsForDayProvider =
    Provider.family<List<Transaction>, DateTime>((ref, day) {
  return ref.watch(transactionsProvider).where((t) {
    return t.date.year == day.year &&
        t.date.month == day.month &&
        t.date.day == day.day;
  }).toList();
});

final monthlyExpenseProvider =
    Provider.family<int, DateTime>((ref, month) {
  return ref.watch(transactionsProvider).where((t) {
    return t.date.year == month.year &&
        t.date.month == month.month &&
        t.type == TransactionType.expense;
  }).fold(0, (sum, t) => sum + t.amount);
});

final monthlyIncomeProvider =
    Provider.family<int, DateTime>((ref, month) {
  return ref.watch(transactionsProvider).where((t) {
    return t.date.year == month.year &&
        t.date.month == month.month &&
        t.type == TransactionType.income;
  }).fold(0, (sum, t) => sum + t.amount);
});

final _initialData = <Transaction>[
  Transaction(
    id: '0',
    title: '3월 급여',
    date: DateTime(2026, 3, 1),
    amount: 2500000,
    type: TransactionType.income,
    icon: Icons.account_balance_wallet,
    iconColor: Colors.blue,
  ),
  Transaction(
    id: '1',
    title: '스타벅스',
    date: DateTime(2026, 3, 11),
    amount: 6500,
    type: TransactionType.expense,
    icon: Icons.local_cafe,
    iconColor: Colors.brown,
  ),
  Transaction(
    id: '2',
    title: 'CGV',
    date: DateTime(2026, 3, 11),
    amount: 15000,
    type: TransactionType.expense,
    icon: Icons.movie,
    iconColor: Colors.red,
  ),
  Transaction(
    id: '3',
    title: '이마트',
    date: DateTime(2026, 3, 10),
    amount: 43200,
    type: TransactionType.expense,
    icon: Icons.shopping_cart,
    iconColor: Colors.blue,
  ),
  Transaction(
    id: '4',
    title: '버거킹',
    date: DateTime(2026, 3, 9),
    amount: 12900,
    type: TransactionType.expense,
    icon: Icons.fastfood,
    iconColor: Colors.orange,
  ),
  Transaction(
    id: '5',
    title: '올리브영',
    date: DateTime(2026, 3, 8),
    amount: 28500,
    type: TransactionType.expense,
    icon: Icons.spa,
    iconColor: Colors.green,
  ),
  Transaction(
    id: '6',
    title: '편의점 GS25',
    date: DateTime(2026, 3, 6),
    amount: 4300,
    type: TransactionType.expense,
    icon: Icons.store,
    iconColor: Colors.teal,
  ),
  Transaction(
    id: '7',
    title: '지하철',
    date: DateTime(2026, 3, 5),
    amount: 1400,
    type: TransactionType.expense,
    icon: Icons.subway,
    iconColor: Colors.indigo,
  ),
  Transaction(
    id: '8',
    title: '약국',
    date: DateTime(2026, 3, 4),
    amount: 9800,
    type: TransactionType.expense,
    icon: Icons.local_pharmacy,
    iconColor: Colors.pink,
  ),
];
