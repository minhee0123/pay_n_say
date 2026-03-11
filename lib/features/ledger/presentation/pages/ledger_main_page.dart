import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pay_n_say/features/ledger/domain/models/transaction.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';

class LedgerMainPage extends ConsumerStatefulWidget {
  const LedgerMainPage({super.key});

  @override
  ConsumerState<LedgerMainPage> createState() => _LedgerMainPageState();
}

class _LedgerMainPageState extends ConsumerState<LedgerMainPage> {
  DateTime _focusedDay = DateTime.now();

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.document_scanner_outlined),
                ),
                title: const Text('영수증 스캔',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('카메라 또는 갤러리로 영수증 인식'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/ocr');
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.edit_note),
                ),
                title: const Text('직접 입력',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('상호명, 금액 등을 직접 입력'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/add');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final monthlyExpense = ref.watch(monthlyExpenseProvider(_focusedDay));
    final monthlyIncome = ref.watch(monthlyIncomeProvider(_focusedDay));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('가계부'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          _MonthlySummaryCard(
            month: _focusedDay,
            income: monthlyIncome,
            expense: monthlyExpense,
          ),
          Expanded(
            child: TableCalendar<Transaction>(
              firstDay: DateTime(2024, 1, 1),
              lastDay: DateTime(2027, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              rowHeight: 64,
              eventLoader: (day) => transactions.where((t) =>
                  t.date.year == day.year &&
                  t.date.month == day.month &&
                  t.date.day == day.day).toList(),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() => _focusedDay = focusedDay);
                context.push('/day/${_fmtDate(selectedDay)}');
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                    color: colorScheme.onSurface, fontSize: 12),
                weekendStyle:
                    TextStyle(color: colorScheme.error, fontSize: 12),
              ),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                markerSize: 0,
              ),
              calendarBuilders: CalendarBuilders<Transaction>(
                defaultBuilder: (context, day, focusedDay) {
                  final evts = transactions.where((t) =>
                      t.date.year == day.year &&
                      t.date.month == day.month &&
                      t.date.day == day.day).toList();
                  return _DayCell(day: day, events: evts);
                },
                todayBuilder: (context, day, focusedDay) {
                  final evts = transactions.where((t) =>
                      t.date.year == day.year &&
                      t.date.month == day.month &&
                      t.date.day == day.day).toList();
                  return _DayCell(day: day, events: evts, isToday: true);
                },
                dowBuilder: (context, day) {
                  final text = ['월', '화', '수', '목', '금', '토', '일'];
                  final idx = (day.weekday - 1) % 7;
                  final isWeekend = day.weekday == 6 || day.weekday == 7;
                  return Center(
                    child: Text(
                      text[idx],
                      style: TextStyle(
                        fontSize: 12,
                        color: isWeekend
                            ? colorScheme.error
                            : colorScheme.onSurface,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        tooltip: '내역 추가',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Monthly Summary Card ────────────────────────────────────────────────────

class _MonthlySummaryCard extends StatelessWidget {
  final DateTime month;
  final int income;
  final int expense;

  const _MonthlySummaryCard({
    required this.month,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final balance = income - expense;

    return Container(
      color: colorScheme.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
              label: '수입', amount: income, color: Colors.greenAccent[100]!),
          _Divider(),
          _SummaryItem(
              label: '지출',
              amount: expense,
              color: Colors.red[100]!,
              prefix: '-'),
          _Divider(),
          _SummaryItem(
              label: '잔액',
              amount: balance,
              color: colorScheme.onPrimary,
              prefix: balance >= 0 ? '+' : ''),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final String prefix;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7))),
        const SizedBox(height: 2),
        Text(
          '$prefix${_fmt(amount.abs())}원',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1,
      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
    );
  }
}

// ─── Calendar Day Cell ───────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime day;
  final List<Transaction> events;
  final bool isToday;

  const _DayCell({
    required this.day,
    required this.events,
    this.isToday = false,
  });

  String _compact(int amount) {
    if (amount >= 10000) {
      final man = amount / 10000;
      return man == man.roundToDouble()
          ? '${man.round()}만'
          : '${man.toStringAsFixed(1)}만';
    }
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final expense = events
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (s, t) => s + t.amount);
    final income = events
        .where((t) => t.type == TransactionType.income)
        .fold(0, (s, t) => s + t.amount);
    final isWeekend = day.weekday == 6 || day.weekday == 7;

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: isToday
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 1.5),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday
                  ? colorScheme.primary
                  : isWeekend
                      ? colorScheme.error
                      : colorScheme.onSurface,
            ),
          ),
          if (expense > 0)
            Text(
              '-${_compact(expense)}',
              style: const TextStyle(
                  fontSize: 8.5, color: Colors.redAccent, height: 1.3),
            ),
          if (income > 0)
            Text(
              '+${_compact(income)}',
              style: TextStyle(
                  fontSize: 8.5, color: Colors.green[700], height: 1.3),
            ),
        ],
      ),
    );
  }
}
