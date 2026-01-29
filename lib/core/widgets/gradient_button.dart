import 'package:flutter/material.dart';

/// A modern gradient button with hover effects and loading state
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color>? gradientColors;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradientColors,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 52,
    this.borderRadius = 14,
    this.textStyle,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> get _defaultGradient {
    final colorScheme = Theme.of(context).colorScheme;
    return [colorScheme.primary, colorScheme.secondary];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColors = widget.gradientColors ?? _defaultGradient;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          if (!isDisabled) {
            _controller.forward();
          }
        },
        onTapUp: (_) {
          _controller.reverse();
        },
        onTapCancel: () {
          _controller.reverse();
        },
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: widget.isOutlined
                  ? null
                  : LinearGradient(
                      colors: isDisabled
                          ? gradientColors
                                .map((c) => c.withValues(alpha: 0.5))
                                .toList()
                          : gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: widget.isOutlined
                  ? Border.all(
                      color: isDisabled
                          ? colorScheme.primary.withValues(alpha: 0.5)
                          : colorScheme.primary,
                      width: 2,
                    )
                  : null,
              boxShadow: widget.isOutlined || isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: gradientColors.first.withValues(
                          alpha: _isHovered ? 0.4 : 0.3,
                        ),
                        blurRadius: _isHovered ? 20 : 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: widget.width != null
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isOutlined
                                ? colorScheme.primary
                                : Colors.white,
                          ),
                        ),
                      )
                    else ...[
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 20,
                          color: widget.isOutlined
                              ? colorScheme.primary
                              : Colors.white,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style:
                            widget.textStyle ??
                            TextStyle(
                              color: widget.isOutlined
                                  ? colorScheme.primary
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A simple icon button with gradient background
class GradientIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final List<Color>? gradientColors;
  final double size;
  final double iconSize;
  final double borderRadius;

  const GradientIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.gradientColors,
    this.size = 48,
    this.iconSize = 24,
    this.borderRadius = 12,
  });

  @override
  State<GradientIconButton> createState() => _GradientIconButtonState();
}

class _GradientIconButtonState extends State<GradientIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColors =
        widget.gradientColors ?? [colorScheme.primary, colorScheme.secondary];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withValues(
                  alpha: _isHovered ? 0.4 : 0.25,
                ),
                blurRadius: _isHovered ? 16 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// A text button with subtle gradient hover effect
class SubtleGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool iconTrailing;

  const SubtleGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.iconTrailing = false,
  });

  @override
  State<SubtleGradientButton> createState() => _SubtleGradientButtonState();
}

class _SubtleGradientButtonState extends State<SubtleGradientButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _isHovered
                ? colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null && !widget.iconTrailing) ...[
                Icon(widget.icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (widget.icon != null && widget.iconTrailing) ...[
                const SizedBox(width: 8),
                Icon(widget.icon, size: 18, color: colorScheme.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
