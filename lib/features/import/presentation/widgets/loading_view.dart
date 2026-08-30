// lib/features/import/presentation/widgets/loading_view.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class LoadingView extends StatelessWidget {
  final String message;
  const LoadingView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final textSecondary = isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(color: textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
