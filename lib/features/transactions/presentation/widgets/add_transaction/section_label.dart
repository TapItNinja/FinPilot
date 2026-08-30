// lib/features/transactions/presentation/widgets/add_transaction/section_label.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      text,
      style: TextStyle(
        color: isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }
}
