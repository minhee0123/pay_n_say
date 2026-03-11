import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_n_say/features/ledger/domain/models/transaction.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';

class DayDetailPage extends ConsumerWidget {
  final DateTime date;

  const DayDetailPage({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsForDayProvider(date));
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (s, t) => s + t.amount);
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (s, t) => s + t.amount);
    final colorScheme = Theme.of(context).colorScheme;

    final title =
        '${date.year}년 ${date.month}월 ${date.day}일';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          _DaySummaryCard(income: income, expense: expense),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('내역',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 56,
                            color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('내역이 없습니다',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return _TransactionTile(
                          transaction: transactions[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add', extra: date),
        tooltip: '내역 추가',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Day Summary Card ────────────────────────────────────────────────────────

class _DaySummaryCard extends StatelessWidget {
  final int income;
  final int expense;

  const _DaySummaryCard({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: colorScheme.surfaceVariant,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Item(label: '수입', amount: income, color: Colors.green[700]!),
              Container(height: 32, width: 1, color: Colors.grey[300]),
              _Item(
                  label: '지출',
                  amount: expense,
                  color: Colors.redAccent,
                  prefix: '-'),
              Container(height: 32, width: 1, color: Colors.grey[300]),
              _Item(
                label: '합계',
                amount: (income - expense).abs(),
                color: colorScheme.onSurfaceVariant,
                prefix: income >= expense ? '+' : '-',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final String prefix;

  const _Item({
    required this.label,
    required this.amount,
    required this.color,
    this.prefix = '',
  });

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text('$prefix${_fmt(amount)}원',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}

// ─── Transaction Tile ────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: transaction.iconColor.withOpacity(0.15),
        child: Icon(transaction.icon,
            color: transaction.iconColor, size: 22),
      ),
      title: Text(transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(transaction.formattedDate,
          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Text(
        '${isExpense ? '-' : '+'}${_fmt(transaction.amount)}원',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isExpense ? Colors.redAccent : Colors.green[700],
        ),
      ),
    );
  }
}
