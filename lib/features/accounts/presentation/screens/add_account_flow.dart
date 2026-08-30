// lib/features/accounts/presentation/screens/add_account_flow.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/accounts/presentation/steps/account_import_step.dart';
import 'package:mobile_app/features/accounts/presentation/steps/account_last4_step.dart';
import 'package:mobile_app/features/accounts/presentation/steps/account_theme_step.dart';
import '../../domain/entities/account_entity.dart';
import '../../presentation/providers/account_notifier.dart';
import 'package:mobile_app/features/accounts/presentation/steps/account_name_step.dart';

class AddAccountFlow extends ConsumerStatefulWidget {
  final bool isFirstSetup;

  const AddAccountFlow({super.key, this.isFirstSetup = false});

  @override
  ConsumerState<AddAccountFlow> createState() => _AddAccountFlowState();
}

class _AddAccountFlowState extends ConsumerState<AddAccountFlow> {
  final _pageController = PageController();
  int _currentPage = 0;

  String _name = '';
  AccountKind _kind = AccountKind.bank;
  String _last4 = '';
  CardGradientTheme _theme = CardGradientTheme.indigoPurple;
  AccountEntity? _createdAccount;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    if (_currentPage == 0) {
      Navigator.of(context).pop();
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createAccount() async {
    final account = await ref
        .read(accountNotifierProvider.notifier)
        .addAccount(
          name: _name,
          kind: _kind,
          last4Digits: _last4,
          gradientTheme: _theme,
        );
    setState(() => _createdAccount = account);
    _nextPage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          _currentPage < 3 ? 'New Account' : 'Account Ready',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          if (_currentPage < 3)
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: FinPilotColors.expense,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                if (widget.isFirstSetup) {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: FinPilotColors.income,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          // Step 1 — Name + Type
          Step1NameType(
            initialName: _name,
            initialKind: _kind,
            onNext: (name, kind) {
              setState(() {
                _name = name;
                _kind = kind;
              });
              _nextPage();
            },
          ),

          // Step 2 — Last 4 digits
          Step2Last4(
            accountName: _name,
            kind: _kind,
            initialLast4: _last4,
            selectedTheme: _theme,
            onBack: _prevPage,
            onNext: (last4) {
              setState(() => _last4 = last4);
              _nextPage();
            },
          ),

          // Step 3 — Theme picker
          Step3Theme(
            accountName: _name,
            kind: _kind,
            last4: _last4,
            selectedTheme: _theme,
            onBack: _prevPage,
            onNext: (theme) {
              setState(() => _theme = theme);
              _createAccount();
            },
          ),

          // Step 4 — Import method
          if (_createdAccount != null)
            Step4ImportMethod(
              account: _createdAccount!,
              isFirstSetup: widget.isFirstSetup,
              onDone: () {
                if (widget.isFirstSetup) {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pop();
                }
              },
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
