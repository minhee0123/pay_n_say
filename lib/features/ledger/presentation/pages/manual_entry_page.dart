import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';
import 'package:pay_n_say/features/ledger/domain/models/transaction.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';

class ManualEntryPage extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final Transaction? editTransaction;

  const ManualEntryPage({super.key, this.initialDate, this.editTransaction});

  @override
  ConsumerState<ManualEntryPage> createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends ConsumerState<ManualEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  late DateTime _selectedDate;
  TransactionType _selectedType = TransactionType.expense;
  late TransactionCategory _selectedCategory;

  List<TransactionCategory> get _categories =>
      _selectedType == TransactionType.expense
          ? expenseCategories
          : incomeCategories;

  bool get _isEditing => widget.editTransaction != null;
  bool get _isExpense => _selectedType == TransactionType.expense;
  Color get _typeColor => _isExpense ? AppColors.expense : AppColors.income;

  @override
  void initState() {
    super.initState();
    final tx = widget.editTransaction;
    if (tx != null) {
      _selectedType = tx.type;
      _selectedDate = tx.date;
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toString();
      // 기존 카테고리 매칭
      _selectedCategory = _categories.firstWhere(
        (c) => c.icon == tx.icon && c.color == tx.iconColor,
        orElse: () => _categories.first,
      );
    } else {
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedCategory = expenseCategories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
      _selectedCategory = _categories.first;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final tx = Transaction(
      id: widget.editTransaction?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      date: _selectedDate,
      amount: int.parse(_amountController.text.replaceAll(',', '')),
      type: _selectedType,
      icon: _selectedCategory.icon,
      iconColor: _selectedCategory.color,
    );

    final notifier = ref.read(transactionsProvider.notifier);
    if (_isEditing) {
      notifier.update(tx);
    } else {
      notifier.add(tx);
    }
    Navigator.of(context).pop();
  }

  String get _formattedDate =>
      '${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? '내역 수정' : '직접 입력'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // ── 지출 / 수입 토글 ────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  _TypeTab(
                    label: '지출',
                    icon: Icons.remove_rounded,
                    selected: _isExpense,
                    selectedColor: AppColors.expense,
                    onTap: () => _onTypeChanged(TransactionType.expense),
                  ),
                  _TypeTab(
                    label: '수입',
                    icon: Icons.add_rounded,
                    selected: !_isExpense,
                    selectedColor: AppColors.income,
                    onTap: () => _onTypeChanged(TransactionType.income),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 입력 카드 ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상호명
                  const _FieldLabel('상호명'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: '예) 스타벅스',
                      prefixIcon: Icon(Icons.storefront_rounded),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? '상호명을 입력해 주세요.'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // 카테고리
                  const _FieldLabel('카테고리'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TransactionCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      hintText: '카테고리 선택',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, color: cat.color, size: 18),
                            const SizedBox(width: 10),
                            Text(cat.label,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (cat) {
                      if (cat != null) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // 날짜
                  const _FieldLabel('날짜'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: _formattedDate,
                          prefixIcon:
                              const Icon(Icons.calendar_today_rounded),
                        ),
                        controller:
                            TextEditingController(text: _formattedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 금액
                  const _FieldLabel('금액'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      hintText: '예) 12000',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 14, right: 8),
                        child: Text('₩',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 0, minHeight: 0),
                      suffixText: '원',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '금액을 입력해 주세요.';
                      if (int.tryParse(v) == null) return '숫자만 입력 가능합니다.';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── 저장 버튼 ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _typeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                child: Text(_isEditing
                    ? '수정 완료'
                    : (_isExpense ? '지출 저장하기' : '수입 저장하기')),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ─── Type Tab ─────────────────────────────────────────────────────────────────

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? selectedColor.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? selectedColor : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      selected ? selectedColor : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary),
    );
  }
}
