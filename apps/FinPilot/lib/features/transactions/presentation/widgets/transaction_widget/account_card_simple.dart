// import 'package:flutter/material.dart';
// import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
// import 'package:mobile_app/core/utils/card_gradient_helper.dart';

// class AccountCardSimple extends StatelessWidget {
//   final AccountEntity account;
//   final double height;
//   final double opacity;

//   const AccountCardSimple({
//     super.key,
//     required this.account,
//     required this.height,
//     this.opacity = 1.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final gradient = gradientForTheme(account.gradientTheme);
//     final textColor = _textColor(account.gradientTheme);

//     return Opacity(
//       opacity: opacity,
//       child: Container(
//         height: height,
//         decoration: BoxDecoration(
//           gradient: gradient,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: gradient.colors.first.withValues(alpha: 0.3),
//               blurRadius: 16,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Text(
//                     account.name,
//                     style: TextStyle(
//                       color: textColor,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Icon(
//                   account.kind == AccountKind.creditCard
//                       ? Icons.credit_card_rounded
//                       : Icons.account_balance_rounded,
//                   color: textColor.withValues(alpha: 0.7),
//                   size: 22,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(
//                 color: textColor.withValues(alpha: 0.15),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 account.kind == AccountKind.creditCard ? 'CREDIT CARD' : 'BANK',
//                 style: TextStyle(
//                   color: textColor.withValues(alpha: 0.8),
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 1,
//                 ),
//               ),
//             ),
//             const Spacer(),
//             Text(
//               'XXXX ${account.last4Digits}',
//               style: TextStyle(
//                 color: textColor.withValues(alpha: 0.9),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _textColor(CardGradientTheme theme) {
//     switch (theme) {
//       case CardGradientTheme.pinkLavender:
//       case CardGradientTheme.peachCream:
//         return const Color(0xFF1A1A2E);
//       default:
//         return Colors.white;
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:mobile_app/features/accounts/domain/entities/account_entity.dart';
import 'package:mobile_app/core/utils/card_gradient_helper.dart';

class AccountCardSimple extends StatelessWidget {
  final AccountEntity account;
  final double height;
  final double opacity;

  const AccountCardSimple({
    super.key,
    required this.account,
    required this.height,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = gradientForTheme(account.gradientTheme);
    final textColor = _textColor(account.gradientTheme);
    final isCreditCard = account.kind == AccountKind.creditCard;

    return Opacity(
      opacity: opacity,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ── Fingerprint watermark ───────────────────────────────────────
            Positioned(
              right: -10,
              bottom: -20,
              child: Opacity(
                opacity: 0.07,
                child: Icon(Icons.fingerprint, size: 180, color: textColor),
              ),
            ),

            // ── Card content ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Row 1: chip icon + NFC + card type badge ──────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Chip
                      Container(
                        width: 36,
                        height: 26,
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: textColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 20,
                            height: 14,
                            decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: textColor.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // NFC icon
                      Icon(
                        Icons.wifi_rounded, // rotated for NFC look
                        color: textColor.withValues(alpha: 0.7),
                        size: 22,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Row 2: masked card number ─────────────────────────────
                  Row(
                    children: [
                      // Three groups of dots
                      ...List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            children: List.generate(
                              4,
                              (_) => Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.only(right: 3),
                                decoration: BoxDecoration(
                                  color: textColor.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Last 4 digits
                      Text(
                        account.last4Digits,
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

                  // ── Row 3: Name + Network logo ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Name block
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NAME',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            account.name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Network logo (VISA style or BANK)
                      isCreditCard
                          ? _VisaLogo(color: textColor)
                          : _BankBadge(color: textColor),
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

  Color _textColor(CardGradientTheme theme) {
    switch (theme) {
      case CardGradientTheme.pinkLavender:
      case CardGradientTheme.peachCream:
        return const Color(0xFF1A1A2E);
      default:
        return Colors.white;
    }
  }
}

// ── VISA logo replica ──────────────────────────────────────────────────────────
class _VisaLogo extends StatelessWidget {
  final Color color;
  const _VisaLogo({required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      'VISA',
      style: TextStyle(
        color: color,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: 1,
        shadows: [
          Shadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(1, 2),
          ),
        ],
      ),
    );
  }
}

// ── Bank badge ─────────────────────────────────────────────────────────────────
class _BankBadge extends StatelessWidget {
  final Color color;
  const _BankBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.account_balance_rounded, color: color, size: 16),
        const SizedBox(width: 5),
        Text(
          'BANK',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
