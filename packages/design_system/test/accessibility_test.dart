import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

void main() {
  group('WCAG 2.1 AAA Contrast & Luminance Verifier (§5.1)', () {
    test('Absolute pure black and white luminance boundary values', () {
      final double blackLum = AccessibilityUtils.calculateRelativeLuminance(const Color(0xFF000000));
      final double whiteLum = AccessibilityUtils.calculateRelativeLuminance(const Color(0xFFFFFFFF));

      expect(blackLum, equals(0.0));
      expect(whiteLum, closeTo(1.0, 0.0001));

      final double maxRatio = AccessibilityUtils.calculateContrastRatio(
        const Color(0xFF000000),
        const Color(0xFFFFFFFF),
      );
      expect(maxRatio, closeTo(21.0, 0.01));
    });

    test('Primary text (#26322C) on background (#F5F6F3) satisfies WCAG AAA (>7:1)', () {
      final double ratio = AccessibilityUtils.calculateContrastRatio(
        ForensicColors.textPrimary,
        ForensicColors.background,
      );

      // Must be >= 7.0 for WCAG AAA
      expect(ratio, greaterThanOrEqualTo(7.0));
      expect(AccessibilityUtils.isWcagAaaCompliant(ForensicColors.textPrimary, ForensicColors.background), isTrue);
    });

    test('Primary text (#26322C) on surface (#FFFFFF) satisfies WCAG AAA (>7:1)', () {
      final double ratio = AccessibilityUtils.calculateContrastRatio(
        ForensicColors.textPrimary,
        ForensicColors.surface,
      );

      expect(ratio, greaterThanOrEqualTo(7.0));
      expect(AccessibilityUtils.isWcagAaaCompliant(ForensicColors.textPrimary, ForensicColors.surface), isTrue);
    });

    test('Forest Green Dark (#163D2E) on surface (#FFFFFF) satisfies WCAG AAA (>7:1)', () {
      final double ratio = AccessibilityUtils.calculateContrastRatio(
        ForensicColors.forestGreenDark,
        ForensicColors.surface,
      );

      expect(ratio, greaterThanOrEqualTo(7.0));
      expect(AccessibilityUtils.isWcagAaaCompliant(ForensicColors.forestGreenDark, ForensicColors.surface), isTrue);
    });

    test('Forest Green Primary (#20533F) on surface (#FFFFFF) satisfies WCAG AA (>4.5:1)', () {
      final double ratio = AccessibilityUtils.calculateContrastRatio(
        ForensicColors.forestGreenPrimary,
        ForensicColors.surface,
      );

      expect(ratio, greaterThanOrEqualTo(4.5));
      expect(AccessibilityUtils.isWcagAaCompliant(ForensicColors.forestGreenPrimary, ForensicColors.surface), isTrue);
      // Also passes AAA for large headings (>=18pt)
      expect(AccessibilityUtils.isWcagAaaCompliant(
        ForensicColors.forestGreenPrimary,
        ForensicColors.surface,
        isLargeText: true,
      ), isTrue);
    });

    test('Error color (#B00020) on surface (#FFFFFF) satisfies WCAG AA (>4.5:1)', () {
      final double ratio = AccessibilityUtils.calculateContrastRatio(
        ForensicColors.error,
        ForensicColors.surface,
      );

      expect(ratio, greaterThanOrEqualTo(4.5));
    });
  });

  group('Editorial Typography Tokens (§5.1, §7.1)', () {
    test('Title and heading tokens are within specified sp ranges', () {
      // Screen title: 24–28 sp
      expect(ForensicTypography.screenTitle.fontSize, inInclusiveRange(24.0, 28.0));
      // Section title: 19–22 sp
      expect(ForensicTypography.sectionTitle.fontSize, inInclusiveRange(19.0, 22.0));
      // Body: 16–18 sp
      expect(ForensicTypography.body.fontSize, inInclusiveRange(16.0, 18.0));
      // Caption: 13–14 sp
      expect(ForensicTypography.caption.fontSize, inInclusiveRange(13.0, 14.0));
    });

    test('Reader scaling clamps accurately within 14–22 sp and maintains ~1.5 line-height', () {
      // Below min: clamps to 14
      final TextStyle scaledLow = ForensicTypography.readerBody(fontSize: 10.0);
      expect(scaledLow.fontSize, equals(14.0));
      expect(scaledLow.height, closeTo(1.5, 0.1));

      // Above max: clamps to 22
      final TextStyle scaledHigh = ForensicTypography.readerBody(fontSize: 32.0);
      expect(scaledHigh.fontSize, equals(22.0));
      expect(scaledHigh.height, closeTo(1.5, 0.1));

      // Mid range
      final TextStyle scaledMid = ForensicTypography.readerBody(fontSize: 18.0);
      expect(scaledMid.fontSize, equals(18.0));
      expect(scaledMid.height, closeTo(1.5, 0.1));
    });
  });
}
