// lib/features/onboarding/presentation/screens/app_walkthrough_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/state/app_state_notifier.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class AppWalkthroughScreen extends ConsumerStatefulWidget {
  final bool isStandalone;

  const AppWalkthroughScreen({super.key, this.isStandalone = false});

  @override
  ConsumerState<AppWalkthroughScreen> createState() => _AppWalkthroughScreenState();
}

class _AppWalkthroughScreenState extends ConsumerState<AppWalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_WalkthroughStep> _steps = const [
    _WalkthroughStep(
      badge: 'CARD MANAGEMENT',
      title: 'Interactive 3D Card Stack',
      subtitle: 'Manage all your credit and debit accounts with realistic depth and smooth tactile gestures.',
      hintText: 'Swipe vertically to browse cards. Tap any card to flip it and access freeze, unfreeze, and card settings.',
      icon: Icons.credit_card_rounded,
      accentColor: Color(0xFF6C5CE7),
      secondaryIcon: Icons.flip_camera_android_rounded,
    ),
    _WalkthroughStep(
      badge: 'FINANCIAL INSIGHTS',
      title: 'Real-Time Analytics & Health',
      subtitle: 'Understand where every dollar goes with automated categorization, donut analytics, and health scores.',
      hintText: 'Tap on any category or top merchant in Analytics to open an instant drill-down breakdown.',
      icon: Icons.pie_chart_rounded,
      accentColor: Color(0xFF00CEC9),
      secondaryIcon: Icons.insights_rounded,
    ),
    _WalkthroughStep(
      badge: 'SMART PARSER',
      title: 'Instant PDF Statement Import',
      subtitle: 'Import password-protected e-statements from SBI, HDFC, ICICI, Axis and more with a single tap.',
      hintText: 'Select your bank statement PDF to extract transactions, detect tags, and sync balances automatically.',
      icon: Icons.picture_as_pdf_rounded,
      accentColor: Color(0xFFFD79A8),
      secondaryIcon: Icons.auto_awesome_motion_rounded,
    ),
    _WalkthroughStep(
      badge: 'AI COPILOT',
      title: 'Your 24/7 Wealth Advisor',
      subtitle: 'Get actionable financial intelligence, budget recommendations, and fiduciary spending diagnostics.',
      hintText: 'Use the quick prompt chips or ask questions like "How can I reduce my monthly expenses by 15%?".',
      icon: Icons.auto_awesome_rounded,
      accentColor: Color(0xFFFF7675),
      secondaryIcon: Icons.chat_bubble_outline_rounded,
    ),
  ];

  void _onNext() {
    HapticFeedback.selectionClick();
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _onSkip() {
    HapticFeedback.lightImpact();
    _finish();
  }

  void _finish() {
    if (widget.isStandalone) {
      Navigator.of(context).pop();
    } else {
      ref.read(appStateProvider.notifier).finishWalkthrough();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? FinPilotColors.primaryDark : FinPilotColors.primaryLight;
    final textPrimary = isDark ? FinPilotColors.darkTextPrimary : FinPilotColors.lightTextPrimary;
    final textMuted = isDark ? FinPilotColors.darkTextMuted : FinPilotColors.lightTextMuted;
    final isLastPage = _currentPage == _steps.length - 1;

    return Scaffold(
      backgroundColor: isDark ? FinPilotColors.darkBg : FinPilotColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar with Brand & Skip Button ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.trending_up_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'FinPilot Tour',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _onSkip,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Interactive Carousel PageView ─────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // ── Visual Graphic Container ──
                        _GraphicHero(step: step, isDark: isDark),

                        const SizedBox(height: 32),

                        // ── Category Badge ──
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: step.accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: step.accentColor.withValues(alpha: isDark ? 0.4 : 0.3),
                            ),
                          ),
                          child: Text(
                            step.badge,
                            style: TextStyle(
                              color: step.accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Title ──
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Subtitle Description ──
                        Text(
                          step.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: textMuted,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const Spacer(),

                        // ── Hint Text Box ──
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? FinPilotColors.darkSurface
                                : FinPilotColors.lightSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: step.accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: step.accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💡',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  step.hintText,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: textPrimary.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Bottom Navigation & Controls ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Animated Pill Indicator Dots ──
                  Row(
                    children: List.generate(_steps.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? _steps[_currentPage].accentColor
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // ── Back & Next/Done Buttons ──
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      GestureDetector(
                        onTap: _onNext,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: EdgeInsets.symmetric(
                            horizontal: isLastPage ? 24 : 20,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: _steps[_currentPage].accentColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: _steps[_currentPage].accentColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLastPage ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isLastPage
                                    ? Icons.rocket_launch_rounded
                                    : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphicHero extends StatelessWidget {
  final _WalkthroughStep step;
  final bool isDark;

  const _GraphicHero({required this.step, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            step.accentColor.withValues(alpha: isDark ? 0.3 : 0.2),
            step.accentColor.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
            shape: BoxShape.circle,
            border: Border.all(
              color: step.accentColor.withValues(alpha: isDark ? 0.6 : 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: step.accentColor.withValues(alpha: isDark ? 0.3 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                step.icon,
                color: step.accentColor,
                size: 48,
              ),
              Positioned(
                right: 18,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: step.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step.secondaryIcon,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalkthroughStep {
  final String badge;
  final String title;
  final String subtitle;
  final String hintText;
  final IconData icon;
  final Color accentColor;
  final IconData secondaryIcon;

  const _WalkthroughStep({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.hintText,
    required this.icon,
    required this.accentColor,
    required this.secondaryIcon,
  });
}
