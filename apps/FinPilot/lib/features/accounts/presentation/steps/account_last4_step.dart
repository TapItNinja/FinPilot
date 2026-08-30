// lib/features/accounts/presentation/steps/account_last4_step.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/accounts/presentation/widgets/account_card_widget.dart';

class Step2Last4 extends StatefulWidget {
  final String accountName;
  final AccountKind kind;
  final String initialLast4;
  final CardGradientTheme selectedTheme;
  final VoidCallback onBack;
  final void Function(String last4) onNext;

  const Step2Last4({
    super.key,
    required this.accountName,
    required this.kind,
    required this.initialLast4,
    required this.selectedTheme,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<Step2Last4> createState() => _Step2Last4State();
}

class _Step2Last4State extends State<Step2Last4> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLast4);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textSecondary = isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;
    final surfaceColor = isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface;
    final borderColor = isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder;

    final preview = AccountEntity(
      id: 'preview',
      name: widget.accountName,
      kind: widget.kind,
      last4Digits: _controller.text.length == 4 ? _controller.text : '0000',
      gradientTheme: widget.selectedTheme,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          AccountCardWidget(account: preview),

          const SizedBox(height: 32),

          Text(
            'Enter last 4 digits of\naccount number',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          // XXXX 0000 styled display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'XXXX ',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintText: '0000',
                    hintStyle: TextStyle(
                      color: textMuted,
                      fontSize: 28,
                      letterSpacing: 4,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Info box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(CardDimensions.borderRadiusSmall),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: FinPilotColors.warning,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Account number is required to differentiate between multiple accounts from the same bank and to match transactions from email alerts.',
                    style: TextStyle(color: textSecondary, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    widget.onBack();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _controller.text.length == 4
                      ? () {
                          HapticFeedback.lightImpact();
                          widget.onNext(_controller.text);
                        }
                      : null,
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
