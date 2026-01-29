import 'dart:ui';

import 'package:flutter/material.dart';

/// A modern glassmorphic card with frosted glass effect
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderRadius,
    this.border,
    this.padding,
    this.margin,
    this.gradient,
    this.width,
    this.height,
    this.constraints,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultBorderRadius = BorderRadius.circular(20);
    final effectiveBorderRadius = borderRadius ?? defaultBorderRadius;

    Widget card = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          constraints: constraints,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: effectiveBorderRadius,
            gradient:
                gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (backgroundColor ?? colorScheme.surface).withValues(
                      alpha: opacity + 0.1,
                    ),
                    (backgroundColor ?? colorScheme.surface).withValues(
                      alpha: opacity,
                    ),
                  ],
                ),
            border:
                border ??
                Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// A simple frosted glass container without the card styling
class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? tint;
  final double tintOpacity;
  final BorderRadius? borderRadius;

  const FrostedGlass({
    super.key,
    required this.child,
    this.blur = 10,
    this.tint,
    this.tintOpacity = 0.1,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTint = tint ?? Theme.of(context).colorScheme.surface;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveTint.withValues(alpha: tintOpacity),
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A container with animated gradient background
class AnimatedGradientContainer extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AnimatedGradientContainer({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    this.borderRadius,
    this.padding,
  });

  @override
  State<AnimatedGradientContainer> createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final gradientColors = widget.colors.length >= 2
            ? widget.colors
            : [widget.colors.first, widget.colors.first];

        // Shift the gradient stops based on animation
        final shift = _animation.value * 0.5;

        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1 + shift, -1 + shift),
              end: Alignment(1 + shift, 1 + shift),
              colors: gradientColors,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
