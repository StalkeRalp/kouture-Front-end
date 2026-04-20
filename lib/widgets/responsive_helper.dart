import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double b;
  static late double v;

  // Base design size (e.g., iPhone 13/14)
  static const double baseWidth = 375.0;
  static const double baseHeight = 812.0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    b = (screenWidth - _safeAreaHorizontal) / 100;
    v = (screenHeight - _safeAreaVertical) / 100;
  }

  /// Scales [size] according to the screen width.
  static double w(double size) {
    return (size / baseWidth) * screenWidth;
  }

  /// Scales [size] according to the screen height.
  static double h(double size) {
    return (size / baseHeight) * screenHeight;
  }

  /// Returns a font size scaled to the screen width.
  static double sp(double size) {
    return w(size);
  }

  /// Returns the width percentage of the screen.
  static double wp(double percent) {
    return (percent / 100) * screenWidth;
  }

  /// Returns the height percentage of the screen.
  static double hp(double percent) {
    return (percent / 100) * screenHeight;
  }
}

/// Extension for easy access to responsive sizes via BuildContext.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  double w(double size) => (size / Responsive.baseWidth) * screenWidth;
  double h(double size) => (size / Responsive.baseHeight) * screenHeight;
  double sp(double size) => w(size);
}
