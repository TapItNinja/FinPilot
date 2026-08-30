// lib/features/accounts/presentation/widgets/account_card_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/utils/card_gradient_helper.dart';
import '../../domain/entities/account_entity.dart';
import '../providers/account_notifier.dart';

class AccountCardWidget extends ConsumerStatefulWidget {
  final AccountEntity account;
  final double? width;
  final double? height;
  final bool isSelected;
  final bool flipEnabled;

  const AccountCardWidget({
    super.key,
    required this.account,
    this.width,
    this.height,
    this.isSelected = false,
    this.flipEnabled = true, // By default allow flipping
  });

  @override
  ConsumerState<AccountCardWidget> createState() => _AccountCardWidgetState();
}

class _AccountCardWidgetState extends ConsumerState<AccountCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AccountCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account.id != widget.account.id) {
      _isFront = true;
      _flipController.reset();
    }
  }

  void _toggleFlip() {
    if (!widget.flipEnabled) return;
    HapticFeedback.lightImpact();
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = gradientForTheme(widget.account.gradientTheme, isDark: isDark);
    final textColor = textColorForTheme(widget.account.gradientTheme, isDark: isDark);
    
    // We adjust visual color if frozen
    final isFrozen = widget.account.isFrozen;
    final effectiveGradient = isFrozen
        ? LinearGradient(
            colors: [
              Colors.grey.shade800,
              Colors.grey.shade900,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : gradient;

    final effectiveTextColor = isFrozen ? Colors.white70 : textColor;

    Widget cardContent = AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateY(angle);

        final showFront = _flipAnimation.value <= 0.5;

        return GestureDetector(
          onTap: _toggleFlip,
          behavior: HitTestBehavior.opaque,
          child: Transform(
            transform: transform,
            alignment: Alignment.center,
            child: showFront
                ? _buildFront(effectiveGradient, effectiveTextColor, isDark)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBack(effectiveGradient, effectiveTextColor, isDark),
                  ),
          ),
        );
      },
    );

    if (widget.width != null && widget.height != null) {
      return SizedBox(width: widget.width, height: widget.height, child: cardContent);
    } else if (widget.width != null) {
      return SizedBox(
        width: widget.width,
        height: widget.width! / CardDimensions.creditCardAspectRatio,
        child: cardContent,
      );
    } else if (widget.height != null) {
      return SizedBox(
        width: widget.height! * CardDimensions.creditCardAspectRatio,
        height: widget.height,
        child: cardContent,
      );
    }

    return AspectRatio(
      aspectRatio: CardDimensions.creditCardAspectRatio,
      child: cardContent,
    );
  }

  Widget _buildFront(LinearGradient gradient, Color textColor, bool isDark) {
    final isCreditCard = widget.account.kind == AccountKind.creditCard;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark
                  ? (widget.isSelected ? 0.5 : 0.35)
                  : (widget.isSelected ? 0.2 : 0.1),
            ),
            blurRadius: widget.isSelected ? 22 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Subtle fingerprint watermark ────────────────────────────────
          Positioned(
            right: -10,
            bottom: -20,
            child: Opacity(
              opacity: 0.06,
              child: Icon(Icons.fingerprint, size: 180, color: textColor),
            ),
          ),

          // ── Frozen Overlay ──
          if (widget.account.isFrozen)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.ac_unit_rounded, color: Colors.blueAccent, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'FROZEN',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Card content ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: EMV Chip + NFC ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Metallic Gold Chip
                    Container(
                      width: 34,
                      height: 24,
                      decoration: BoxDecoration(
                        color: widget.account.isFrozen
                            ? Colors.grey.shade400
                            : const Color(0xFFD4AF37).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: widget.account.isFrozen ? Colors.grey.shade500 : const Color(0xFFF3E5AB),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 18,
                          height: 12,
                          decoration: BoxDecoration(
                            color: widget.account.isFrozen
                                ? Colors.grey.shade500
                                : const Color(0xFFB8860B).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: widget.account.isFrozen ? Colors.grey.shade300 : const Color(0xFFFFF8DC),
                              width: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Contactless Wave Icon
                    Icon(
                      Icons.wifi_rounded,
                      color: textColor.withValues(alpha: 0.8),
                      size: 20,
                    ),
                  ],
                ),

                const Spacer(),

                // ── Row 2: Masked card number ─────────────────────────────
                Row(
                  children: [
                    ...List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          children: List.generate(
                            4,
                            (_) => Container(
                              width: 4.5,
                              height: 4.5,
                              margin: const EdgeInsets.only(right: 2.5),
                              decoration: BoxDecoration(
                                color: textColor.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      widget.account.last4Digits,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // ── Row 3: Name + Network Logo ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CARDHOLDER',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.6),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.account.name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Network logo (VISA / BANK)
                    isCreditCard
                        ? Text(
                            'VISA',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.account_balance_rounded, color: textColor, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'BANK',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFreezeToggle() async {
    if (!widget.account.isFrozen) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? FinPilotColors.darkSurface : FinPilotColors.lightSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: isDark ? FinPilotColors.darkBorder : FinPilotColors.lightBorder,
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.ac_unit_rounded, color: Colors.blueAccent, size: 22),
                ),
                const SizedBox(width: 12),
                const Text('Freeze Account?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: Text(
              'Are you sure you want to freeze ${widget.account.name} (•••• ${widget.account.last4Digits})?\n\nThis will temporarily remove this card from your active stack and exclude its transactions from overall balances.',
              style: TextStyle(
                color: isDark ? FinPilotColors.darkTextSecondary : FinPilotColors.lightTextSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Freeze Account', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        if (mounted) {
          setState(() {
            _isFront = true;
            _flipController.reset();
          });
        }
        HapticFeedback.heavyImpact();
        await ref.read(accountNotifierProvider.notifier).toggleFreeze(widget.account.id);
        final selected = ref.read(selectedAccountProvider);
        if (selected?.id == widget.account.id) {
          ref.read(selectedAccountProvider.notifier).select(null);
        }
      }
    } else {
      HapticFeedback.mediumImpact();
      await ref.read(accountNotifierProvider.notifier).toggleFreeze(widget.account.id);
    }
  }

  Widget _buildBack(LinearGradient gradient, Color textColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark
                  ? (widget.isSelected ? 0.5 : 0.35)
                  : (widget.isSelected ? 0.2 : 0.1),
            ),
            blurRadius: widget.isSelected ? 22 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtly dark overlay to make it look like the back
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Magnetic Stripe
              Container(
                height: 36,
                color: Colors.black87,
              ),
              const SizedBox(height: 12),
              // Signature Box & CVV
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        child: const Text(
                          '***',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'CVV',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Freeze Card Switch & Info
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Service',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '1-800-FIN-PILOT',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    // Quick Action: Freeze Card
                    GestureDetector(
                      onTap: _handleFreezeToggle,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Text(
                            widget.account.isFrozen ? 'Unfreeze' : 'Freeze Card',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            widget.account.isFrozen ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                            color: widget.account.isFrozen ? Colors.blueAccent : textColor.withValues(alpha: 0.5),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}