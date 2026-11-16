import 'dart:math' as math;
import 'package:flutter/material.dart';

/// WCAG Contrast Ratio and Accessibility Verifier (§5.1)
class AccessibilityUtils {
  AccessibilityUtils._();

  /// Calculates relative luminance for a given color per WCAG 2.1 specifications.
  static double calculateRelativeLuminance(Color color) {
    double transformComponent(int component) {
      final double normalized = component / 255.0;
      if (normalized <= 0.03928) {
        return normalized / 12.92;
      } else {
        return math.pow((normalized + 0.055) / 1.055, 2.4).toDouble();
      }
    }

    final double r = transformComponent(color.red);
    final double g = transformComponent(color.green);
    final double b = transformComponent(color.blue);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculates the contrast ratio between two colors (ranging from 1.0 to 21.0).
  static double calculateContrastRatio(Color foreground, Color background) {
    final double lum1 = calculateRelativeLuminance(foreground);
    final double lum2 = calculateRelativeLuminance(background);

    final double lighter = math.max(lum1, lum2);
    final double darker = math.min(lum1, lum2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Checks whether foreground on background satisfies WCAG AA.
  /// Standard text requires >= 4.5:1. Large text (>=18pt or >=14pt bold) requires >= 3.0:1.
  static bool isWcagAaCompliant(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final double ratio = calculateContrastRatio(foreground, background);
    return ratio >= (isLargeText ? 3.0 : 4.5);
  }

  /// Checks whether foreground on background satisfies WCAG AAA.
  /// Standard text requires >= 7.0:1. Large text (>=18pt or >=14pt bold) requires >= 4.5:1.
  static bool isWcagAaaCompliant(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final double ratio = calculateContrastRatio(foreground, background);
    return ratio >= (isLargeText ? 4.5 : 7.0);
  }
}
