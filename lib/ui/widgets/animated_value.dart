import 'package:flutter/material.dart';
import '../theme.dart';

/// Large animated measurement value (white or dark surface).
class AnimatedValue extends StatelessWidget {
  final String value;
  final String? unit;
  final bool onWhite;
  final double fontSize;

  const AnimatedValue({
    super.key,
    required this.value,
    this.unit,
    this.onWhite = true,
    this.fontSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final color = onWhite ? AppColors.textOnWhite : AppColors.textPrimary;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      child: Row(
        key: ValueKey('$value|$unit'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          if (unit != null) ...[
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: fontSize * 0.4,
                color: onWhite
                    ? AppColors.textMutedOnWhite
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              child: Text(unit!),
            ),
          ],
        ],
      ),
    );
  }
}

/// White card surface with entrance animation.
class AnimatedWhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AnimatedWhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderOnWhite),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
