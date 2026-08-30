import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/accounts/presentation/widgets/account_card_widget.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/accounts/presentation/widgets/type_option_tile.dart';

class Step1NameType extends StatefulWidget {
  final String initialName;
  final AccountKind initialKind;
  final void Function(String name, AccountKind kind) onNext;

  const Step1NameType({
    super.key,
    required this.initialName,
    required this.initialKind,
    required this.onNext,
  });

  @override
  State<Step1NameType> createState() => _Step1NameTypeState();
}

class _Step1NameTypeState extends State<Step1NameType> {
  late final TextEditingController _nameController;
  late AccountKind _kind;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _kind = widget.initialKind;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;

    final previewAccount = AccountEntity(
      id: 'preview',
      name: _nameController.text.isEmpty
          ? 'Account Name'
          : _nameController.text,
      kind: _kind,
      last4Digits: '0000',
      gradientTheme: CardGradientTheme.indigoPurple,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          AccountCardWidget(account: previewAccount),

          const SizedBox(height: 32),

          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Account name',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 24),

          TypeOption(
            label: 'Bank',
            subtitle: 'Savings or current account',
            icon: Icons.account_balance_rounded,
            isSelected: _kind == AccountKind.bank,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _kind = AccountKind.bank);
            },
          ),
          const SizedBox(height: 12),
          TypeOption(
            label: 'Credit Card',
            subtitle: 'Visa, Mastercard, Amex, etc.',
            icon: Icons.credit_card_rounded,
            isSelected: _kind == AccountKind.creditCard,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _kind = AccountKind.creditCard);
            },
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nameController.text.trim().isEmpty
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      widget.onNext(_nameController.text.trim(), _kind);
                    },
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
