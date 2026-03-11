import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pay_n_say/features/ledger/domain/models/transaction.dart';
import 'package:pay_n_say/features/ledger/presentation/providers/ledger_provider.dart';

class ManualEntryPage extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const ManualEntryPage({super.key, this.initialDate});

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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedCategory = expenseCategories.first;
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      date: _selectedDate,
      amount: int.parse(_amountController.text.replaceAll(',', '')),
      type: _selectedType,
      icon: _selectedCategory.icon,
      iconColor: _selectedCategory.color,
    );

    ref.read(transactionsProvider.notifier).add(tx);
    Navigator.of(context).pop();
  }

  String get _formattedDate =>
      '${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('직접 입력'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 수입/지출 토글
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('지출'),
                  icon: Icon(Icons.remove_circle_outline),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('수입'),
                  icon: Icon(Icons.add_circle_outline),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (set) => _onTypeChanged(set.first),
            ),
            const SizedBox(height: 24),

            // 상호명
            const _SectionLabel('상호명'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('예) 스타벅스', Icons.storefront),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '상호명을 입력해 주세요.' : null,
            ),
            const SizedBox(height: 20),

            // 카테고리
            const _SectionLabel('카테고리'),
            const SizedBox(height: 8),
            DropdownButtonFormField<TransactionCategory>(
              value: _selectedCategory,
              decoration: _inputDecoration('카테고리 선택', Icons.category),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(cat.icon, color: cat.color, size: 20),
                      const SizedBox(width: 10),
                      Text(cat.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (cat) {
                if (cat != null) setState(() => _selectedCategory = cat);
              },
            ),
            const SizedBox(height: 20),

            // 날짜
            const _SectionLabel('날짜'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextFormField(
                  decoration:
                      _inputDecoration(_formattedDate, Icons.calendar_today),
                  controller:
                      TextEditingController(text: _formattedDate),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 금액
            const _SectionLabel('금액'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              decoration: _inputDecoration('예) 12000', Icons.attach_money),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return '금액을 입력해 주세요.';
                if (int.tryParse(v) == null) return '숫자만 입력 가능합니다.';
                return null;
              },
            ),
            const SizedBox(height: 40),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == TransactionType.expense
                      ? colorScheme.primary
                      : Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(_selectedType == TransactionType.expense
                    ? '지출 저장'
                    : '수입 저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }
}
