// ── Done view ─────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class DoneView extends StatelessWidget {
  final int count;
  final VoidCallback onDone;

  const DoneView({super.key, required this.count, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FinPilotTheme.income.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 56,
                color: FinPilotTheme.income,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$count transaction${count == 1 ? '' : 's'} imported!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The rule engine has automatically categorised your transactions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onDone,
                child: const Text('Back to Transactions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
