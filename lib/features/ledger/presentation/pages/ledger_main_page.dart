import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';
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

  List<Transaction> _eventsFor(DateTime day, List<Transaction> all) =>
      all.where((t) =>
          t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day).toList();

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('내역 추가',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 16),
              _SheetOption(
                icon: Icons.document_scanner_outlined,
                iconBg: AppColors.accentLight,
                iconColor: AppColors.accent,
                title: '영수증 스캔',
                subtitle: '카메라 또는 갤러리로 인식',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/ocr');
                },
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon: Icons.edit_note_rounded,
                iconBg: AppColors.incomeLight,
                iconColor: AppColors.income,
                title: '직접 입력',
                subtitle: '상호명, 금액 등을 직접 입력',
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
        children: [
          // ── 그라데이션 헤더 ──────────────────────────────────
          _SummaryHeader(
            focusedDay: _focusedDay,
            income: monthlyIncome,
            expense: monthlyExpense,
          ),
          const SizedBox(height: 12),
          // ── 캘린더 카드 ─────────────────────────────────────
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: TableCalendar<Transaction>(
                    firstDay: DateTime(2024, 1, 1),
                    lastDay: DateTime(2027, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    rowHeight: 58,
                    eventLoader: (day) => _eventsFor(day, transactions),
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
                      titleTextStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left_rounded,
                          color: AppColors.textSecondary),
                      rightChevronIcon: Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary),
                      headerPadding:
                          EdgeInsets.symmetric(vertical: 10),
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      markerSize: 0,
                    ),
                    calendarBuilders: CalendarBuilders<Transaction>(
                      dowBuilder: (context, day) {
                        const labels = [
                          '월', '화', '수', '목', '금', '토', '일'
                        ];
                        final idx = (day.weekday - 1) % 7;
                        final isWeekend =
                            day.weekday == 6 || day.weekday == 7;
                        return Center(
                          child: Text(
                            labels[idx],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isWeekend
                                  ? AppColors.expense.withOpacity(0.7)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                      defaultBuilder: (context, day, _) => _DayCell(
                          day: day,
                          events: _eventsFor(day, transactions)),
                      todayBuilder: (context, day, _) => _DayCell(
                          day: day,
                          events: _eventsFor(day, transactions),
                          isToday: true),
                      outsideBuilder: (context, day, _) =>
                          _DayCell(day: day, events: const [], isOutside: true),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        tooltip: '내역 추가',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ─── Summary Header ───────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  final DateTime focusedDay;
  final int income;
  final int expense;

  const _SummaryHeader({
    required this.focusedDay,
    required this.income,
    required this.expense,
  });

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    final isPositive = balance >= 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '가계부',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${focusedDay.year}년 ${focusedDay.month}월',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '이번 달 잔액',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                '${isPositive ? '+' : '-'}${_fmt(balance.abs())}원',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _MiniStat(
                        label: '수입',
                        amount: income,
                        color: const Color(0xFF6EFFD9)),
                    Container(
                        height: 24,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.white.withOpacity(0.2)),
                    _MiniStat(
                        label: '지출',
                        amount: expense,
                        color: const Color(0xFFFFB3BE)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;

  const _MiniStat(
      {required this.label, required this.amount, required this.color});

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text('${_fmt(amount)}원',
              style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── Sheet Option ─────────────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Day Cell ─────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime day;
  final List<Transaction> events;
  final bool isToday;
  final bool isOutside;

  const _DayCell({
    required this.day,
    required this.events,
    this.isToday = false,
    this.isOutside = false,
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
    final expense = events
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (s, t) => s + t.amount);
    final income = events
        .where((t) => t.type == TransactionType.income)
        .fold(0, (s, t) => s + t.amount);
    final isWeekend = day.weekday == 6 || day.weekday == 7;

    Color dayColor;
    if (isOutside) {
      dayColor = AppColors.textSecondary.withOpacity(0.3);
    } else if (isToday) {
      dayColor = Colors.white;
    } else if (isWeekend) {
      dayColor = AppColors.expense.withOpacity(0.8);
    } else {
      dayColor = AppColors.textPrimary;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: isToday
                ? const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  )
                : null,
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  color: dayColor,
                ),
              ),
            ),
          ),
          if (expense > 0)
            Text(
              '-${_compact(expense)}',
              style: const TextStyle(
                fontSize: 8.5,
                color: AppColors.expense,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (income > 0)
            Text(
              '+${_compact(income)}',
              style: const TextStyle(
                fontSize: 8.5,
                color: AppColors.income,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
