import 'package:flutter/material.dart';

/// Breakpoint constants for responsive design
class Breakpoints {
  Breakpoints._();

  /// Mobile: < 600px
  static const double mobile = 600;

  /// Tablet: 600px - 1024px
  static const double tablet = 850;

  /// Large Tablet (Landscape): 800px - 1200px
  static const double largeTablet = 1200;

  /// Desktop: > 1200px
  static const double desktop = 1200;

  /// Large Desktop: > 1440px
  static const double largeDesktop = 1440;
}

/// Device type enum for responsive layouts
/// DeviceType enum for responsive layouts
enum DeviceType { mobile, tablet, largeTablet, desktop }

/// Get the current device type based on screen width
DeviceType getDeviceType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < Breakpoints.mobile) {
    return DeviceType.mobile;
  } else if (width < Breakpoints.tablet) {
    return DeviceType.tablet;
  } else if (width < Breakpoints.largeTablet) {
    return DeviceType.largeTablet;
  } else {
    return DeviceType.desktop;
  }
}

/// Extension on BuildContext for easy responsive checks
extension ResponsiveContext on BuildContext {
  /// Screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Current device type
  DeviceType get deviceType => getDeviceType(this);

  /// Check if current screen is mobile
  bool get isMobile => screenWidth < Breakpoints.mobile;

  /// Check if current screen is tablet
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;

  /// Check if current screen is desktop
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  /// Check if current screen is large desktop
  bool get isLargeDesktop => screenWidth >= Breakpoints.largeDesktop;

  /// Check if screen is smaller than tablet (mobile only)
  bool get isMobileOnly => screenWidth < Breakpoints.mobile;

  /// Check if current screen is large tablet
  bool get isLargeTablet =>
      screenWidth >= Breakpoints.tablet &&
      screenWidth < Breakpoints.largeTablet;

  /// Check if screen is tablet or larger(includes large tablet)
  bool get isTabletOrLarger => screenWidth >= Breakpoints.mobile;

  /// Check if screen is desktop or larger
  bool get isDesktopOrLarger => screenWidth >= Breakpoints.desktop;
}

/// A widget that builds different layouts based on screen size
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? largeTablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.largeTablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return desktop ?? largeTablet ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= Breakpoints.largeTablet) {
          return largeTablet ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= Breakpoints.mobile) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A utility class for responsive values
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? largeTablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.largeTablet,
    this.desktop,
  });

  /// Get the appropriate value based on screen width
  T getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktop) {
      return desktop ?? largeTablet ?? tablet ?? mobile;
    } else if (width >= Breakpoints.largeTablet) {
      return largeTablet ?? tablet ?? mobile;
    } else if (width >= Breakpoints.mobile) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Responsive padding helper
class ResponsivePadding {
  ResponsivePadding._();

  /// Get horizontal padding based on screen size
  static double horizontal(BuildContext context) {
    if (context.isDesktop) return 64;
    if (context.isTablet) return 32;
    return 16;
  }

  /// Get vertical padding based on screen size
  static double vertical(BuildContext context) {
    if (context.isDesktop) return 48;
    if (context.isTablet) return 32;
    return 24;
  }

  /// Get page padding as EdgeInsets
  static EdgeInsets page(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontal(context),
      vertical: vertical(context),
    );
  }

  /// Get content max width for centered content
  static double maxContentWidth(BuildContext context) {
    if (context.isLargeDesktop) return 1200;
    if (context.isDesktop) return 1000;
    return double.infinity;
  }
}

/// A wrapper widget that constrains content to a max width
class ResponsiveConstraints extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveConstraints({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsivePadding.maxContentWidth(context),
        ),
        padding: padding ?? ResponsivePadding.page(context),
        child: child,
      ),
    );
  }
}

/// Responsive grid helper for calculating cross axis count
class ResponsiveGrid {
  ResponsiveGrid._();

  /// Get cross axis count for a grid based on screen size
  static int crossAxisCount(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int largeTablet = 3,
    int desktop = 3,
    int? largeDesktop,
  }) {
    if (context.isLargeDesktop) return largeDesktop ?? desktop;
    if (context.isDesktop) return desktop;
    if (context.screenWidth >= Breakpoints.tablet) return largeTablet;
    if (context.isTablet) return tablet;
    return mobile;
  }

  static double childAspectRatio(
    BuildContext context, {
    double mobile = 1.0,
    double tablet = 1.2,
    double largeTablet = 1.2,
    double desktop = 1.3,
  }) {
    if (context.isDesktop) return desktop;
    if (context.screenWidth >= Breakpoints.tablet) return largeTablet;
    if (context.isTablet) return tablet;
    return mobile;
  }
}
