import 'package:flutter/material.dart';

/// Screen Device Type enum
enum DeviceType { mobile, largeMobile, tablet, desktop }

/// Responsive Breakpoint definitions
abstract class ResponsiveBreakpoints {
  static const double mobileMax = 480.0;
  static const double largeMobileMax = 768.0;
  static const double tabletMax = 1024.0;
}

/// Helper class to resolve layout details based on screen size
class ResponsiveHelper {
  final BuildContext context;
  final BoxConstraints constraints;

  ResponsiveHelper(this.context, this.constraints);

  double get width => constraints.maxWidth > 0 ? constraints.maxWidth : MediaQuery.of(context).size.width;
  double get height => constraints.maxHeight > 0 ? constraints.maxHeight : MediaQuery.of(context).size.height;

  DeviceType get deviceType {
    if (width <= ResponsiveBreakpoints.mobileMax) {
      return DeviceType.mobile;
    } else if (width <= ResponsiveBreakpoints.largeMobileMax) {
      return DeviceType.largeMobile;
    } else if (width <= ResponsiveBreakpoints.tabletMax) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isLargeMobile => deviceType == DeviceType.largeMobile;
  bool get isTablet => deviceType == DeviceType.tablet;

  /// Get column count for grids dynamically
  int get gridColumnCount {
    switch (deviceType) {
      case DeviceType.mobile:
        return 2;
      case DeviceType.largeMobile:
        return 3;
      case DeviceType.tablet:
        return 4;
      case DeviceType.desktop:
        return 6;
    }
  }

  /// Get horizontal screen padding
  double get horizontalPadding {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16.0;
      case DeviceType.largeMobile:
        return 20.0;
      case DeviceType.tablet:
        return 28.0;
      case DeviceType.desktop:
        return 36.0;
    }
  }
}

/// Widget builder that resolves responsive widget variations based on device type
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveHelper helper) builder;

  const ResponsiveLayout({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final helper = ResponsiveHelper(context, constraints);
        return builder(context, helper);
      },
    );
  }
}
