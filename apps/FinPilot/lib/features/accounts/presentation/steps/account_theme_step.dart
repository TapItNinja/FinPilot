// ── Step 3: Theme picker ──────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/core/utils/card_gradient_helper.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/features/accounts/presentation/widgets/account_card_widget.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class Step3Theme extends StatefulWidget {
  final String accountName;
  final AccountKind kind;
  final String last4;
  final CardGradientTheme selectedTheme;
  final VoidCallback onBack;
  final void Function(CardGradientTheme theme) onNext;

  const Step3Theme({
    super.key,
    required this.accountName,
    required this.kind,
    required this.last4,
    required this.selectedTheme,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<Step3Theme> createState() => _Step3ThemeState();
}

class _Step3ThemeState extends State<Step3Theme> {
  late CardGradientTheme _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedTheme;
  }

  @override
  Widget build(BuildContext context) {
    final preview = AccountEntity(
      id: 'preview',
      name: widget.accountName,
      kind: widget.kind,
      last4Digits: widget.last4,
      gradientTheme: _selected,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccountCardWidget(account: preview, height: 160),

          const SizedBox(height: 24),

          Text(
            'Choose a theme',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 16),

          // Grid of gradient swatches
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: CardGradientTheme.values.length,
              itemBuilder: (context, index) {
                final theme = CardGradientTheme.values[index];
                final gradient = gradientForTheme(theme);
                final isSelected = theme == _selected;

                return GestureDetector(
                  onTap: () => setState(() => _selected = theme),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: gradient.colors.first.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: FinPilotTheme.darkBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => widget.onNext(_selected),
                  child: const Text('Create Account'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
