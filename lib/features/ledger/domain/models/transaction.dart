import 'package:flutter/material.dart';

enum TransactionType { expense, income }

class Transaction {
  final String id;
  final String title;
  final DateTime date;
  final int amount;
  final TransactionType type;
  final IconData icon;
  final Color iconColor;

  const Transaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    this.type = TransactionType.expense,
    required this.icon,
    required this.iconColor,
  });

  String get formattedDate =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  Transaction copyWith({
    String? id,
    String? title,
    DateTime? date,
    int? amount,
    TransactionType? type,
    IconData? icon,
    Color? iconColor,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}

class TransactionCategory {
  final String label;
  final IconData icon;
  final Color color;

  const TransactionCategory({
    required this.label,
    required this.icon,
    required this.color,
  });
}

const expenseCategories = <TransactionCategory>[
  TransactionCategory(label: '식비', icon: Icons.fastfood, color: Colors.orange),
  TransactionCategory(label: '카페', icon: Icons.local_cafe, color: Colors.brown),
  TransactionCategory(label: '쇼핑', icon: Icons.shopping_cart, color: Colors.blue),
  TransactionCategory(label: '뷰티', icon: Icons.spa, color: Colors.green),
  TransactionCategory(label: '문화', icon: Icons.movie, color: Colors.red),
  TransactionCategory(label: '편의점', icon: Icons.store, color: Colors.teal),
  TransactionCategory(label: '교통', icon: Icons.subway, color: Colors.indigo),
  TransactionCategory(label: '의료', icon: Icons.local_pharmacy, color: Colors.pink),
  TransactionCategory(label: '기타', icon: Icons.receipt_long, color: Colors.grey),
];

const incomeCategories = <TransactionCategory>[
  TransactionCategory(label: '급여', icon: Icons.account_balance_wallet, color: Colors.blue),
  TransactionCategory(label: '용돈', icon: Icons.savings, color: Colors.green),
  TransactionCategory(label: '부업', icon: Icons.work, color: Colors.purple),
  TransactionCategory(label: '기타 수입', icon: Icons.add_circle_outline, color: Colors.teal),
];
