// lib/features/transactions/presentation/screens/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/accounts/presentation/providers/account_notifier.dart';
import 'package:mobile_app/features/rules/data/rule_engine_service.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/add_transaction/account_picker.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/add_transaction/section_label.dart';
import 'package:mobile_app/features/transactions/presentation/widgets/add_transaction/toggle.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_notifier.dart';
import 'emi_dialog.dart';
import 'package:mobile_app/features/import/presentation/screens/pdf_import_screen.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.debit;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  AccountEntity? _selectedAccount; // NEW — selected account

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _previewCategory() async {
    final merchant = _merchantController.text.trim();
    if (merchant.isEmpty) {
      return;
    }

    final ruleEngineService = ref.read(ruleEngineServiceProvider);
    final preview = TransactionEntity(
      id: 'preview',
      amount: 0,
      currencyCode: CurrencyCode.inr,
      merchant: merchant,
      timestamp: _selectedDate,
      category: 'Uncategorized',
      type: _selectedType,
      source: '',
      status: TransactionStatus.completed,
      isRecurring: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final tagged = await ruleEngineService.applyRulesTo(preview);
    if (tagged.category != 'Uncategorized' &&
        _categoryController.text.isEmpty) {
      setState(() => _categoryController.text = tagged.category);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final transaction = TransactionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text.trim()),
        currencyCode: CurrencyCode.inr,
        merchant: _merchantController.text.trim(),
        timestamp: _selectedDate,
        category: _categoryController.text.trim().isEmpty
            ? 'Uncategorized'
            : _categoryController.text.trim(),
        type: _selectedType,
        source: _selectedAccount!.name, // account name as source
        accountId: _selectedAccount!.id, // wire accountId
        status: TransactionStatus.completed,
        isRecurring: false,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        importSource: ImportSource.manual,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final isEmiCandidate = await ref
          .read(transactionNotifierProvider.notifier)
          .addTransaction(transaction);

      if (!mounted) {
        return;
      }

      if (isEmiCandidate) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => EmiDialog(transaction: transaction),
        );
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountNotifierProvider).asData?.value ?? [];

    return Scaffold(
      backgroundColor: FinPilotTheme.darkBg,
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: FinPilotTheme.darkBg,
        actions: _isSaving
            ? [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Type Toggle ──────────────────────────────────────────────
            SectionLabel('Transaction Type'),
            const SizedBox(height: 8),
            TypeToggle(
              selected: _selectedType,
              onChanged: (type) => setState(() => _selectedType = type),
            ),

            const SizedBox(height: 24),

            // ── Account Picker (mini card row) ───────────────────────────
            SectionLabel('Account'),
            const SizedBox(height: 4),
            const Text(
              'Select which account this transaction belongs to',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 12),
            AccountPicker(
              accounts: accounts,
              selected: _selectedAccount,
              onSelected: (account) =>
                  setState(() => _selectedAccount = account),
            ),

            const SizedBox(height: 16),

            // ── Import from PDF ──────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PdfImportScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: FinPilotTheme.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: FinPilotTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: FinPilotTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: FinPilotTheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Import from PDF',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Upload a bank statement',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white24,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const SectionLabel('Or enter manually'),

            const SizedBox(height: 16),

            // ── Merchant ─────────────────────────────────────────────────
            SectionLabel('Merchant / Paid To'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _merchantController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('e.g. Swiggy, Amazon, KFC'),
              onEditingComplete: _previewCategory,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter merchant name'
                  : null,
            ),

            const SizedBox(height: 16),

            // ── Amount ───────────────────────────────────────────────────
            SectionLabel('Amount (₹)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: _inputDecoration('0.00'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Enter amount';
                }
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Date ─────────────────────────────────────────────────────
            SectionLabel('Date'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: FinPilotTheme.darkSurface2,
                  border: Border.all(color: FinPilotTheme.darkBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Category ─────────────────────────────────────────────────
            SectionLabel('Category'),
            const SizedBox(height: 4),
            const Text(
              'Auto-filled from merchant name. You can edit it.',
              style: TextStyle(fontSize: 12, color: Colors.white38),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _categoryController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('e.g. Food, Shopping, Transport'),
            ),

            const SizedBox(height: 16),

            // ── Note ─────────────────────────────────────────────────────
            SectionLabel('Note (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: _inputDecoration('Add a note...'),
            ),

            const SizedBox(height: 32),

            // ── Save Button ──────────────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save Transaction',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}




