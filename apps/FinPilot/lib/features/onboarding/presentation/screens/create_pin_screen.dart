// lib/features/onboarding/presentation/screens/create_pin_screen.dart
//
// Shown after first login. User sets a 4-digit PIN.
// PIN is stored in flutter_secure_storage via PinService.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    setState(() {
      _errorMessage = null;
      final current = _isConfirming ? _confirmPin : _pin;
      if (current.length < 4) {
        current.add(digit);

        // Auto-advance after 4 digits
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
      setState(() {
        _errorMessage = 'PINs do not match. Try again.';
        _confirmPin.clear();
        // Shake effect — reset to re-enter confirm PIN
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _isConfirming = true);
          }
        });
      });
      return;
    }
    await ref.read(appStateProvider.notifier).pinCreated(_pin.join());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinPilotTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
          child: Column(
            children: [
              // Header
              Text(
                _isConfirming ? 'Confirm your PIN' : 'Create a PIN',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirming
                    ? 'Enter your PIN again to confirm'
                    : 'This PIN protects your financial data',
                style: const TextStyle(color: Colors.white38, fontSize: 15),
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
                          ? FinPilotTheme.primary
                          : FinPilotTheme.darkSurface2,
                      border: Border.all(
                        color: filled
                            ? FinPilotTheme.primary
                            : FinPilotTheme.darkBorder,
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
                    color: FinPilotTheme.expense,
                    fontSize: 14,
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


