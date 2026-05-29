// lib/features/import/presentation/screens/pdf_import_screen.dart
//
// Full PDF import flow in one screen with multiple states:
// idle → picking → extracting → reviewing → importing → done

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/import/data/pdf_parser_service.dart';
import 'package:mobile_app/features/import/presentation/widgets/done_view.dart';
import 'package:mobile_app/features/import/presentation/widgets/idle_view.dart';
import 'package:mobile_app/features/import/presentation/widgets/loading_view.dart';
import 'package:mobile_app/features/import/presentation/widgets/password_view.dart';
import 'package:mobile_app/features/import/presentation/widgets/review_view.dart';
import 'package:mobile_app/features/transactions/presentation/providers/transaction_notifier.dart';

// ── Screen states ─────────────────────────────────────────────────────────────
enum _ImportStep {
  idle,
  picking,
  passwordPrompt,
  extracting,
  reviewing,
  importing,
  done,
}

class PdfImportScreen extends ConsumerStatefulWidget {
  const PdfImportScreen({super.key});

  @override
  ConsumerState<PdfImportScreen> createState() => _PdfImportScreenState();
}

class _PdfImportScreenState extends ConsumerState<PdfImportScreen> {
  _ImportStep _step = _ImportStep.idle;

  PlatformFile? _pickedFile;
  PdfImportResult? _importResult;
  AccountEntity? _selectedAccount;
  String? _errorMessage;

  // Which parsed transactions the user has selected to import
  // (they can deselect duplicates)
  final Set<int> _selectedIndices = {};

  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // ── Step 1: Pick file ─────────────────────────────────────────────────────
  Future<void> _pickFile() async {
    setState(() => _step = _ImportStep.picking);

    final service = ref.read(pdfParserServiceProvider);
    final file = await service.pickPdfFile();

    if (file == null) {
      setState(() => _step = _ImportStep.idle);
      return;
    }

    setState(() {
      _pickedFile = file;
      _step = _ImportStep.passwordPrompt;
    });
  }

  // ── Step 2: Extract text ──────────────────────────────────────────────────
  Future<void> _extractAndParse({String? password}) async {
    setState(() => _step = _ImportStep.extracting);

    final service = ref.read(pdfParserServiceProvider);

    final text = await service.extractText(_pickedFile!, password: password);

    if (text == null || text.trim().isEmpty) {
      setState(() {
        _step = _ImportStep.passwordPrompt;
        _errorMessage = password != null && password.isNotEmpty
            ? 'Incorrect password. Please try again.'
            : 'Could not read this PDF. It may be scanned or image-based.';
      });
      return;
    }

    // Get existing transactions for duplicate detection
    final existing = ref.read(transactionNotifierProvider).asData?.value ?? [];

    final result = service.parseText(text, _pickedFile!.name, existing);

    if (result.hasError) {
      setState(() {
        _step = _ImportStep.idle;
        _errorMessage = result.error;
      });
      return;
    }

    // Pre-select all non-duplicate transactions
    final indices = <int>{};
    for (int i = 0; i < result.transactions.length; i++) {
      if (!result.transactions[i].isDuplicateCandidate) {
        indices.add(i);
      }
    }

    setState(() {
      _importResult = result;
      _selectedIndices.clear();
      _selectedIndices.addAll(indices);
      _step = _ImportStep.reviewing;
    });
  }

  // ── Step 3: Import selected ───────────────────────────────────────────────
  Future<void> _importSelected() async {
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account first')),
      );
      return;
    }

    setState(() => _step = _ImportStep.importing);

    final selectedTransactions = _selectedIndices
        .map((i) => _importResult!.transactions[i])
        .map(
          (t) => t.toEntity(
            accountId: _selectedAccount!.id,
            accountName: _selectedAccount!.name,
          ),
        )
        .toList();

    await ref
        .read(transactionNotifierProvider.notifier)
        .importTransactions(selectedTransactions);

    setState(() => _step = _ImportStep.done);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinPilotTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Import PDF Statement'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case _ImportStep.idle:
        return IdleView(onPickFile: _pickFile, errorMessage: _errorMessage);

      case _ImportStep.picking:
        return const LoadingView(message: 'Opening file picker...');

      case _ImportStep.passwordPrompt:
        return PasswordView(
          fileName: _pickedFile?.name ?? '',
          controller: _passwordController,
          errorMessage: _errorMessage,
          onContinue: () => _extractAndParse(
            password: _passwordController.text.trim().isEmpty
                ? null
                : _passwordController.text.trim(),
          ),
          onSkip: () => _extractAndParse(),
        );

      case _ImportStep.extracting:
        return const LoadingView(message: 'Reading PDF...');

      case _ImportStep.reviewing:
        return ReviewView(
          result: _importResult!,
          selectedIndices: _selectedIndices,
          selectedAccount: _selectedAccount,
          onToggle: (index) {
            setState(() {
              if (_selectedIndices.contains(index)) {
                _selectedIndices.remove(index);
              } else {
                _selectedIndices.add(index);
              }
            });
          },
          onAccountSelected: (account) =>
              setState(() => _selectedAccount = account),
          onImport: _importSelected,
        );

      case _ImportStep.importing:
        return const LoadingView(message: 'Importing transactions...');

      case _ImportStep.done:
        return DoneView(
          count: _selectedIndices.length,
          onDone: () => Navigator.of(context).pop(),
        );
    }
  }
}




