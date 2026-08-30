// lib/features/onboarding/presentation/screens/create_pin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/core/state/app_state_notifier.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/onboarding/presentation/widgets/number_pad.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  final List<String> _pin = [];
  final List<String> _confirmPin = [];
  bool _isConfirming = false;
  String? _errorMessage;

  void _onDigitTap(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;
      final current = _isConfirming ? _confirmPin : _pin;
      if (current.length < 4) {
        current.add(digit);

        if (!_isConfirming && _pin.length == 4) {
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) {
              setState(() => _isConfirming = true);
            }
          });
        } else if (_isConfirming && _confirmPin.length == 4) {
          _validateAndSave();
        }
      }
    });
  }

  void _onDelete() {
    HapticFeedback.selectionClick();
    setState(() {
      _errorMessage = null;
      if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin.removeLast();
      } else if (!_isConfirming && _pin.isNotEmpty) {
        _pin.removeLast();
      }
    });
  }

  Future<void> _validateAndSave() async {
    if (_pin.join() != _confirmPin.join()) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = 'PINs do not match. Try again.';
        _confirmPin.clear();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _isConfirming = true);
          }
        });
      });
      return;
    }
    HapticFeedback.mediumImpact();
    await ref.read(appStateProvider.notifier).pinCreated(_pin.join());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
          child: Column(
            children: [
              // Header
              Text(
                _isConfirming ? 'Confirm your PIN' : 'Create a PIN',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirming
                    ? 'Enter your PIN again to confirm'
                    : 'This PIN protects your financial data',
                style: TextStyle(color: textMuted, fontSize: 15),
              ),

              const SizedBox(height: 48),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = _isConfirming
                      ? i < _confirmPin.length
                      : i < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? primaryColor
                          : (isDark ? FinPilotColors.darkSurface2 : FinPilotColors.lightSurface2),
                      border: Border.all(
                        color: filled
                            ? primaryColor
                            : (isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: FinPilotColors.expense,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const Spacer(),

              // Number pad
              NumberPad(onDigitTap: _onDigitTap, onDelete: _onDelete),
            ],
          ),
        ),
      ),
    );
  }
}
