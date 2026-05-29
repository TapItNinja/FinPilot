// lib/features/accounts/presentation/screens/add_account_flow.dart
//
// 4-step wizard for adding a new account.
// Uses a PageView to animate between steps.
// Steps: name+type → last 4 digits → gradient theme → import method → created!
//
// WHY PageView instead of Navigator pushes:
// All steps share the same state (account being built).
// PageView keeps them in memory and animates smoothly.
// We hold the in-progress account fields in local state.

import 'package:flutter/material.dart';
// import 'package:mobile_app/features/import/presentation/screens/pdf_import_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/accounts/presentation/steps/account_import_step.dart';
import 'package:mobile_app/features/accounts/presentation/steps/account_last4_step.dart';
import 'package:mobile_app/features/accounts/presentation/steps/account_theme_step.dart';
import '../../domain/entities/account_entity.dart';
import '../../presentation/providers/account_notifier.dart';
import 'package:mobile_app/features/accounts/presentation/steps/account_name_step.dart';

class AddAccountFlow extends ConsumerStatefulWidget {
  // If true, after completion → call accountsSetupComplete (first time setup)
  // If false, just pop back (adding additional account)
  final bool isFirstSetup;

  const AddAccountFlow({super.key, this.isFirstSetup = false});

  @override
  ConsumerState<AddAccountFlow> createState() => _AddAccountFlowState();
}

class _AddAccountFlowState extends ConsumerState<AddAccountFlow> {
  final _pageController = PageController();
  int _currentPage = 0;

  // State being built across steps
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
    _nextPage(); // go to created screen
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinPilotTheme.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: _currentPage < 4
            ? const Text('New Account')
            : const SizedBox.shrink(),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: FinPilotTheme.expense, fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // only programmatic swipe
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

          // Step 4 — Import method (shown after account created)
          if (_createdAccount != null)
            Step4ImportMethod(
              account: _createdAccount!,
              isFirstSetup: widget.isFirstSetup,
              onDone: () {
                if (widget.isFirstSetup) {
                  // Pop back to setup screen which handles the state transition
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


