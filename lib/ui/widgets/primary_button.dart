import 'package:flutter/material.dart';
import '../theme.dart';

/// Highly animated primary action button.
class PrimaryButton extends StatefulWidget {
  final String label;
  final bool enabled;
  final bool showProgress;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    this.enabled = true,
    this.showProgress = false,
    this.onPressed,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _c.drive(CurveTween(curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: AppColors.accentCyan.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: widget.enabled
                ? () async {
                    await _c.reverse();
                    await _c.forward();
                    widget.onPressed?.call();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.enabled
                  ? AppColors.accentCyan
                  : Colors.grey.withOpacity(0.35),
              foregroundColor: AppColors.nearBlack,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.showProgress
                  ? const SizedBox(
                      key: ValueKey('p'),
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.nearBlack,
                      ),
                    )
                  : Text(
                      widget.label,
                      key: ValueKey(widget.label),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
