import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Extension methods to easily access custom theme extensions
extension ThemeExtensions on BuildContext {
  /// Get the custom gradients from the theme
  AppGradients get gradients {
    return Theme.of(this).extension<AppGradients>() ??
        const AppGradients(
          primaryGradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          secondaryGradient: LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          surfaceGradient: LinearGradient(
            colors: [Color(0xFFFAFAFA), Color(0xFFF3F4F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          cardShadow: [],
          buttonShadow: [],
        );
  }

  /// Quick access to color scheme
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Quick access to text theme
  TextTheme get textStyles => Theme.of(this).textTheme;
}

/// Example widget showing how to use the custom theme
class GradientCard extends StatelessWidget {
  final Widget child;
  final bool useGradient;
  final EdgeInsets? padding;

  const GradientCard({
    super.key,
    required this.child,
    this.useGradient = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = context.gradients;
    final colors = context.colors;

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: useGradient ? gradients.primaryGradient : null,
        color: useGradient ? null : colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: gradients.cardShadow,
      ),
      child: child,
    );
  }
}

/// Gradient button with smooth animations
class GradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradients = context.gradients;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: gradients.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: gradients.buttonShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else if (widget.icon != null)
                Icon(widget.icon, color: Colors.white, size: 20),
              if (widget.icon != null || widget.isLoading)
                const SizedBox(width: 12),
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated gradient background
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.surface,
                context.colors.surfaceContainerHighest,
              ],
              stops: [_controller.value, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Glassmorphism effect card
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double blur;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 10,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surface.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
