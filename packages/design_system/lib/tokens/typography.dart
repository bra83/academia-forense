import 'package:flutter/material.dart';
import 'colors.dart';

/// Editorial Typography Tokens & Scales (§5.1, §7.1)
class ForensicTypography {
  ForensicTypography._();

  static const String fontFamilySans = 'Roboto';
  static const String fontFamilySerif = 'Georgia';

  /// Screen title: 24–28 sp (Default: 26sp, bold, Forest Green Dark)
  static const TextStyle screenTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: ForensicColors.forestGreenDark,
    letterSpacing: -0.5,
    height: 1.25,
  );

  /// Section title: 19–22 sp (Default: 20sp, semi-bold, Forest Green Primary)
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: ForensicColors.forestGreenPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  /// Subsection / Subhead: 17-18 sp
  static const TextStyle subTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: ForensicColors.textPrimary,
    height: 1.35,
  );

  /// Body text: 16–18 sp (Default: 16sp, regular, Text Primary)
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: ForensicColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  /// Body Medium: 16sp, 500 weight
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: ForensicColors.textPrimary,
    height: 1.5,
  );

  /// Caption: 13–14 sp (Default: 13sp, regular, Text Secondary)
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: ForensicColors.textSecondary,
    height: 1.4,
  );

  /// Monospace / Code: 14sp
  static const TextStyle code = TextStyle(
    fontSize: 14,
    fontFamily: 'monospace',
    color: ForensicColors.forestGreenDark,
    backgroundColor: ForensicColors.softField,
    height: 1.45,
  );

  /// Generates a reader text style with custom scalable font size (14–22 sp)
  /// and comfortable academic line spacing (~1.5 line-height).
  static TextStyle readerBody({
    double fontSize = 17.0,
    double lineHeight = 1.55,
    FontWeight fontWeight = FontWeight.normal,
    Color color = ForensicColors.textPrimary,
    bool serif = true,
  }) {
    // Clamp to valid range 14 to 22 sp
    final double clampedSize = fontSize.clamp(14.0, 22.0);
    return TextStyle(
      fontSize: clampedSize,
      height: lineHeight,
      fontWeight: fontWeight,
      color: color,
      fontFamily: serif ? fontFamilySerif : fontFamilySans,
      letterSpacing: 0.15,
    );
  }
}
