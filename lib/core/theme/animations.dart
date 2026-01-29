import 'package:flutter/material.dart';

/// Animation duration constants for consistent motion throughout the app
class AppDurations {
  AppDurations._();

  /// Instant feedback (button press, tap)
  static const Duration instant = Duration(milliseconds: 100);

  /// Fast transitions (hover effects, small changes)
  static const Duration fast = Duration(milliseconds: 200);

  /// Standard transitions (most animations)
  static const Duration standard = Duration(milliseconds: 300);

  /// Medium transitions (page transitions, modals)
  static const Duration medium = Duration(milliseconds: 400);

  /// Slow transitions (complex animations, emphasis)
  static const Duration slow = Duration(milliseconds: 500);

  /// Extra slow (dramatic reveals, loading)
  static const Duration extraSlow = Duration(milliseconds: 800);

  /// Stagger delay for list items
  static const Duration staggerDelay = Duration(milliseconds: 50);
}

/// Animation curve constants for consistent motion feel
class AppCurves {
  AppCurves._();

  /// Standard easing - use for most animations
  static const Curve standard = Curves.easeInOutCubic;

  /// Enter animations - elements appearing
  static const Curve enter = Curves.easeOutCubic;

  /// Exit animations - elements disappearing
  static const Curve exit = Curves.easeInCubic;

  /// Emphasized animations - dramatic effect
  static const Curve emphasized = Curves.easeInOutBack;

  /// Bounce effect - playful interactions
  static const Curve bounce = Curves.elasticOut;

  /// Spring effect - natural feel
  static const Curve spring = Curves.easeOutBack;

  /// Linear - constant speed
  static const Curve linear = Curves.linear;

  /// Decelerate - slowing down
  static const Curve decelerate = Curves.decelerate;
}

/// Reusable animation configurations
class AppAnimations {
  AppAnimations._();

  /// Fade in animation
  static Widget fadeIn({
    required Widget child,
    required Animation<double> animation,
    Curve curve = Curves.easeOut,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: curve),
      child: child,
    );
  }

  /// Slide up fade in animation
  static Widget slideUpFadeIn({
    required Widget child,
    required Animation<double> animation,
    double offset = 20,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * offset),
            child: child,
          ),
        );
      },
    );
  }

  /// Scale fade in animation
  static Widget scaleFadeIn({
    required Widget child,
    required Animation<double> animation,
    double startScale = 0.95,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final scale = startScale + (1 - startScale) * animation.value;
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}

/// Staggered animation helper for lists
class StaggeredAnimation {
  final int index;
  final int totalItems;
  final Duration baseDuration;
  final Duration staggerDelay;

  const StaggeredAnimation({
    required this.index,
    required this.totalItems,
    this.baseDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  /// Get the delay for this item
  Duration get delay =>
      Duration(milliseconds: staggerDelay.inMilliseconds * index);

  /// Get the duration for this item
  Duration get duration => baseDuration;

  /// Get the total animation duration for all items
  Duration get totalDuration => Duration(
    milliseconds:
        baseDuration.inMilliseconds +
        (staggerDelay.inMilliseconds * (totalItems - 1)),
  );
}

/// A widget that fades in its child with optional slide
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double slideOffset;
  final Axis slideAxis;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.slideOffset = 0,
    this.slideAxis = Axis.vertical,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: widget.curve);

    final slideOffset = widget.slideAxis == Axis.vertical
        ? Offset(0, widget.slideOffset)
        : Offset(widget.slideOffset, 0);

    _slideAnimation = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Shimmer loading effect widget
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = widget.baseColor ?? colorScheme.surfaceContainerHighest;
    final highlightColor = widget.highlightColor ?? colorScheme.surface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Pulse animation widget for attention
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
